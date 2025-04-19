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
        let filteredPublicStacks = publicStacks.filter { !userStacks.contains($0) }
        return (userStacks + filteredPublicStacks).sorted { $0.creationDate > $1.creationDate }
    }

    var creatingStack: Bool = false
    var editingStack: Bool = false
    var isLoading: Bool = false
    var errorMessage: String = ""

    private let db = Firestore.firestore()
    private var syncTimer: Timer?
    private let syncDelay: TimeInterval = 0.5

    // MARK: - Stack Fetching
    func fetchUserStacks(for userID: String) async {
        self.isLoading = true
        guard let _ = AuthViewModel.shared.user else {
            self.errorMessage = "ERROR: user not logged in"
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }

        do {
            let querySnapshot = try await db.collection("allStacks").document(userID).collection("stacks").getDocuments()
            let stacks = querySnapshot.documents.compactMap { try? $0.data(as: Stack.self) }
            self.userStacks = stacks
        } catch {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch user stacks - \(self.errorMessage)")
        }

        self.isLoading = false
    }

    func fetchPublicStacks() async {
        self.isLoading = true

        do {
            let querySnapshot = try await db.collectionGroup("stacks")
                .whereField("isPublic", isEqualTo: true)
                .getDocuments()
            let stacks = querySnapshot.documents.compactMap { try? $0.data(as: Stack.self) }
            self.publicStacks = stacks
        } catch {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch public stacks - \(self.errorMessage)")
        }

        self.isLoading = false
    }

    // MARK: - Stack Creation
    func createStack(for userID: String, stackToAdd: Stack, badgeAwarded: @escaping (String?) -> Void) async {
        isLoading = true
        let stackRef = db.collection("allStacks").document(userID).collection("stacks").document()
        var stackToAddWithID = stackToAdd
        stackToAddWithID.id = stackRef.documentID

        do {
            try stackRef.setData(from: stackToAddWithID)
            await fetchUserStacks(for: userID)
            await checkForStackBadges(userID: userID) { badgeID in
                badgeAwarded(badgeID)
            }
        } catch {
            errorMessage = error.localizedDescription
            print("ERROR: Failed create stack - \(errorMessage)")
            badgeAwarded(nil)
        }

        isLoading = false
    }

    // MARK: - Badge Logic
    func checkForStackBadges(userID: String, completion: @escaping (String?) -> Void) async {
        let milestones: [Int: String] = [
            1: "1_Stack",
            5: "5_Stacks",
            10: "10_Stacks"
        ]

        guard let user = AuthViewModel.shared.user else {
            completion(nil)
            return
        }

        let currentBadgeIDs = user.earnedBadges
        let currentStackCount = userStacks.count

        guard let badgeID = milestones[currentStackCount],
              !currentBadgeIDs.contains(badgeID) else {
            completion(nil)
            return
        }

        var updatedBadges = currentBadgeIDs
        updatedBadges.append(badgeID)

        do {
            try await db.collection("users").document(userID).updateData(["earnedBadges": updatedBadges])
            AuthViewModel.shared.user?.earnedBadges = updatedBadges
            print("SUCCESS: Awarded badge \(badgeID)")
            completion(badgeID)
        } catch {
            print("ERROR: Failed to update badges in Firestore: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    // MARK: - Stack Deletion
    func deleteStack(_ stack: Stack) async {
        self.isLoading = true

        guard let user = AuthViewModel.shared.user else {
            print("ERROR: user not logged in")
            self.isLoading = false
            return
        }

        do {
            try await db.collection("allStacks").document(user.id).collection("stacks").document(stack.id).delete()
            await self.fetchUserStacks(for: user.id)
            print("DOCUMENT REMOVED")
        } catch {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to delete stack: \(error.localizedDescription)")
        }

        self.isLoading = false
    }

    // MARK: - Stack Update
    func updateStack(for userID: String, stackToUpdate: Stack) async {
        self.isLoading = true
        let stackRef = db.collection("allStacks").document(userID).collection("stacks").document(stackToUpdate.id)

        do {
            try stackRef.setData(from: stackToUpdate)
            print("SUCCESS: Stack updated")
        } catch {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to update stack: \(error.localizedDescription)")
        }

        self.isLoading = false
    }

    // MARK: - Favorites
    func fetchUserFavorites(for userID: String) async {
        guard let user = AuthViewModel.shared.user else {
            print("ERROR: user not logged in")
            return
        }

        do {
            let snapshot = try await db.collection("users").document(userID).getDocument()
            let favorites = snapshot.data()?["favoriteStackIDs"] as? [String] ?? []
            self.favoriteStackIDs = favorites
        } catch {
            self.errorMessage = error.localizedDescription
            print("ERROR: Failed to fetch favorites - \(self.errorMessage)")
        }
    }

    func isFavorite(_ stack: Stack) -> Bool {
        return self.favoriteStackIDs.contains(stack.id)
    }

    func toggleFavorite(for stackID: String) async {
        guard let user = AuthViewModel.shared.user else { return }

        if favoriteStackIDs.contains(stackID) {
            favoriteStackIDs.removeAll { $0 == stackID }
        } else {
            favoriteStackIDs.append(stackID)
        }

        do {
            try await db.collection("users").document(user.id).updateData(["favoriteStackIDs": favoriteStackIDs])
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func clearFavorites() {
        self.favoriteStackIDs = []
    }
}
