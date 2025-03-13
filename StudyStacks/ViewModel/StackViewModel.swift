//
//  StackViewModel.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/4/25.
//

import Foundation
import Firebase
import FirebaseFirestore

class StackViewModel: ObservableObject {
    static var shared = StackViewModel()
    @Published var stacks: [Stack] = []
    @Published var userStacks: [Stack] = []
    @Published var publicStacks: [Stack] = []
    
    var combinedStacks: [Stack] {
        let userIDs = Set(userStacks.map { $0.id })
        let filteredPublicStacks = publicStacks.filter { userIDs.contains($0.id) }
        
        return (userStacks + filteredPublicStacks).sorted { $0.creationDate > $1.creationDate }
    }
    
    var creatingStack: Bool = false
    var editingStack: Bool = false
    
    var isLoading: Bool = false
    var errorMessage: String = ""
    
    private let db = Firestore.firestore()
    private var auth = AuthViewModel.shared
    
    func fetchStacks() async {
        self.isLoading = true
        
        guard let userID = auth.user?.id else {
            self.errorMessage = "ERROR: user not logged in"
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        do {
            stacks = try await fetchUserStacks(userID: userID)
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed fetch stack - \(String(describing: errorMessage))")
            self.isLoading = false
        }
        self.isLoading = false
        
    }
    
    func fetchUserStacks(for userID: String) async {
        self.isLoading = true
        
        guard let userID = auth.user?.id else {
            self.errorMessage = "ERROR: user not logged in"
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        do {
            let querySnapshot = try await db.collection("allStacks").document(userID).collection("stacks").getDocuments()
            let stacks = querySnapshot.documents.compactMap { try? $0.data(as: Stack.self) }
            userStacks = stacks
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
            publicStacks = stacks
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch public stacks - \(String(describing: errorMessage))")
        }
        self.isLoading = false
    }
    
    private func fetchUserStacks(userID: String) async throws -> [Stack] {
        let querySnapshot = try await db.collection("allStacks").document(userID).collection("stacks").getDocuments()
        return querySnapshot.documents.compactMap { document in
            var stack = try? document.data(as: Stack.self)
            stack?.id = document.documentID
            return stack
        }
    }
    
    func createStack(for userID: String, stackToAdd: Stack) async {
        self.isLoading = true
        let stackRef = db.collection("allStacks").document(userID).collection("stacks").document()
        var stackToAddWithID = stackToAdd
        stackToAddWithID.id = stackRef.documentID
        
        do {
            try await stackRef.setData(from: stackToAddWithID)
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed create stack - \(String(describing: errorMessage))")
            self.isLoading = false
        }
        self.isLoading = false
    }
    
    func deleteStack(_ stack: Stack) {
        self.isLoading = true
        
        guard let userID = auth.user?.id else {
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }
        
        let stackRef = db.collection("allStacks").document(userID).collection("stacks")
        stackRef.document(stack.id).delete { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("ERROR: Failed to delete stack: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
        self.isLoading = false
    }
    
    
}
