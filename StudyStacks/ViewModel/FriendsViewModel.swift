//
//  FriendsViewModel.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/31/25.
//

import Foundation
import Firebase
import FirebaseFirestore

@Observable
class FriendsViewModel: ObservableObject {
    static var shared = FriendsViewModel()
    
    var friends: [Friend] = []
    var receivedRequests: [Friend] = []
    var sentRequests: [String] = []
    
    var isLoading: Bool = false
    var errorMessage: String = ""
    var showAlert: Bool = false
    
    private let db = Firestore.firestore()
    
    //MARK: - Friend functions
    
    //FETCHING FRIENDS
    func fetchFriends(userID: String?) async {
        self.isLoading = true
        
        guard let user = AuthViewModel.shared.user else {
            self.errorMessage = "ERROR: user not logged in"
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        let documentID: String
        if userID != nil { documentID = userID! } else { documentID = user.id }
        
        do {
            //FETCHING ALL USER FRIENDS
            let snapshot = try await db.collection("friendships").document(documentID).getDocument()
            guard let data = snapshot.data(), let friendIDs = data["friends"] as? [String], !friendIDs.isEmpty else {
                self.friends = []
                return
            }
            
            //FETCHING USER DATA FOR EACH FRIEND
            let querySnapshot = try await db.collectionGroup("users").whereField("id", in: friendIDs).getDocuments()
            let friendInfo = querySnapshot.documents.compactMap { try? $0.data(as: Friend.self) }
            self.friends = friendInfo
            self.isLoading = false
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch friends - \(String(describing: errorMessage))")
            self.isLoading = false
        }
    }
    
    //FETCHING FRIEND REQUESTS
    func fetchFriendRequests(userID: String?) async {
        self.isLoading = true
        
        guard let user = AuthViewModel.shared.user else {
            self.errorMessage = "ERROR: user not logged in"
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        let documentID: String
        if userID != nil { documentID = userID! } else { documentID = user.id }
        
        do {
            let snapshot = try await db.collection("friendships").document(documentID).getDocument()
            guard let data = snapshot.data() else { return }
            
            if let receivedIDs = data["receivedRequests"] as? [String], !receivedIDs.isEmpty {
                let querySnapshot = try await db.collection("users").whereField("id", in: receivedIDs).getDocuments()
                self.receivedRequests = querySnapshot.documents.compactMap { try? $0.data(as: Friend.self) }
            } else {
                self.receivedRequests = []
            }
            
            self.sentRequests = data["sentRequests"] as? [String] ?? []
            self.isLoading = false
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch friend requests - \(String(describing: errorMessage))")
            self.isLoading = false
        }
    }
    
    //SENDING REQUESTS
    func sendFriendRequest(toEmail: String, senderID: String, senderEmail: String) async -> (Bool, String) {
        self.isLoading = true
        let senderID = senderID
        
        //checking if friend is in list
        if let existingFriend = friends.first(where: { $0.email == toEmail }) {
            self.isLoading = false
            return (false, "You are already friends with \(existingFriend.displayName)")
        }
        
        if toEmail == senderEmail {
            print("TO EMAIL: \(toEmail) and USER EMAIL: \(senderEmail)")
            self.isLoading = false
            return(false, "You can't add yourself as a friend... Good try!")
        }
        
        //sending request if not friends already
        do {
            let snapshot = try await db.collection("users").whereField("email", isEqualTo: toEmail).getDocuments()
            guard let document = snapshot.documents.first else {
                self.errorMessage = "Email doesn't have matching document"
                print("ERROR: Email doesn't have matching document")
                showAlert = true
                return (false, "Whoops, this email isn't connected to an account")
            }
            
            let recipientID = document.documentID
            let senderRef = db.collection("friendships").document(senderID)
            let recipientRef = db.collection("friendships").document(recipientID)
            
            try await senderRef.updateData(["sentRequests": FieldValue.arrayUnion([recipientID])])
            try await recipientRef.updateData(["receivedRequests": FieldValue.arrayUnion([senderID])])
            self.isLoading = false
            return (true, "Request sent!")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to send friend requests - \(String(describing: errorMessage))")
            self.isLoading = false
            return (false, "ERROR: Failed to send friend request")
        }
    }
    
    //ACCEPTING REQUESTS
    func acceptFriendRequest(senderID: String, currentUserID: String) async {
        self.isLoading = true

        let userID = currentUserID
        
        let userRef = db.collection("friendships").document(userID)
        let senderRef = db.collection("friendships").document(senderID)
        
        do {
            try await db.runTransaction { (transaction, _) -> Any?  in
                transaction.updateData([
                    "friends": FieldValue.arrayUnion([senderID]),
                    "receivedRequests": FieldValue.arrayRemove([senderID])
                ], forDocument: userRef)
                
                transaction.updateData([
                    "friends": FieldValue.arrayUnion([userID]),
                    "sentRequests": FieldValue.arrayRemove([userID])
                ], forDocument: senderRef)
                return nil
            }
            print("SUCCESS: accepted friend request")
            await fetchFriends(userID: userID)
            await fetchFriendRequests(userID: userID)
            
            self.isLoading = false
            
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to accept friend request - \(String(describing: errorMessage))")
            
            self.isLoading = false
        }
    }
    
    //REJECTING REQUESTS
    func rejectFriendRequest(senderID: String, currentUserID: String) async {
        self.isLoading = true
        
        let userID = currentUserID
        
        let userRef = db.collection("friendships").document(userID)
        let senderRef = db.collection("friendships").document(senderID)
        
        do {
            try await userRef.updateData(["receivedRequests": FieldValue.arrayRemove([senderID])])
            try await senderRef.updateData(["sentRequests": FieldValue.arrayRemove([userID])])
            await fetchFriendRequests(userID: userID)
            print("REJECTED REQUEST")
            self.isLoading = false
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to reject friend request - \(String(describing: errorMessage))")
            self.isLoading = false
        }
    }
    
    //GET FRIEND COUNT
    func getFriendCount(userID: String) async -> Int {
        self.isLoading = true
    
        do {
            let snapshot = try await db.collection("friendships").document(userID).getDocument()
            guard let data = snapshot.data(), let friendIDs = data["friends"] as? [String], !friendIDs.isEmpty else {
                return 0
            }
            self.isLoading = false
            return friendIDs.count
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to count friends - \(String(describing: errorMessage))")
            self.isLoading = false
            return 0
        }
    }
    
    //REMOVING FRIENDS
    func removeFriend(friendIDToRemove: String, currentUserID: String) async -> (Bool, String?) {
        self.isLoading = true
        
        let userID = currentUserID
        
        let userRef = db.collection("friendships").document(userID)
        let friendRef = db.collection("friendships").document(friendIDToRemove)
        
        do {
            try await userRef.updateData(["friends": FieldValue.arrayRemove([friendIDToRemove])])
            try await friendRef.updateData(["friends": FieldValue.arrayRemove([userID])])
            print("SUCCESS: Removed from both friend lists")
            
            DispatchQueue.main.async {
                self.friends.removeAll { $0.id == friendIDToRemove }
            }
            
            self.isLoading = false
            return (true, "friend removed")
        } catch let error as NSError {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to remove friend -\(String(describing: errorMessage))")
            return (false, "Whoops, we couldn't remove this friend")
        }
    }
    
    //CLEARING FRIENDS ON SIGN OUT
    func clearFriendshipLocally() {
        friends = []
        receivedRequests = []
        sentRequests = []
        print("ALL FRIENDSHIP DATA CLEARED")
    }
}
