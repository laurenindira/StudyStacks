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

    @StateObject var swipeVM: SwipeableCardsViewModel
    @ObservedObject var forgottenCardsVM: ForgottenCardsViewModel

    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    @State private var forgottenCount: Int = 0
    
    private let swipeThreshold: CGFloat = 100.0
    private let rotationFactor: Double = 35.0
    
    var card: Card
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
//                let reversedIndices = Array(swipeVM.unswipedForgottenCards.indices).reversed()
                ZStack {
                    ForEach(Array(swipeVM.unswipedForgottenCards.enumerated()), id: \.element.id) { index, card in
                        let isTopCard = index == 0
                        let isSecondCard = index == 1
                        let card = swipeVM.unswipedForgottenCards[index]

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
        .onAppear {
            if let userID = auth.user?.id {
                forgottenCardsVM.load(for: userID)
                let forgottenCards = forgottenCardsVM.getForgottenCards(from: stack.cards, for: stack.id)
                swipeVM.setupForgottenCards(forgottenCards)
                print("ForgottenCardStackView appeared. Loaded \(forgottenCards.count) forgotten cards.")
            } else {
                print("No user ID found.")
            }
        }
    }
    
    // functions
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
                        dragState = .zero
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
        card: forgottenCards[0],
        stack: stack
    )
    .environmentObject(AuthViewModel())
    .environmentObject(StackViewModel())
    .environmentObject(ForgottenCardsViewModel())
}
