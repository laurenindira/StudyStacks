//
//  ContentView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    @AppStorage("isSignedIn") var isSignedIn = false

    var body: some View {
        Group {
            if !isSignedIn {
                SplashView()
                    .environmentObject(auth)
                    .environmentObject(stackVM)
                    .environmentObject(friendVM)
            } else {
                TabView {
                    Dashboard()
                        .environmentObject(auth)
                        .environmentObject(stackVM)
                        .environmentObject(friendVM)
                        .tabItem {
                            Label("Dashboard", systemImage: "rectangle.stack.fill")
                        }

                    ProfileView()
                        .environmentObject(auth)
                        .environmentObject(stackVM)
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }

                    LibraryView()
                        .environmentObject(auth)
                        .environmentObject(stackVM)
                        .tabItem {
                            Label("Library", systemImage: "square.stack.3d.up.fill")
                        }
                    LeaderboardView()
                        .environmentObject(auth)
                        .environmentObject(stackVM)
                        .environmentObject(friendVM)
                        .tabItem {
                            Label("Leaderboard", systemImage: "trophy")
                        }
                }
            }
        }
    }

    // Custom button for bottom nav — no longer used but kept here in case you want to bring it back later
    @ViewBuilder
    private func bottomNavButton(label: String, systemImage: String, page: Int) -> some View {
        Button(action: {
            // Placeholder action; selectedPage removed
        }) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.gray) // default appearance
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
