//
//  AddFriendsView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/26/25.
//

import SwiftUI

struct AddFriendsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading) {
                    //HEADING
                    Text("Add Friend")
                        .customHeading(.title)
                    Text("Add your friends via email")
                    
                    //SEARCH
                    SearchBar(searchText: searchText)
                    
                    //SEARCH RESULTS
                    //TODO: add list of potential friends based on search results
                    
                }
                .padding()
            }
        }
    }
}

#Preview {
    AddFriendsView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
