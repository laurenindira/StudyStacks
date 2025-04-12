//
//  ContentView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

enum Page {
    case dashboard
    case profile
    case library
}

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    @AppStorage("isSignedIn") var isSignedIn = false

    @State private var selectedPage: Page = .dashboard

    var body: some View {
        Group {
            if !isSignedIn {
                SplashView()
            } else {
                TabView(selection: $selectedPage) {
                    Dashboard()
                        .tabItem {
                            Label("Dashboard", systemImage: "rectangle.stack.fill")
                        }
                        .tag(Page.dashboard)

                    ProfileView()
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                        .tag(Page.profile)

                    LibraryView()
                        .tabItem {
                            Label("Library", systemImage: "book.closed.fill")
                        }
                        .tag(Page.library)
                }
                .environmentObject(auth)
                .environmentObject(stackVM)
            }
        }
    }

    // Custom button for bottom nav — no longer used but kept here in case you want to bring it back later
    @ViewBuilder
    private func bottomNavButton(label: String, systemImage: String, page: Page) -> some View {
        Button(action: {
            selectedPage = page
        }) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(selectedPage == page ? Color.accentColor : .gray)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
