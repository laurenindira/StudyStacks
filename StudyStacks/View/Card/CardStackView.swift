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
    @Environment(\.dismiss) var dismiss

    @StateObject var swipeVM: SwipeableCardsViewModel
    @ObservedObject var forgottenCardsVM: ForgottenCardsViewModel

    @State private var dragState = CGSize.zero
    @State private var cardRotation: Double = 0
    @State private var forgottenCount: Int = 0
    @State private var showingPointsEarned = false
    @State private var pointsEarned = 0
    @State private var navigateToOverview = false
    
    private let swipeThreshold: CGFloat = 100.0
    private let rotationFactor: Double = 35.0
    
    var card: Card
    var stack: Stack

    var body: some View {
        VStack {
            // deck title and close button
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
            
            // when all cards gone, return back to stack overview page
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
                            PointsManager.shared.addPoints(points: pointsEarned)
                            //await auth.addPoints(pointsEarned)
                            //await auth.loadUserFromFirebase()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showingPointsEarned = false
                                navigateToOverview = true
                                swipeVM.reset()
                            }
                        }
                    }) {
                        
                        GeneralButton(
                            placeholder: "Return to Stack Overview (+\(swipeVM.originalCards.count) pts)",
                            backgroundColor: Color.prim,
                            foregroundColor: Color.white,
                            isSystemImage: false)
                    }
                    .padding(.horizontal, 80)
                    
                    Spacer()
                }
                .frame(maxHeight: .infinity)
                .animation(.easeInOut, value: showingPointsEarned)
                
            } else {
                let reversedIndices = Array(swipeVM.unswipedCards.indices).reversed()
                ZStack(alignment: .top) {
                    ForEach(swipeVM.unswipedCards.reversed(), id: \.id) { card in
                        CardView(
                            presenter: FlipCardPresenter(),
                            card: card,
                            stack: stack,
                            dragOffset: dragState,
                            isTopCard: card.id == swipeVM.unswipedCards.first?.id,
                            isSecondCard: card.id == swipeVM.unswipedCards.dropFirst().first?.id
                        )
                        .frame(width: 340, height: 524)
                        .offset(x: card.id == swipeVM.unswipedCards.first?.id ? dragState.width : 0)
                        .rotationEffect(.degrees(card.id == swipeVM.unswipedCards.first?.id
                                                 ? Double(dragState.width) / rotationFactor : 0))
                        .shadow(color: getShadowColor(for: dragState),
                                radius: card.id == swipeVM.unswipedCards.first?.id ? 10 : 0,
                                x: 0, y: 5)
                        .zIndex(card.id == swipeVM.unswipedCards.first?.id ? 1 : 0)
                        .gesture(swipingAction(for: card,
                                               isTopCard: card.id == swipeVM.unswipedCards.first?.id))
                    }
                }
                .frame(width: 340, height: 524)
            }
            Spacer()
            
            // remember it section
            if !swipeVM.unswipedCards.isEmpty {
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
        .navigationDestination(isPresented: $navigateToOverview) {
            StackDetailView(stack: stack)
        }
        .onAppear {
            print("CardStackView appeared for stack \(stack.id)")
            if let userID = auth.user?.id {
                print("User already set: \(userID)")
                forgottenCardsVM.load(for: userID)
            } else {
                print("Waiting for user...")
            }
        }
        .onChange(of: auth.user?.id) {
            if let userID = auth.user?.id {
                print("User ID now available (onChange): \(userID)")
                forgottenCardsVM.load(for: userID)
            }
        }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
//            loadForgottenCards()
//        }
    }
    
    // functions
    private func handleButtonSwipe(direction: CardView.SwipeDirection) {
        guard let topCard = swipeVM.unswipedCards.first else { return }

        let remembered = direction == .right
        print("Button tapped → \(remembered ? "REMEMBERED" : "FORGOTTEN") for \(topCard.front)")

        if let _ = auth.user?.id {
            forgottenCardsVM.updateCardStatus(
                cardID: topCard.id,
                remembered: remembered,
                stackID: stack.id
            )
        }
        swipeVM.removeTopCard()
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
                        swipeVM.removeTopCard()
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
    let mockCards = [
        Card(id: "1", front: "What is Swift?", back: "A programming language by Apple."),
        Card(id: "2", front: "What is Xcode?", back: "An IDE for Apple platforms.")
    ]

    let mockStack = Stack(
        id: "1",
        title: "bj class",
        description: "project management",
        creator: "jane",
        creatorID: "",
        creationDate: Date(),
        tags: ["cs"],
        cards: mockCards,
        isPublic: true
    )

    let mockSwipeVM = SwipeableCardsViewModel(cards: mockCards)

    let mockForgottenVM = ForgottenCardsViewModel()
    mockForgottenVM.localForgottenCards = [
        "1": ["2"]
    ]

    let mockAuth = AuthViewModel()
    mockAuth.user = User(
        id: "previewUser123",
        username: "preview_user",
        displayName: "Preview User",
        email: "preview@example.com",
        profilePicture: nil,
        creationDate: Date(),
        lastSignIn: nil,
        providerRef: "preview_provider",
        selectedSubjects: ["Math", "CS"],
        studyReminderTime: Date(),
        studentType: "College",
        currentStreak: 1,
        longestStreak: 2,
        lastStudyDate: Date(),
        points: 0,
        favoriteStackIDs: []
    )

    return NavigationStack {
        CardStackView(
            swipeVM: mockSwipeVM,
            forgottenCardsVM: mockForgottenVM,
            card: mockCards.first!,
            stack: mockStack
        )
        .environmentObject(mockAuth)
        .environmentObject(StackViewModel())
    }
}
