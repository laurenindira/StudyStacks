//
//  AuthViewModel.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

@Observable
class AuthViewModel: NSObject, ObservableObject {
    static var shared = AuthViewModel()
    
    var user: User? {
        didSet {
            if let currentUser = user {
                saveUserToCache(currentUser)
                userDefaults.set(currentUser != nil , forKey: "isSignedIn")
            } else {
                clearUserCache()
            }
        }
    }
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    //local cache
    private let userDefaults = UserDefaults.standard
    private let userKey = "cachedUser"
    
    //loading and errors
    var isLoading: Bool = false
    var errorMessage: String?
    
    override init() {
        guard auth.currentUser != nil else {
            self.user = nil
            return
        }
        
        if let savedUserData = userDefaults.data(forKey: userKey),
           let savedUser = try? JSONDecoder().decode(User.self, from: savedUserData) {
            self.user = savedUser
            UserDefaults.standard.set(true, forKey: "isSignedIn")
        }
    }
    
    //MARK: - Loading User
    private func loadSession() async {
        guard auth.currentUser != nil else {
            self.user = nil
            return
        }
        
        if let cachedUser = loadUserFromCache() {
            self.user = cachedUser
        } else {
            await loadUserFromFirebase()
        }
        UserDefaults.standard.set(true, forKey: "isSignedIn")
    }
    
    //loading signed in user from Firebase
    func loadUserFromFirebase() async {
        guard let currentUser = auth.currentUser else { return }
        do {
            let snapshot = try await db.collection("users").document(currentUser.uid).getDocument()
            if let userData = snapshot.data() {
                let currentUser = try Firestore.Decoder().decode(User.self, from: userData)
                self.user = currentUser
                saveUserToCache(currentUser)
                print("CURRENT USER DATA: \(String(describing: self.user))")
            }
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Cannot load user - \(String(describing: errorMessage))")
        }
    }
    
    //MARK: - Sign up
    func signUpWithEmail(email: String, password: String, username: String, displayName: String, selectedSubjects: [String], studyReminderTime: Date, studentType: String) async throws {
        self.isLoading = true
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = User(id: result.user.uid, username: username, displayName: displayName, email: email, creationDate: Date(), lastSignIn: Date(), providerRef: "password", selectedSubjects: selectedSubjects, studyReminderTime: studyReminderTime, studentType: studentType, currentStreak: 0, longestStreak: 0, lastStudyDate: Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: Date()), points: 0, favoriteStackIDs: [])
            print("USER: \(user)")
            
            self.user = user
            try await saveUserToFirestore(user: user)
            try await createFriendshipCollection(user: user)
            saveUserToCache(user)
            UserDefaults.standard.set(true, forKey: "isSignedIn")
            self.isLoading = false
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Sign up failure - \(String(describing: errorMessage))")
            self.isLoading = false
            throw error
        }
    }
    
    //MARK: - Sign in
    private func updateLastSignIn(for uid: String) async {
        let userRef = db.collection("users").document(uid)
        do {
            try await userRef.updateData(["lastSignIn": Date()])
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to update last sign in - \(String(describing: errorMessage))")
        }
    }
    
    func signInWithEmail(email: String, password: String) async throws {
        self.isLoading = true
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            await updateLastSignIn(for: result.user.uid)
            await loadUserFromFirebase()
            UserDefaults.standard.set(true, forKey: "isSignedIn")
            updateCachedUser(user: self.user!)
            self.createLocalStreak()
            print("USER: \(user?.id ?? "not known") and \(user?.displayName ?? "not known")")
            //await self.loadFriendshipData(userID: user?.id)
            self.isLoading = false
        } catch let error as NSError {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("ERROR: Sign in failure - \(String(describing: errorMessage))")
            throw error
        }
    }
    
    func signInWithGoogle(tempUser: User, presenting: UIViewController, completion: @escaping(Error?) -> Void) {
        self.isLoading = true
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            guard error == nil else {
                self.isLoading = false
                print("ERROR: Google sign up error - \(error?.localizedDescription ?? "")")
                completion(error)
                return
            }
            
            guard let currentUser = result?.user,
                  let idToken = currentUser.idToken?.tokenString,
                  let email = currentUser.profile?.email,
                  let fullName = currentUser.profile?.name else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: currentUser.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                guard let authResult = result, error == nil else {
                    self.isLoading = false
                    completion(error)
                    return
                }
                
                let uid = authResult.user.uid
                let userRef = self.db.collection("users").document(uid)
                
                userRef.getDocument { document, error in
                    if let document = document, document.exists {
                        if let data = document.data() {
                            Task {
                                await self.loadUserFromFirebase()
                                await self.updateLastSignIn(for: uid)
                                self.updateCachedUser(user: self.user!)
                                //await self.loadFriendshipData(userID: uid)
                                UserDefaults.standard.set(true, forKey: "isSignedIn")
                                self.createLocalStreak()
                            }
                        } else {
                            let newUsername = fullName.filter { !$0.isWhitespace }.lowercased()
                            let newUser = User(id: uid, username: newUsername, displayName: fullName, email: email, creationDate: Date(), lastSignIn: Date(), providerRef: "google", selectedSubjects: tempUser.selectedSubjects, studyReminderTime: tempUser.studyReminderTime, studentType: tempUser.studentType, currentStreak: 0, longestStreak: 0, lastStudyDate: Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: Date()), points: 0, favoriteStackIDs: [])
                            
                            Task {
                                do {
                                    try await self.saveUserToFirestore(user: newUser)
                                    try await self.createFriendshipCollection(user: newUser)
                                    self.user = newUser
                                    self.saveUserToCache(newUser)
                                    UserDefaults.standard.set(true, forKey: "isSignedIn")
                                    self.isLoading = false
                                } catch {
                                    self.isLoading = false
                                    print("ERROR: Could not save Firebase user - \(error.localizedDescription)")
                                    completion(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Saving user data
    func saveUserToFirestore(user: User) async throws {
        do {
            try await db.collection("users").document(user.id).setData([
                "id": user.id,
                "username": user.username,
                "displayName": user.displayName,
                "email": user.email,
                "creationDate": Timestamp(date: user.creationDate),
                "lastSignIn": Timestamp(date: user.lastSignIn ?? Date()),
                "providerRef": user.providerRef,
                "selectedSubjects": user.selectedSubjects,
                "studyReminderTime": user.studyReminderTime,
                "studentType": user.studentType,
                "currentStreak": user.currentStreak,
                "longestStreak": user.longestStreak,
                "lastStudyDate": Timestamp(date: user.lastStudyDate ?? Date()),
                "points": user.points,
                "favoriteStackIDs": user.favoriteStackIDs
            ])
            print("SUCCESS: Saved user to Firestore")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failure saving to Firestore - \(String(describing: errorMessage))")
            throw error
        }
    }
    
    //MARK: - Sign out and deletion
    func signOut() async {
        do {
            self.isLoading = true
            if auth.currentUser?.uid != nil {
                await updatePointsInFirebase()
                StackViewModel.shared.clearFavorites()
                FriendsViewModel.shared.clearFriendshipLocally()
                clearUserCache()
                try auth.signOut()
                self.user = nil
            }
            self.isLoading = false
        } catch let error {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("ERROR: Sign out error - \(error.localizedDescription)")
        }
    }
    
//    func deleteUserAccount(completion: @escaping (Error?) -> Void) async throws {
//        guard let currentUser = auth.currentUser else {
//            completion(NSError(domain: "UserNotLoggedIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in."]))
//            return
//        }
//        
//        self.isLoading = true
//        let userID = currentUser.uid
//        let userRef = db.collection("users").document(userID)
//        //TODO: add in flashcard removal when implemented
//        
//        do {
//            try await userRef.delete()
//            print("SUCCESS: User removed from user collection")
//            try await currentUser.delete()
//            print("SUCCESS: User removed from auth console")
//            self.user = nil
//            clearUserCache()
//        } catch let error {
//            self.isLoading = false
//            print("ERROR: Deletion Error - \(error.localizedDescription)")
//            completion(error)
//        }
//    }
    
    // does not work, email gets deleted but the users stacks still showing up
      func deleteUserAccount(completion: @escaping (Error?) -> Void) async throws {
          guard let currentUser = auth.currentUser else {
              completion(NSError(domain: "UserNotLoggedIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in."]))
              return
          }

          self.isLoading = true
          let userID = currentUser.uid
          let userRef = db.collection("users").document(userID)

          do {
              let deckQuery = db.collection("decks").whereField("userID", isEqualTo: userID)
              let deckSnapshot = try await deckQuery.getDocuments()

              for deckDoc in deckSnapshot.documents {
                  let cardsRef = deckDoc.reference.collection("cards")
                  let cardsSnapshot = try await cardsRef.getDocuments()

                  let batch = db.batch()
                  for cardDoc in cardsSnapshot.documents {
                      batch.deleteDocument(cardDoc.reference)
                  }
                  try await batch.commit()

                  try await deckDoc.reference.delete()
              }

              let publicDeckQuery = db.collection("decks").whereField("createdBy", isEqualTo: userID)
              let publicDeckSnapshot = try await publicDeckQuery.getDocuments()

              for deckDoc in publicDeckSnapshot.documents {
                  if !deckSnapshot.documents.contains(where: { $0.documentID == deckDoc.documentID }) {
                      let cardsRef = deckDoc.reference.collection("cards")
                      let cardsSnapshot = try await cardsRef.getDocuments()

                      let batch = db.batch()
                      for cardDoc in cardsSnapshot.documents {
                          batch.deleteDocument(cardDoc.reference)
                      }
                      try await batch.commit()

                      try await deckDoc.reference.delete()
                  }
              }

              print("SUCCESS: All user decks and cards deleted")

              try await userRef.delete()
              print("SUCCESS: User removed from user collection")

              try await currentUser.delete()
              print("SUCCESS: User removed from auth console")

              self.user = nil
              clearUserCache()
              self.isLoading = false
              completion(nil)

          } catch let error {
              self.isLoading = false
              print("ERROR: Deletion Error - \(error.localizedDescription)")
              completion(error)
          }
      }
    
    //MARK: - User Editing
    func updateStudyReminder(for userID: String, newReminderTime: Date) async {
        guard let user = user else { return }
        self.isLoading = true
        
        do {
            try await db.collection("users").document(userID).updateData(["studyReminderTime" : newReminderTime ])
            print("SUCCESS: Changed reminder time")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to update reminder time - \(String(describing: errorMessage))")
        }
        self.isLoading = false
    }
    
    //MARK: - Streak Calculations
    func updateStudyStreak(for userID: String) async {
        guard let user = user else { return }
        
        var currentStreak = user.currentStreak
        var longestStreak = user.longestStreak
        
        let calendar = Calendar.current
        let today = Date()
        
        if UserDefaults.standard.object(forKey: "lastStreakUpdate") != nil {
            if let lastUpdate = UserDefaults.standard.object(forKey: "lastStreakUpdate") as? Date {
                if calendar.isDateInToday(lastUpdate) {
                    print("OOP: Streak already updated today.")
                    return
                }
            }
        }
        
        //COUNTING CURRENT STREAK
        if let lastStudyDate = user.lastStudyDate {
            if calendar.isDateInYesterday(lastStudyDate) {
                currentStreak = user.currentStreak + 1
            } else if !calendar.isDateInToday(lastStudyDate) || !calendar.isDateInYesterday(lastStudyDate) {
                //ie if streak broke womp womp
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        //UPDATING LONGEST STREAK
        if currentStreak > user.longestStreak {
            longestStreak = currentStreak
        } else {
            longestStreak = user.longestStreak
        }
        
        //UPDATING LAST STUDIED
        let lastStudyDate = today
        
        //SAVING CHANGES
        do {
            try await db.collection("users").document(user.id).setData(["currentStreak": currentStreak, "longestStreak": longestStreak, "lastStudyDate": lastStudyDate], merge: true)
            UserDefaults.standard.set(today, forKey: "lastStreakUpdate")
            print("SUCCESS: Updated streak")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Could not update streaks - \(String(describing: errorMessage))")
        }
    }
    
    func createLocalStreak() {
        //updating streak value if hadn't been set before
        if UserDefaults.standard.object(forKey: "lastStreakUpdate") == nil {
            let yesterday = Calendar(identifier: .gregorian).date(byAdding: .day, value: -1, to: Date())
            UserDefaults.standard.set(yesterday, forKey: "lastStreakUpdate")
        }
    }
    
    func resetLocalStreak() {
        UserDefaults.standard.removeObject(forKey: "lastStreakUpdate")
    }
    
    //TODO: move to relevant page when detail views are created
//    func endStudySession() async {
//        guard let userID = auth.user?.id else { return }
//        
//        await updateStudyStreak(for: userID)
//
            //TO DO: milestones and badges related to streaks
//        if let streak = auth.user?.currentStreak {
//            //checkForMilestones(streak: streak)
//        }
//    }

    //MARK: - Tracking points
    func updatePointsInFirebase() async {
        guard let user = user else {
            print("ERROR: No user logged in")
            return
        }
        
        let currentPoints = PointsManager.shared.loadPoints()
        
        do {
            try await db.collection("users").document(user.id).updateData(["points": currentPoints])
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Could not update points - \(String(describing: errorMessage))")
        }
    }
    
    func createLocalPointTracking() {
        guard let user = user else {
            print("ERROR: No user logged in")
            return
        }
        
        let currentPoints = user.points
        
        if UserDefaults.standard.object(forKey: "userPoints") == nil {
            UserDefaults.standard.set(currentPoints, forKey: "userPoints")
        }
    }
    
    func resetLocalPointTracking() {
        UserDefaults.standard.removeObject(forKey: "userPoints")
    }
    
    //MARK: -  Friendship data
    func createFriendshipCollection(user: User) async throws {
        do {
            try await db.collection("friendships").document(user.id).setData([
                "userID": user.id,
                "friends": [],
                "receivedRequests": [],
                "sentRequests": []
            ])
            
            //await loadFriendshipData(userID: user.id)
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to add friendship collection - \(String(describing: errorMessage))")
            throw error
        }
    }
    
//    func loadFriendshipData(userID: String) async {
//        await FriendsViewModel.shared.fetchFriends(userID: user?.id)
//        await FriendsViewModel.shared.fetchFriendRequests(userID: user?.id)
//    }
    
    //MARK: - Local User Caching
    private func saveUserToCache(_ user: User) {
        if let encodedUser = try? JSONEncoder().encode(user) {
            userDefaults.set(encodedUser, forKey: userKey)
        }
        self.createLocalStreak()
        self.createLocalPointTracking()
        print("USER IN CACHE ONCE SAVED: \(String(describing: userDefaults.data(forKey: userKey)))")
    }

    private func updateCachedUser(user: User) {
        if let encodedUser = try? JSONEncoder().encode(user) {
            userDefaults.set(encodedUser, forKey: userKey)
        }
        print("USER IN CACHE ONCE UPDATED: \(String(describing: userDefaults.data(forKey: userKey)))")
    }
    
    private func loadUserFromCache() -> User? {
        guard let savedUserData = userDefaults.data(forKey: userKey) else { return nil }
        print("USER IN CACHE ONCE LOADED: \(savedUserData)")
        return try? JSONDecoder().decode(User.self, from: savedUserData)
    }
    
    private func clearUserCache() {
        userDefaults.removeObject(forKey: userKey)
        resetLocalStreak()
        StackViewModel.shared.clearFavorites()
        resetLocalPointTracking()
        UserDefaults.standard.set(false, forKey: "isSignedIn")
        print("USER IN DEFAULTS: \(String(describing: userDefaults.data(forKey: userKey)))")
    }
}

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}
