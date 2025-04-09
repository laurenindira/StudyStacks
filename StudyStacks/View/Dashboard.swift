//
//  Dashboard.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    
    @State var creatingStack: Bool = false
   
    @AppStorage("userPoints") var currentPoints: Int = 0
  
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Welcome back, \(auth.user?.displayName ?? "user")!")
                        .font(.customHeading(.title2))

                    // Weekly Progress Card
                    WeeklyProgressView(rank: "1st", cardsStudied: currentPoints)

                    // Streaks + Cards Studied
                    HStack(alignment: .center, spacing: 16) {
                        StatCardView(number: 6, text: "day streak")
                        StatCardView(number: 2345, text: "cards studied lifetime")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }

            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button(action: { creatingStack = true }) {
                            Image(systemName: "plus.circle")
                        }
                        NavigationLink {
                            FriendManagerView()
                        } label: {
                            if friendVM.receivedRequests.isEmpty {
                                Image(systemName: "bell")
                            } else {
                                Image(systemName: "bell.badge")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $creatingStack) {
                NewStackView()
            }
            .onAppear {
                Task {
                    //TODO: modify this to only load once on app launch instead of every time you go to dashboard
                    await friendVM.fetchFriends(userID: auth.user?.id)
                    await friendVM.fetchFriendRequests(userID: auth.user?.id)
                    //await stackVM.fetchPublicStacks()
                }
            }
            .padding()
        }
    
    }
}

#Preview {
    Dashboard()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
