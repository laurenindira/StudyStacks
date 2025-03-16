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
    
    @State private var searchText: String = ""
    @State private var selectedCategory: String? = nil
    @State private var selectedCreator: String? = nil
    
    let categories = ["English", "Chemistry", "Physics", "Computer Science", "Spanish", "Psychology", "Geography"]
    let creatorFilters = ["Me", "Friends", "Anyone"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // TITLE
                    Text("All Stacks")
                        .customHeading(.title)
                    
                    // SEARCH
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
                    
                    // FILTERS
                    Text("Filters")
                        .font(.headline)
                    
                    HStack {
                        // Category Filter
                        Menu {
                            ForEach(categories, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category)
                                }
                            }
                            Button(action: { selectedCategory = nil }) {
                                Text("Clear Category")
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory ?? "Category")
                                    .foregroundStyle(Color.primary)
                                Image(systemName: "chevron.down")
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.surface))
                        }
                        
                        // Creator Filter
                        Menu {
                            ForEach(creatorFilters, id: \.self) { creator in
                                Button(action: { selectedCreator = creator }) {
                                    Text(creator)
                                }
                            }
                            Button(action: { selectedCreator = nil }) {
                                Text("Clear Filter")
                            }
                        } label: {
                            HStack {
                                Text(selectedCreator ?? "Made By")
                                    .foregroundStyle(Color.primary)
                                Image(systemName: "chevron.down")
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.surface))
                        }
                    }
                    
                    // LIST OF CARDS
                    if searchResults.isEmpty {
                        ErrorView(errorMessage: "Womp womp... Looks like there aren't any stacks here right now :/", imageName: "empty-box", isSystemImage: false)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(searchResults, id: \.self) { stack in
                            NavigationLink {
                                // link to overview
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
            .onAppear {
                Task {
                    if let userID = auth.user?.id {
                        await stackVM.fetchUserStacks(for: userID)
                    }
                    await stackVM.fetchPublicStacks()
                }
            }
            .refreshable {
                await refresh()
            }
        }
    }
    
    var searchResults: [Stack] {
        stackVM.combinedStacks.filter { stack in
            let matchesSearch = searchText.isEmpty || stack.title.localizedCaseInsensitiveContains(searchText) ||
                stack.description.localizedCaseInsensitiveContains(searchText) || stack.creator.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == nil || stack.tags.contains(selectedCategory!)
            
            let matchesCreator: Bool
            if let selectedCreator = selectedCreator {
                switch selectedCreator {
                case "Me":
                    matchesCreator = stack.creatorID == auth.user?.id
                case "Friends":
                    matchesCreator = stack.creatorID != auth.user?.id && stack.isPublic
                case "Anyone":
                    matchesCreator = true
                default:
                    matchesCreator = true
                }
            } else {
                matchesCreator = true
            }
            
            return matchesSearch && matchesCategory && matchesCreator
        }
    }
    
    private func refresh() async {
        await stackVM.fetchPublicStacks()
    }
}

#Preview {
    LibraryView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
