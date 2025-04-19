//
//  BadgeGalleryView.swift
//  StudyStacks
//
//  Created by brady katler on 4/15/25.
//


import SwiftUI

struct BadgeGalleryView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedIndex: Int = 0

    let badgeIDs = [
        "1_Stack", "5_Stacks", "10_Stacks",
        "5_Points", "25_Points", "100_Points",
        "5_Streak", "15_Streak", "30_Streak"
    ]

    let badgeDescriptions: [String: String] = [
        "1_Stack": "Create your first stack.",
        "5_Stacks": "Create 5 stacks.",
        "10_Stacks": "Create 10 stacks.",
        "5_Points": "Earn 5 points.",
        "25_Points": "Earn 25 points.",
        "100_Points": "Earn 100 points.",
        "5_Streak": "Study for 5 consecutive days.",
        "15_Streak": "Study for 15 consecutive days.",
        "30_Streak": "Study for 30 consecutive days."
    ]

    var body: some View {
        VStack(spacing: 24) {
            // MARK: - Title
            HStack {
                Text("Badge Gallery")
                    .customHeading(.title)
                    .padding(.leading)
                Spacer()
            }

            Divider()
            Spacer(minLength: 40) 

            let badgeID = badgeIDs[selectedIndex]
            let userEarned = auth.user?.earnedBadges.contains(badgeID) ?? false

            // MARK: - Badge Row
            HStack(spacing: 20) {
                if selectedIndex > 0 {
                    let previousBadgeID = badgeIDs[selectedIndex - 1]
                    let earned = auth.user?.earnedBadges.contains(previousBadgeID) ?? false

                    Image(previousBadgeID)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .grayscale(earned ? 0 : 1)
                        .opacity(earned ? 0.8 : 0.3)
                } else {
                    Spacer().frame(width: 100)
                }

                Image(badgeID)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 240, height: 240)
                    .shadow(radius: 10)
                    .grayscale(userEarned ? 0 : 1)
                    .opacity(userEarned ? 1 : 0.4)

                if selectedIndex < badgeIDs.count - 1 {
                    let nextBadgeID = badgeIDs[selectedIndex + 1]
                    let earned = auth.user?.earnedBadges.contains(nextBadgeID) ?? false

                    Image(nextBadgeID)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .grayscale(earned ? 0 : 1)
                        .opacity(earned ? 0.8 : 0.3)
                } else {
                    Spacer().frame(width: 100)
                }
            }

            // MARK: - Badge Title + Description
            VStack(spacing: 8) {
                Text(badgeID.replacingOccurrences(of: "_", with: " "))
                    .font(.title)
                    .bold()

                Text(badgeDescriptions[badgeID] ?? "Unknown badge")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // MARK: - Navigation Arrows
            HStack(spacing: 60) {
                Button(action: {
                    if selectedIndex > 0 {
                        withAnimation(.easeInOut) {
                            selectedIndex -= 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                }
                .disabled(selectedIndex == 0)

                Button(action: {
                    if selectedIndex < badgeIDs.count - 1 {
                        withAnimation(.easeInOut) {
                            selectedIndex += 1
                        }
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                }
                .disabled(selectedIndex == badgeIDs.count - 1)
            }

            Spacer(minLength: 10)
        }
        .padding()
        .background(Color.white.ignoresSafeArea())
    }
}
