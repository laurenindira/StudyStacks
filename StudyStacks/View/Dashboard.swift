//
//  DashboardView.swift
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
                VStack {
                    
                    Text("This is a dashboard")
                    
                    Text("\(auth.user?.displayName ?? "this user") has a \(String(auth.user?.currentStreak ?? 0)) day streak")
                    
                  Text("Points: \(currentPoints)")
                    .font(.title)
                    .padding()

                    Button {
                        Task {
                            await auth.signOut()
                        }
                    } label: {
                        GeneralButton(placeholder: "Sign Out", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                    }
                    .padding(.top, 20)
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
                    if let currentUser = auth.user {
                        await friendVM.fetchFriends(userID: currentUser.id)
                        await friendVM.fetchFriendRequests(userID: currentUser.id)
                    }
                    await stackVM.fetchPublicStacks()
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
