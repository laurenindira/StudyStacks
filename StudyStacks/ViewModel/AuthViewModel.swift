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
    @Published var user: User?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    //local cache
    private let userDefaults = UserDefaults.standard
    private let userKey = "cachedUser"
    
    //loading and errors
    var isLoading: Bool = false
    var errorMessage: String?
    
    override init() {
        Task {
            await loadSession()
        }
    }
    
    //MARK: - Loading User
    //loading user session when app launches (if exists)
    private func loadSession() async {
        guard let user = auth.currentUser else {
            self.user = nil
            return
        }
        
        if let cachedUser = loadUserFromCache() {
            self.user = cachedUser
        } else {
            await loadUserFromFirebase()
        }
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
            }
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Cannot load user - \(String(describing: errorMessage))")
        }
    }
    
    //MARK: - Sign up
    func signUpWithEmail(email: String, password: String, username: String, displayName: String) async throws {
        self.isLoading = true
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let user = User(id: result.user.uid, username: username, displayName: displayName, email: email, creationDate: Date(), lastSignIn: Date(), providerRef: "password")
            self.user = user
            try await saveUserToFirestore(user: user)
            saveUserToCache(user)
            self.isLoading = false
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Sign up failure - \(String(describing: errorMessage))")
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
            self.isLoading = false
        } catch let error as NSError {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("ERROR: Sign in failure - \(String(describing: errorMessage))")
            throw error
        }
    }
    
    func signInWithGoogle(presenting: UIViewController, completion: @escaping(Error?) -> Void) {
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
                            }
                        }
                    } else {
                        let newUsername = fullName.filter { !$0.isWhitespace }.lowercased()
                        let newUser = User(id: uid, username: newUsername, displayName: fullName, email: email, creationDate: Date(), lastSignIn: Date(), providerRef: "google")
                        
                        Task {
                            do {
                                try await self.saveUserToFirestore(user: newUser)
                                self.user = newUser
                                self.saveUserToCache(newUser)
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
                "providerRef": user.providerRef
            ])
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failure saving to Firestore - \(String(describing: errorMessage))")
            throw error
        }
    }
    
    private func saveUserToCache(_ user: User) {
        if let encodedUser = try? JSONEncoder().encode(user) {
            userDefaults.set(encodedUser, forKey: userKey)
        }
    }
    
    //MARK: - Sign out and deletion
    func signOut() throws {
        do {
            self.isLoading = true
            if auth.currentUser?.uid != nil {
                try auth.signOut()
                self.user = nil
                clearUserCache()
            }
            self.isLoading = false
        } catch let error {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("ERROR: Sign out error - \(error.localizedDescription)")
        }
    }
    
    func deleteUserAccount(completion: @escaping (Error?) -> Void) async throws {
        guard let currentUser = auth.currentUser else {
            completion(NSError(domain: "UserNotLoggedIn", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is currently logged in."]))
            return
        }
        
        self.isLoading = true
        let userID = currentUser.uid
        let userRef = db.collection("users").document(userID)
        //TODO: add in flashcard removal when implemented
        
        do {
            try await userRef.delete()
            print("SUCCESS: User removed from user collection")
            try await currentUser.delete()
            print("SUCCESS: User removed from auth console")
            self.user = nil
            clearUserCache()
        } catch let error {
            self.isLoading = false
            print("ERROR: Deletion Error - \(error.localizedDescription)")
            completion(error)
        }
    }
    
    //MARK: - Local User Caching
    private func loadUserFromCache() -> User? {
        guard let savedUserData = userDefaults.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: savedUserData)
    }
    
    private func clearUserCache() {
        userDefaults.removeObject(forKey: userKey)
    }
}
