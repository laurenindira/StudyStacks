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

    @ObservedObject var swipeVM: SwipeableCardsViewModel
    @ObservedObject var forgottenCardsVM: ForgottenCardsViewModel

    @State private var isFlippingCard = false
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
                    
                    Text("No Cards Left")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                    
                    NavigationLink(destination: StackDetailView(stack: stack)) {
                        GeneralButton(
                            placeholder: "Return to Main",
                            backgroundColor: Color.prim,
                            foregroundColor: Color.white,
                            isSystemImage: false
                        )
                    }
                    .padding(.horizontal, 80)
                }
            } else {
                let reversedIndices = Array(swipeVM.unswipedCards.indices).reversed()
                
                ZStack(alignment: .top) {
                    ForEach(reversedIndices, id: \.self) { index in
                        let isTopCard = index == reversedIndices.last
                        let isSecondCard = index == swipeVM.unswipedCards.indices.dropLast().last
                        let card = swipeVM.unswipedCards[index]
                        
                        CardView(
                            presenter: FlipCardPresenter(),
                            isFlipping: $isFlippingCard,
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
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if isTopCard && !isFlippingCard {
                                        dragState = gesture.translation
                                    }
                                }
                                .onEnded { _ in
                                    if isTopCard && !isFlippingCard {
                                        if abs(dragState.width) > swipeThreshold {
                                            let direction: CardView.SwipeDirection = dragState.width > 0 ? .right : .left
                                            let remembered = direction == .right

                                            print("🧠 Swiped \(remembered ? "REMEMBERED" : "FORGOTTEN") → \(card.front)")

                                            withAnimation(.easeOut(duration: 0.5)) {
                                                dragState.width = dragState.width > 0 ? 1000 : -1000
                                            }

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                if (auth.user?.id) != nil {
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
                    Button(action: {
                        // TODO: Add thumbs-down action, save to firebase
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
                        // TODO: Add thumbs-up action, save to firebase
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
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("📦 CardStackView appeared for stack \(stack.id)")
            if let userID = auth.user?.id {
                print("✅ User already set: \(userID)")
                forgottenCardsVM.load(for: userID)
            } else {
                print("⏳ Waiting for user...")
            }
        }
        .onChange(of: auth.user?.id) {
            if let userID = auth.user?.id {
                print("✅ User ID now available (onChange): \(userID)")
                forgottenCardsVM.load(for: userID)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            loadForgottenCards()
        }
    }

    private func loadForgottenCards() {
        if let userID = auth.user?.id {
            forgottenCardsVM.load(for: userID)
            let forgotten = forgottenCardsVM.getForgottenCards(from: stack.cards, for: stack.id)
            forgottenCount = forgotten.count
            print("🧠 Forgotten cards loaded: \(forgottenCount)")
        } else {
            print("⚠️ No user ID available")
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
        lastStudyDate: Date()
    )

    return CardStackView(
        swipeVM: mockSwipeVM,
        forgottenCardsVM: mockForgottenVM,
        card: mockCards.first!,
        stack: mockStack
    )
    .environmentObject(mockAuth)
    .environmentObject(StackViewModel())
}



//#Preview {
//    CardStackView(
//        swipeVM: SwipeableCardsViewModel(cards: [
//            Card(id: "1", front: "What is Swift?", back: "A programming language by Apple."),
//            Card(id: "2", front: "What is Xcode?", back: "An IDE for Apple platforms.")
//        ]),
//        forgottenCardsVM: ForgottenCardsViewModel(), card: Card(id: "1", front: "agile methodologies", back: "scrum"),
//        stack: Stack(
//            id: "1",
//            title: "bj class",
//            description: "project management",
//            creator: "jane",
//            creatorID: "",
//            creationDate: Date(),
//            tags: ["cs"],
//            cards: [],
//            isPublic: true
//        )
//    )
//    .environmentObject(AuthViewModel())
//    .environmentObject(StackViewModel())
//}
