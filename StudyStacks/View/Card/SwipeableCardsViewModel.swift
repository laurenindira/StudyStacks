//
//  SwipeableCardsView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/10/25.
//
// medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8

import SwiftUI

class SwipeableCardsViewModel: ObservableObject {
    var originalCards: [Card]
    @Published var unswipedCards: [Card]
    @Published var swipedCards: [Card]

    init(cards: [Card]) {
        self.originalCards = cards
        self.unswipedCards = cards
        self.swipedCards = []
    }

    func removeTopCard() {
        if !unswipedCards.isEmpty {
            guard let card = unswipedCards.first else { return }
            unswipedCards.removeFirst()
            swipedCards.append(card)
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
