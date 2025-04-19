//
//  CardStackView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/8/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

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

                                        // STREAK LOGIC
                                        if let user = auth.user {
                                            let calendar = Calendar.current
                                            let now = Date()
                                            if let last = user.lastStudyDate {
                                                if !calendar.isDateInToday(last) {
                                                    // Not studied today
                                                    let didStudyYesterday = calendar.isDateInYesterday(last)
                                                    let newStreak = didStudyYesterday ? user.currentStreak + 1 : 1

                                                    auth.user?.currentStreak = newStreak
                                                    auth.user?.longestStreak = max(newStreak, user.longestStreak)
                                                    auth.user?.lastStudyDate = now

                                                    Task {
                                                        try? await Firestore.firestore().collection("users").document(user.id).updateData([
                                                            "currentStreak": newStreak,
                                                            "longestStreak": max(newStreak, user.longestStreak),
                                                            "lastStudyDate": Timestamp(date: now)
                                                        ])
                                                        print("Streak updated: \(newStreak)")

                                                        checkStreakBadge(userID: user.id, streak: newStreak) { badgeID in
                                                            if let badgeID = badgeID {
                                                                DispatchQueue.main.async {
                                                                    pointBadgeID = badgeID
                                                                    showPointBadgePopup = true
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                // No streak yet
                                                auth.user?.currentStreak = 1
                                                auth.user?.longestStreak = max(1, user.longestStreak)
                                                auth.user?.lastStudyDate = now

                                                Task {
                                                    try? await Firestore.firestore().collection("users").document(user.id).updateData([
                                                        "currentStreak": 1,
                                                        "longestStreak": max(1, user.longestStreak),
                                                        "lastStudyDate": Timestamp(date: now)
                                                    ])
                                                    print("First streak started")

                                                    checkStreakBadge(userID: user.id, streak: 1) { badgeID in
                                                        if let badgeID = badgeID {
                                                            DispatchQueue.main.async {
                                                                pointBadgeID = badgeID
                                                                showPointBadgePopup = true
                                                            }
                                                        }
                                                    }
                                                }
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

            VStack {
                Spacer()

                HStack {
                    Button(action: {}) {
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
    private func checkStreakBadge(userID: String, streak: Int, completion: @escaping (String?) -> Void) {
        let milestones: [Int: String] = [
            5: "5_Streak",
            15: "15_Streak",
            30: "30_Streak"
        ]

        guard let user = AuthViewModel.shared.user else {
            completion(nil)
            return
        }

        guard let badgeID = milestones[streak], !user.earnedBadges.contains(badgeID) else {
            completion(nil)
            return
        }

        var updatedBadges = user.earnedBadges
        updatedBadges.append(badgeID)

        Task {
            do {
                try await Firestore.firestore().collection("users").document(userID).updateData([
                    "earnedBadges": updatedBadges
                ])
                AuthViewModel.shared.user?.earnedBadges = updatedBadges
                print("✅ Awarded streak badge: \(badgeID)")
                completion(badgeID)
            } catch {
                print("❌ Failed to award streak badge: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

}
