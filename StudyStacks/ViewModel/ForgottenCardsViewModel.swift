//
//  ForgottenCardsViewModel.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/1/25.
//

import Foundation

class ForgottenCardsViewModel: ObservableObject {
    @Published var localForgottenCards: [String: Set<String>] = [:]
    private var userID: String = ""

    // Load cards for a user (usually called on login or onAppear)
    func load(for userID: String) {
        self.userID = userID
        let key = "forgottenCards_\(userID)"

        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let decoded = try JSONDecoder().decode([String: Set<String>].self, from: data)
                self.localForgottenCards = decoded
                print("✅ Loaded forgotten cards for user \(userID)")
            } catch {
                print("⚠️ Failed to decode forgotten cards: \(error)")
                self.localForgottenCards = [:]
            }
        } else {
            print("ℹ️ No existing forgotten cards for user \(userID)")
            self.localForgottenCards = [:]
        }
        print("Loaded: \(localForgottenCards)")
    }

    // Save to UserDefaults
    private func save() {
        let key = "forgottenCards_\(userID)"
        do {
            let encoded = try JSONEncoder().encode(localForgottenCards)
            UserDefaults.standard.set(encoded, forKey: key)
            print("💾 Saved forgotten cards for user \(userID)")
        } catch {
            print("❌ Failed to encode forgotten cards: \(error)")
        }
    }

    // Update card status (remembered / not remembered)
    func updateCardStatus(cardID: String, remembered: Bool, stackID: String) {
        if localForgottenCards[stackID] == nil {
            localForgottenCards[stackID] = []
        }

        if remembered {
            localForgottenCards[stackID]?.remove(cardID)
        } else {
            localForgottenCards[stackID]?.insert(cardID)
        }
        
        print("📝 Updating card status for cardID: \(cardID), remembered: \(remembered), stackID: \(stackID)")
        print("Saved: \(localForgottenCards)")

        save()
    }

    // Get forgotten cards to review
    func getForgottenCards(from allCards: [Card], for stackID: String) -> [Card] {
        let ids = localForgottenCards[stackID] ?? []
        return allCards.filter { ids.contains($0.id) }
    }

    // Optional: Clear forgotten cards (e.g. on logout)
    func clear() {
        localForgottenCards = [:]
        save()
    }
}
