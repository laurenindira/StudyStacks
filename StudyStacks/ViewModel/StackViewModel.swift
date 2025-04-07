//
//  StackViewModel.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/4/25.
//

import Foundation
import Firebase
import FirebaseFirestore

@Observable
class StackViewModel: ObservableObject {
    static var shared = StackViewModel()
    
    var stacks: [Stack] = []
    var userStacks: [Stack] = []
    var publicStacks: [Stack] = []
    var favoriteStackIDs: [String] = []
    
    var combinedStacks: [Stack] {
        let filteredPublicStacks = publicStacks.filter({ !userStacks.contains($0) })
        return (userStacks + filteredPublicStacks).sorted { $0.creationDate > $1.creationDate }
    }
    
//    var favoriteStacks: [Stack] {
//        return combinedStacks.filter { favoriteStackIDs.contains($0.id) }
//    }
    
    var creatingStack: Bool = false
    var editingStack: Bool = false
    
    var isLoading: Bool = false
    var errorMessage: String = ""
    
    private let db = Firestore.firestore()
    private var auth = AuthViewModel.shared
    
    //delaying firebase writes for favorites
    private var syncTimer: Timer?
    private let syncDelay: TimeInterval = 0.5
    
    //MARK: - Stack Fetching
    func fetchUserStacks(for userID: String) async {
        self.isLoading = true
        
        guard let _ = auth.user else {
            print("USER: \(String(describing: auth.user))")
            self.errorMessage = "ERROR: user not logged in"
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        do {
            let querySnapshot = try await db.collection("allStacks").document(userID).collection("stacks").getDocuments()
            let stacks = querySnapshot.documents.compactMap { try? $0.data(as: Stack.self) }
            self.userStacks = stacks
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch user stacks - \(String(describing: errorMessage))")
        }
        self.isLoading = false
    }
    
    func fetchPublicStacks() async {
        self.isLoading = true
        
        do {
            let querySnapshot = try await db.collectionGroup("stacks").whereField("isPublic", isEqualTo: true).getDocuments()
            let stacks = querySnapshot.documents.compactMap { try? $0.data(as: Stack.self) }
            self.publicStacks = stacks
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch public stacks - \(String(describing: errorMessage))")
        }
        self.isLoading = false
    }
    
    //MARK: - Stack Creation
    func createStack(for userID: String, stackToAdd: Stack) async {
        self.isLoading = true
        let stackRef = db.collection("allStacks").document(userID).collection("stacks").document()
        var stackToAddWithID = stackToAdd
        stackToAddWithID.id = stackRef.documentID
        
        do {
            try stackRef.setData(from: stackToAddWithID)
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed create stack - \(String(describing: errorMessage))")
            self.isLoading = false
        }
        self.isLoading = false
    }
    
    //MARK: - Stack Deletion
    func deleteStack(_ stack: Stack) async {
        self.isLoading = true
        
        guard let userID = auth.user?.id else {
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        let stackRef = db.collection("allStacks").document(userID).collection("stacks")
        do {
            try await stackRef.document(stack.id).delete()
            await self.fetchUserStacks(for: userID)
            
            print("DOCUMENT REMOVED")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to delete stack: \(error.localizedDescription)")
        }
        
        self.isLoading = false
    }
    
    //MARK: - Stack Update
    func updateStack(for userID: String, stackToUpdate: Stack) async {
        self.isLoading = true
        let stackRef = db.collection("allStacks").document(userID).collection("stacks").document(stackToUpdate.id)

        do {
            try stackRef.setData(from: stackToUpdate)
            print("SUCCESS: Stack updated")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to update stack - \(String(describing: errorMessage))")
        }
        
        self.isLoading = false
    }
    
    //MARK: - Favorite Stacks
    func fetchUserFavorites() async {
        guard let user = auth.user else {
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        do {
            let snapshot = try await db.collection("users").document(user.id).getDocument()
            let favorites = snapshot.data()?["favoriteStackIDs"] as? [String] ?? []
            self.favoriteStackIDs = favorites
            print("FAVORITE IDS: \(self.favoriteStackIDs)")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch user favorites - \(String(describing: errorMessage))")
        }
    }
    
    func isFavorite(_ stack: Stack) -> Bool {
        return self.favoriteStackIDs.contains(stack.id)
    }
    
    func toggleFavorite(for stackID: String) async {
        self.isLoading = true
        
        guard let user = auth.user else {
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        if favoriteStackIDs.contains(stackID) {
            favoriteStackIDs.removeAll { $0 == stackID}
        } else {
            favoriteStackIDs.append(stackID)
        }
        
        do {
            try await db.collection("users").document(user.id).updateData(["favoriteStackIDs": favoriteStackIDs])
            print("SUCCESS: Favorite stacks updated in Firebase")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to update favorites - \(String(describing: errorMessage))")
        }
    }
    
    //TODO: revisit these later on in order to delay the sync for the favorites
//    private func scheduleFavoritesSync() {
//        syncTimer?.invalidate()
//        syncTimer = Timer.scheduledTimer(withTimeInterval: syncDelay, repeats: false) { [weak self] _ in
//            Task {
//                print("BEGINNING SYNC")
//                await self?.syncFavoritesWithFirebase()
//            }
//        }
//    }
//    
//    func syncFavoritesWithFirebase() async {
//        guard let user = auth.user else { return }
//        
//        
//    }
}
