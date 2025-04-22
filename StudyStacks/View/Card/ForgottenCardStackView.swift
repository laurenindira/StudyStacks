//
//  ForgottenCardStackView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/2/25.
//

import SwiftUI

struct ForgottenCardStackView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @Environment(\.dismiss) var dismiss

    @ObservedObject var swipeVM: SwipeableCardsViewModel
    @ObservedObject var forgottenCardsVM: ForgottenCardsViewModel

    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    @State private var forgottenCount: Int = 0
    @State private var didLoadForgotten = false
    
    private let swipeThreshold: CGFloat = 100.0
    private let rotationFactor: Double = 35.0
    
//    var card: Card
    var stack: Stack

    var body: some View {
        VStack {
            // deck title and close button
            HStack {
                Text("Review Forgotten")
                    .customHeading(.title2)
                    .bold()
                    .padding(.leading, 20)

                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding()
                }
            }
            .padding(.top, 10)

            Spacer()
            
            // when all cards gone, return back to stack overview page
            if swipeVM.unswipedForgottenCards.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    Text("No Forgotten Cards Left")
                        .font(.title2)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                let reversedIndices = Array(swipeVM.unswipedForgottenCards.indices).reversed()
                ZStack {
                    ForEach(Array(swipeVM.unswipedCards.enumerated()).reversed(),
                            id: \.element.id) { tuple in
                        let index        = tuple.offset
                        let card         = tuple.element
                        let isTopCard    = index == swipeVM.unswipedCards.count - 1
                        let isSecondCard = index == swipeVM.unswipedCards.count - 2
//                    ForEach(reversedIndices, id: \.self) { index in
//                        let isTopCard = index == swipeVM.unswipedForgottenCards.indices.last
//                        let isSecondCard = index == swipeVM.unswipedForgottenCards.indices.dropLast().last
//                        let card = swipeVM.unswipedForgottenCards[index]

                        CardView(
                            presenter: FlipCardPresenter(),
                            card: card,
                            stack: stack,
                            dragOffset: dragState,
                            isTopCard: isTopCard,
                            isSecondCard: isSecondCard
                        )
                        .frame(width: 340, height: 524)
                        .zIndex(isTopCard ? 1 : 0)
                        .offset(x: isTopCard ? dragState.width : 0)
                        .rotationEffect(.degrees(isTopCard ? Double(dragState.width) / rotationFactor : 0))
                        .shadow(
                            color: dragState.width > 0 ? Color.green.opacity(0.3) :
                                   dragState.width < 0 ? Color.red.opacity(0.3) : Color.clear,
                            radius: isTopCard ? 10 : 0,
                            x: 0, y: 5
                        )
                        .gesture(swipingAction(for: card, isTopCard: isTopCard))
                    }
                }
                .frame(width: 340, height: 524)
            }

            Spacer()
            
            // remember it section
            if !swipeVM.unswipedForgottenCards.isEmpty {
                VStack {
                    Spacer()

                    HStack {
                        Button(action: {
                            handleButtonSwipe(direction: .left)
                        }) {
                            Image(systemName: "hand.thumbsdown.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.red)
                        }

                        Text("remember it?")
                            .font(.body)
                            .foregroundColor(.black)
                            .padding(.horizontal)

                        Button(action: {
                            handleButtonSwipe(direction: .right)
                        }) {
                            Image(systemName: "hand.thumbsup.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        // In ForgottenCardStackView.swift
        .onAppear {
            print("🔄 ForgottenCardStackView appeared for stack: \(stack.id)")
            
            // Check the current state
            print("🔄 Initial forgotten cards count: \(swipeVM.unswipedForgottenCards.count)")
            
            // If we don't have any cards yet, force a reload
            if swipeVM.unswipedForgottenCards.isEmpty {
                print("🔄 No forgotten cards loaded yet, forcing reload...")
                loadForgottenCards()
                
                // Double check
                print("🔄 After reload: \(swipeVM.unswipedForgottenCards.count) forgotten cards")
            }
            
            didLoadForgotten = true
        }
//        .onAppear {
//            print("🔄 ForgottenCardStackView appeared for stack: \(stack.id)")
//            
//            // Always attempt to load forgotten cards when the view appears
//            loadForgottenCards()
//            
//            // Check if we successfully loaded cards
//            print("🔄 After loading, unswipedForgottenCards count: \(swipeVM.unswipedForgottenCards.count)")
//            didLoadForgotten = true
//        }
    }
    
    // functions
    private func loadForgottenCards() {
        print("🔍 Beginning loadForgottenCards()")
        
        if let userID = auth.user?.id {
            print("🔍 User ID found: \(userID)")
            
            // Force a fresh load from UserDefaults
            forgottenCardsVM.load(for: userID)
            
            print("🔍 Stack ID: \(stack.id)")
            print("🔍 Total cards in stack: \(stack.cards.count)")
            
            // Get all forgotten card IDs for this stack
            let forgottenCardIDs = forgottenCardsVM.localForgottenCards[stack.id] ?? Set<String>()
            print("🔍 Found \(forgottenCardIDs.count) forgotten card IDs: \(forgottenCardIDs)")
            
            // Match these IDs with actual cards
            let forgottenCards = stack.cards.filter { forgottenCardIDs.contains($0.id) }
            print("🔍 Filtered down to \(forgottenCards.count) actual forgotten cards")
            
            // Print each forgotten card for debugging
            for card in forgottenCards {
                print("🔍 Forgotten card: \(card.id) - \(card.front)")
            }
            
            // Setup the swipe view model with these cards
            swipeVM.setupForgottenCards(forgottenCards)
            forgottenCount = forgottenCards.count
            
            // Verify setup worked
            print("🔍 After setup: unswipedForgottenCards count = \(swipeVM.unswipedForgottenCards.count)")
        } else {
            print("⚠️ No user ID available")
        }
    }
//    private func loadForgottenCards() {
//        if let userID = auth.user?.id {
//            forgottenCardsVM.load(for: userID)
//            
//            // Ensure we access the correct stack ID
//            print("🔍 Loading forgotten cards for stack ID: \(stack.id)")
//            
//            // Get the forgotten card IDs for this stack
//            let forgottenCardIDs = forgottenCardsVM.localForgottenCards[stack.id] ?? Set<String>()
//            print("🔍 Found forgotten card IDs: \(forgottenCardIDs)")
//            
//            // Filter the stack's cards to only include those in the forgotten set
//            let forgottenCards = stack.cards.filter { forgottenCardIDs.contains($0.id) }
//            print("🔍 Filtered forgotten cards count: \(forgottenCards.count)")
//            
//            // Debugging the content of cards
//            for card in forgottenCards {
//                print("🧠 Forgotten card: \(card.id) - \(card.front)")
//            }
//            
//            // Set up the forgotten cards in the swipe view model
//            swipeVM.setupForgottenCards(forgottenCards)
//            forgottenCount = forgottenCards.count
//        } else {
//            print("⚠️ No user ID available")
//        }
//    }
//    private func loadForgottenCards() {
//        if let userID = auth.user?.id {
//            forgottenCardsVM.load(for: userID)
//            let forgotten = forgottenCardsVM.getForgottenCards(from: stack.cards, for: stack.id)
//            swipeVM.setupForgottenCards(forgotten)
//            forgottenCount = forgotten.count
//            print("🧠 Forgotten cards loaded: \(forgottenCount)")
//        } else {
//            print("⚠️ No user ID available")
//        }
//    }
    
    private func handleButtonSwipe(direction: CardView.SwipeDirection) {
        guard let topCard = swipeVM.unswipedForgottenCards.first else { return }

        let remembered = direction == .right
        print("Button tapped → \(remembered ? "REMEMBERED" : "FORGOTTEN") for \(topCard.front)")

        if let _ = auth.user?.id {
            forgottenCardsVM.updateCardStatus(
                cardID: topCard.id,
                remembered: remembered,
                stackID: stack.id
            )
        }
        swipeVM.removeTopForgottenCard()
    }
    
    private func getShadowColor(for offset: CGSize) -> Color {
        if offset.width > 0 {
            return Color.green.opacity(0.3)
        } else if offset.width < 0 {
            return Color.red.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    private func swipingAction(for card: Card, isTopCard: Bool) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                if isTopCard {
                    dragState = gesture.translation
                }
            }
            .onEnded { _ in
                guard isTopCard else { return }

                if abs(dragState.width) > swipeThreshold {
                    let direction: CardView.SwipeDirection = dragState.width > 0 ? .right : .left
                    let remembered = direction == .right

                    print("Swiped \(remembered ? "REMEMBERED" : "FORGOTTEN") → \(card.front)")

                    withAnimation(.easeOut(duration: 0.5)) {
                        dragState.width = dragState.width > 0 ? 1000 : -1000
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let _ = auth.user?.id {
                            forgottenCardsVM.updateCardStatus(
                                cardID: card.id,
                                remembered: remembered,
                                stackID: stack.id
                            )
                        }
                        swipeVM.removeTopForgottenCard()
                        withAnimation {
                            dragState = .zero
                        }
                    }
                } else {
                    withAnimation {
                        dragState = .zero
                    }
                }
            }
    }
}



#Preview {
    let forgottenCards = [
        Card(id: "1", front: "What is Swift??", back: "A language by Apple"),
        Card(id: "2", front: "What is Xcode?", back: "An IDE for Apple platforms"),
        Card(id: "3", front: "What is UIKit?", back: "A UI framework"),
        Card(id: "4", front: "What is SwiftUI?", back: "A declarative UI framework"),
        Card(id: "5", front: "What is Combine?", back: "A reactive programming framework")
    ]

    let stack = Stack(
        id: "stack1",
        title: "iOS Flashcards",
        description: "Learn Apple development",
        creator: "dev_girl",
        creatorID: "user1",
        creationDate: .now,
        tags: ["swift", "ios"],
        cards: forgottenCards,
        isPublic: true
    )

    let swipeVM = SwipeableCardsViewModel(cards: forgottenCards)
    swipeVM.setupForgottenCards(forgottenCards)

    let forgottenVM = ForgottenCardsViewModel()
    forgottenVM.localForgottenCards = [
        "stack1": Set(forgottenCards.map { $0.id })
    ]

    return ForgottenCardStackView(
        swipeVM: swipeVM,
        forgottenCardsVM: forgottenVM,
//        card: forgottenCards[2],
        stack: stack
    )
    .environmentObject(AuthViewModel())
    .environmentObject(StackViewModel())
    .environmentObject(ForgottenCardsViewModel())
}


