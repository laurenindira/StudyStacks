//
//  CardStackView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/8/25.
//
// medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8

import SwiftUI

struct CardStackView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel

    @ObservedObject var swipeVM: SwipeableCardsViewModel

    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    
    private let swipeThreshold: CGFloat = 100.0
    private let rotationFactor: Double = 35.0

    var body: some View {
        VStack {
            if swipeVM.unswipedCards.isEmpty {
                VStack {
                    Text("No Cards Left")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Button(action: swipeVM.reset) {
                        Text("Reset")
                            .font(.headline)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                let reversedIndices = Array(swipeVM.unswipedCards.indices).reversed()
                
                ZStack {
                    ForEach(reversedIndices, id: \.self) { index in
                        let isTopCard = index == reversedIndices.last
                        let isSecondCard = index == swipeVM.unswipedCards.indices.dropLast().last
                        let card = swipeVM.unswipedCards[index]
                        
                        CardView(
                            presenter: FlipCardPresenter(),
                            card: card,
                            stack: Stack(id: "", title: "", description: "", creator: "", creationDate: Date(), tags: [], cards: [], isPublic: false),
                            dragOffset: dragState,
                            isTopCard: isTopCard,
                            isSecondCard: isSecondCard
                        )
                        .frame(width: 340, height: 524)
                        .zIndex(isTopCard ? 1 : 0)
                        .offset(x: isTopCard ? dragState.width : 0)
                        .rotationEffect(.degrees(isTopCard ? Double(dragState.width) / rotationFactor : 0))
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if isTopCard {
                                        dragState = gesture.translation
                                    }
                                }
                                .onEnded { _ in
                                    if abs(dragState.width) > swipeThreshold {
                                        let direction: CardView.SwipeDirection = dragState.width > 0 ? .right : .left
                                        swipeVM.updateTopCardSwipeDirection(direction)

                                        withAnimation(.easeOut(duration: 0.5)) {
                                            dragState.width = dragState.width > 0 ? 1000 : -1000
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            swipeVM.removeTopCard()
                                            dragState = .zero
                                        }
                                    } else {
                                        withAnimation {
                                            dragState = .zero
                                        }
                                    }
                                }
                        )
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    CardStackView(swipeVM: SwipeableCardsViewModel(cards: [
        Card(id: "1", front: "What is Swift?", back: "A programming language by Apple."),
        Card(id: "2", front: "What is Xcode?", back: "An IDE for Apple platforms.")
    ]))
    .environmentObject(AuthViewModel())
    .environmentObject(StackViewModel())
}
