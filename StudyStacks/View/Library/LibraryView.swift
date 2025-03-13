//
//  LibraryView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/12/25.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    
    @State var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    //TITLE
                    Text("All Stacks")
                        .customHeading(.title)
                    
                    //SEARCH
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.callout)
                            .foregroundStyle(Color.stacksgray)
                        TextField("Looking for something specific?", text: $searchText)
                            .foregroundStyle(Color.secondaryText)
                        if !searchText.isEmpty {
                            Button(action: { self.searchText = ""}) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.stacksgray)
                            }
                        }
                    }
                    .padding(10)
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.surface)
                    }
                    
                    //LIST OF CARDS
                    if searchResults.isEmpty {
                        //TODO: custom error message
                        Text("womp womp no stacks")
                    } else {
                        ForEach(searchResults, id: \.self) { stack in
                            //TODO: add in check for if card is favorite
                            NavigationLink {
                                //link to overview
                            } label: {
                                StackCardView(stack: stack, isFavorite: true)
                            }
                            .buttonStyle(.plain)
                        }
                        
                    }
                }
                .padding()
            }
            .animation(.easeInOut, value: searchResults)
            //TODO: change how often this loads
            .onAppear {
                Task {
                    if let userID = auth.user?.id {
                        await stackVM.fetchUserStacks(for: userID)
                    }
                    await stackVM.fetchPublicStacks()
                }
            }
        }
    }
    
    var searchResults: [Stack] {
        if searchText.isEmpty {
            return stackVM.combinedStacks
        } else {
            //TODO: fix filter so that it can search for tags as well
            return stackVM.combinedStacks.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.creator.localizedCaseInsensitiveContains(searchText) || $0.tags.contains(searchText.lowercased())
            }
        }
    }
}

#Preview {
    LibraryView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
