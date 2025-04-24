//
//  CardStackView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/8/25.
//
//  medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8

import SwiftUI


struct CardStackView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @Environment(\.dismiss) var dismiss

    @ObservedObject var swipeVM: SwipeableCardsViewModel

    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    @State private var showingPointsEarned = false
    @State private var pointsEarned = 0
    @State private var pointBadgeID: String? = nil
    @State private var showPointBadgePopup: Bool = false

    private let swipeThreshold: CGFloat = 100.0
    private let rotationFactor: Double = 35.0

    var card: Card
    var stack: Stack

    var body: some View {
        VStack {
            HStack {
                Text(stack.title)
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

            if swipeVM.unswipedCards.isEmpty {
                VStack {
                    Spacer()

                    if showingPointsEarned {
                        Text("+\(pointsEarned) points!")
                            .font(.title)
                            .foregroundColor(.green)
                            .padding()
                            .transition(.scale)
                    }

                    Text("No Cards Left")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()

                    Button(action: {
                        pointsEarned = swipeVM.originalCards.count
                        showingPointsEarned = true

                        Task {
                            PointsManager.shared.addPoints(points: pointsEarned) { badgeID in
                                if let badgeID = badgeID {
                                    DispatchQueue.main.async {
                                        pointBadgeID = badgeID
                                        showPointBadgePopup = true
                                    }
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showingPointsEarned = false
                                swipeVM.reset()
                            }
                        }
                    }) {
                        GeneralButton(
                            placeholder: "Reset (+\(swipeVM.originalCards.count) pts)",
                            backgroundColor: Color.prim,
                            foregroundColor: Color.white,
                            isSystemImage: false)
                    }
                    .padding(.horizontal, 80)
                }
                .animation(.easeInOut, value: showingPointsEarned)
            } else {
                let reversedIndices = Array(swipeVM.unswipedCards.indices).reversed()

                ZStack(alignment: .top) {
                    ForEach(reversedIndices, id: \.self) { index in
                        let isTopCard = index == reversedIndices.last
                        let isSecondCard = index == swipeVM.unswipedCards.indices.dropLast().last
                        let card = swipeVM.unswipedCards[index]

                        CardView(
                            presenter: FlipCardPresenter(),
                            card: card,
                            stack: Stack(id: "", title: "", description: "", creator: "", creatorID: "", creationDate: Date(), tags: [], cards: [], isPublic: false),
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

                                        Task {
                                            if let badgeID = await auth.updateStreakAndCheckForBadge() {
                                                pointBadgeID = badgeID
                                                showPointBadgePopup = true
                                            }
                                        }

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
                .frame(width: 340, height: 524)
            }

            Spacer()
            
            //remember it section
            VStack {
                Spacer()

                HStack {
                    Button(action: {}) {
                        // TODO: Add thumbs-down action, save to firebase
                        Image(systemName: "hand.thumbsdown.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                    }

                    Text("remember it?")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(.horizontal)

                    Button(action: {}) {
                        // TODO: Add thumbs-up action, save to firebase
                        Image(systemName: "hand.thumbsup.circle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.green)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if showPointBadgePopup, let badgeID = pointBadgeID {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    BadgePopupView(badgeID: badgeID) {
                        showPointBadgePopup = false
                        pointBadgeID = nil
                    }
                }
                .zIndex(1)
            }
        }
        
    }

}

#Preview {
    CardStackView(
        swipeVM: SwipeableCardsViewModel(cards: [
            Card(id: "1", front: "What is Swift?", back: "A programming language by Apple."),
            Card(id: "2", front: "What is Xcode?", back: "An IDE for Apple platforms.")
        ]),
        card: Card(id: "1", front: "agile methodologies", back: "scrum"),
        stack: Stack(
            id: "1",
            title: "bj class",
            description: "project management",
            creator: "jane",
            creatorID: "",
            creationDate: Date(),
            tags: ["cs"],
            cards: [],
            isPublic: true
        )
    )
    .environmentObject(AuthViewModel())
    .environmentObject(StackViewModel())
}
