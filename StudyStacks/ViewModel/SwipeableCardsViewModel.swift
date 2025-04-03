//
//  SwipeableCardsView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/10/25.
//
// medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8

import SwiftUI

class SwipeableCardsViewModel: ObservableObject {
    private var originalCards: [Card]
    @Published var unswipedCards: [Card]
    @Published var swipedCards: [Card]
    
    @Published var forgottenCardsDeck: [Card]
    @Published var unswipedForgottenCards: [Card]
    @Published var swipedForgottenCards: [Card]

    init(cards: [Card]) {
        self.originalCards = cards
        self.unswipedCards = cards
        self.swipedCards = []
        self.forgottenCardsDeck = []
        self.unswipedForgottenCards = []
        self.swipedForgottenCards = []
    }
    
    func removeTopCard(remembered: Bool) {
        guard let topCard = unswipedCards.first else { return }

        unswipedCards.removeFirst()
        swipedCards.append(topCard)
        
        print("UNSWIPED")
        print(unswipedCards)

        if !remembered {
            forgottenCardsDeck.append(topCard)
            unswipedForgottenCards.append(topCard)
        }
    }
    
    func removeTopForgottenCard() {
        guard let topCard = unswipedForgottenCards.first else { return }
        unswipedForgottenCards.removeFirst()
        swipedForgottenCards.append(topCard)
    }

    func resetOriginalDeck() {
        unswipedCards = originalCards
        swipedCards = []
    }

    func resetForgottenDeck() {
        unswipedForgottenCards = forgottenCardsDeck
        swipedForgottenCards = []
    }

//    func removeTopCard() {
//        if !unswipedCards.isEmpty {
//            guard let card = unswipedCards.first else { return }
//            unswipedCards.removeFirst()
//            swipedCards.append(card)
//        }
//    }

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
