//
//  FriendManagerView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/26/25.
//

import SwiftUI

struct FriendManagerView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    
    @State var searchText: String = ""
    @State var addingFriends: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading) {
                    //HEADER
                    Text("Friend Manager")
                        .customHeading(.title)
                    
                    //SEARCH
                    SearchBar(searchText: searchText)
                    
                    //REQUESTS
                    VStack(alignment: .leading) {
                        Text("Requests")
                            .customHeading(.title2)
                        
                        if $friendVM.receivedRequests.isEmpty {
                            Text("No requests here!")
                                .padding()
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .background {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.surface)
                                }
                        } else {
                            ForEach(friendVM.receivedRequests, id: \.self) { request in
                                FriendRow(friend: request, isRequest: true)
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    //FRIEND LIST
                    VStack(alignment: .leading) {
                        Text("My Friends")
                            .customHeading(.title2)
                        
                        if searchResults.isEmpty {
                            //TODO: change error message image
                            ErrorView(errorMessage: "Uh oh! Looks like you haven't added any friends. You should get on that...", imageName: "magnifying", isSystemImage: false)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(searchResults, id: \.self) { friend in
                                NavigationLink {
                                    PublicProfileView(friend: friend)
                                } label: {
                                    FriendRow(friend: friend, isRequest: false)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { addingFriends = true }) {
                        Image(systemName: "person.fill.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $addingFriends) {
                AddFriendsView()
            }
            .onAppear {
                Task {
                    await stackVM.fetchPublicStacks()
                    await friendVM.fetchFriends(userID: auth.user?.id)
                    await friendVM.fetchFriendRequests(userID: auth.user?.id)
                    
                }
            }
        }
    }
    
    var searchResults: [Friend] {
        if searchText.isEmpty {
            return friendVM.friends
        } else {
            return friendVM.friends.filter { $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.username.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    FriendManagerView(searchText: "")
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
