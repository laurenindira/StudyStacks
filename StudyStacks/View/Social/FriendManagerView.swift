//
//  FriendManagerView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/26/25.
//

import SwiftUI

struct FriendManagerView: View {
    @State var searchText: String
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
                    Text("Requests")
                        .customHeading(.title2)
                    //TODO: add empty message
                    //TODO: add FriendRows when functions are made
                    
                    //FRIEND LIST
                    Text("My Friends")
                        .customHeading(.title2)
                    //TODO: for each with user's friends
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
        }
    }
}

#Preview {
    FriendManagerView(searchText: "")
}
