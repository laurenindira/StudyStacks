//
//  StackViewModel.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/7/25.
//

import Foundation
import Firebase
import FirebaseFirestore

class StackViewModel: ObservableObject {
    static var shared = StackViewModel()
    @Published var stacks: [Stack] = []
    
    var creatingStack: Bool = false
    var editingStack: Bool = false
    
    var isLoading: Bool = false
    var errorMessage: String = ""
    
    private let db = Firestore.firestore()
    private var auth = AuthViewModel.shared
    
    @MainActor
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
            self.isLoading = false
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed fetch stack - \(String(describing: errorMessage))")
            self.isLoading = false
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
    
    func updateStack(for userID: String, stackToUpdate: Stack) async {
        self.isLoading = true
        let stackRef = db.collection("allStacks").document(userID).collection("stacks").document(stackToUpdate.id)

        do {
            try await stackRef.setData(from: stackToUpdate)
            print("SUCCESS: Stack updated")
        } catch let error as NSError {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to update stack - \(String(describing: errorMessage))")
        }
        
        self.isLoading = false
    }
    
    
}
