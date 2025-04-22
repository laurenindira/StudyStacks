//
//  SwipeableCardsView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/10/25.
//
// medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8

import SwiftUI

class SwipeableCardsViewModel: ObservableObject {
    @Published var originalCards: [Card] = []
    @Published var unswipedCards: [Card] = []
    @Published var swipedCards: [Card] = []
    @Published var unswipedForgottenCards: [Card] = []
    @Published var swipedForgottenCards: [Card] = []


    init(cards: [Card]) {
        self.originalCards = cards
        self.unswipedCards = cards
        self.swipedCards = []
        self.unswipedForgottenCards = []
        self.swipedForgottenCards = []
    }

    @MainActor
    func removeTopCard() {
        if !unswipedCards.isEmpty {
            let removed = unswipedCards.removeFirst()
            swipedCards.append(removed)
            print("🗑 removed:", removed.front, "| left:", unswipedCards.map(\.front))
        }
    }
    
    func setupForgottenCards(_ cards: [Card]) {
        self.unswipedForgottenCards = cards
    }
    
    func removeTopForgottenCard() {
        if !unswipedForgottenCards.isEmpty {
            guard let card = unswipedForgottenCards.first else { return }
            unswipedForgottenCards.removeFirst()
            swipedForgottenCards.append(card)
        }
    }

    func updateTopCardSwipeDirection(_ direction: CardView.SwipeDirection) {
        if !unswipedCards.isEmpty {
            print("Swiped \(direction == .right ? "Remember ✅" : "Don't Remember ❌")")
        }
    }

    func reset() {
        unswipedCards = originalCards
        swipedCards = []
    }
}
