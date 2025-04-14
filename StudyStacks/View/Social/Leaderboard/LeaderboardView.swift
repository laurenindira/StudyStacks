//
//  LeaderboardView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/12/25.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    //HEADING
                    Text("Leaderboard")
                        .customHeading(.title)
                    Text("Let's see how you're doing this week")
                    
                    //SCORES
                    VStack {
                        ForEach(Array(leaderboardUsers.enumerated()), id: \.element.id) { (index, friend) in
                            NavigationLink {
                                PublicProfileView(friend: friend)
                            } label: {
                                LeaderboardRow(friend: friend, placement: index + 1 )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink {
                            FriendManagerView()
                        } label: {
                            Image(systemName: "person.crop.circle.badge.plus")
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    print("CURRENTLY IN USER: \(String(describing: auth.user))")
                    await stackVM.fetchPublicStacks()
                    await friendVM.fetchFriends(userID: auth.user?.id)
                    
                }
            }
        }
    }
    
    var leaderboardUsers: [Friend]  {
        var allFriends = friendVM.friends
        if let currentUser = AuthViewModel.shared.user {
            let userAsFriend = Friend(id: currentUser.id, username: currentUser.username, displayName: currentUser.displayName, email: currentUser.email, creationDate: currentUser.creationDate, currentStreak: currentUser.currentStreak, points: currentUser.points)
            allFriends.append(userAsFriend)
        }
        return allFriends.sorted { $0.points > $1.points}
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
