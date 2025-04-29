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
    @EnvironmentObject var friendVM: FriendsViewModel
    
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var selectedCreator: String = "Anyone"
    @State private var showFavoritesOnly: Bool = false
    
    @State var creatingStack: Bool = false
    
    // TODO: Revisit this later to create a consistent list of subjects across the app.
    let categories = ["All", "Accounting", "Biology", "Chemistry", "Computer Science", "English", "Geography", "History", "Physics", "Psychology", "Spanish"]
    let creatorFilters = ["Anyone", "Friends", "Me"]
    
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
                    
                    // FILTERS SECTION
                    HStack(spacing: 15) {
                        Text("Filters")
                            .font(.headline)
                        
                        // Category Filter
                        Menu {
                            ForEach(categories, id: \.self) { category in
                                Button(action: { selectedCategory = category }) {
                                    Text(category)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCategory)
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
                        } label: {
                            HStack {
                                Text(selectedCreator)
                                    .foregroundStyle(Color.primary)
                                Image(systemName: "chevron.down")
                            }
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.surface))
                        }
                        
                    }
                    
                    Toggle("Show Favorites Only", isOn: $showFavoritesOnly)
                        .padding(.horizontal)
                        .toggleStyle(SwitchToggleStyle(tint: Color.prim))
                    
                    // LIST OF CARDS
                    if searchResults.isEmpty {
                        ErrorView(errorMessage: "Womp womp... Looks like there aren't any stacks here right now :/", imageName: "empty-box", isSystemImage: false)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(searchResults, id: \.self) { stack in
                            NavigationLink {
                                StackDetailView(stack: stack)
                                    .environmentObject(stackVM)
                            } label: {
                                StackCardView(stack: stack, isFavorite: stackVM.isFavorite(stack))
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
                        await stackVM.fetchUserFavorites(for: userID)
                    }
                    await stackVM.fetchPublicStacks()
                }
            }
            .refreshable {
                await refresh()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Button(action: { creatingStack = true }) {
                            Image(systemName: "plus.circle")
                                .font(.title3)
                        }
                    }
                }
            }
            .sheet(isPresented: $creatingStack) {
                NewStackView()
            }
        }
    }
    
    var searchResults: [Stack] {
        let filteredStacks: [Stack]
        
        if searchText.isEmpty && selectedCategory == "All" && selectedCreator == "Anyone" {
            filteredStacks = stackVM.combinedStacks
        } else {
            filteredStacks = stackVM.combinedStacks.filter { stack in
                let matchesSearch = searchText.isEmpty || stack.title.localizedCaseInsensitiveContains(searchText) ||
                    stack.description.localizedCaseInsensitiveContains(searchText) || stack.creator.localizedCaseInsensitiveContains(searchText)
                
                let matchesCategory = selectedCategory == "All" || stack.tags.contains(selectedCategory)
                
                let friendIDs = friendVM.friends.map { $0.id }
                let matchesCreator = selectedCreator == "Anyone" ||
                                  (selectedCreator == "Me" && stack.creatorID == auth.user?.id) ||
                                  (selectedCreator == "Friends" && (friendIDs.contains(stack.creatorID)) && stack.isPublic)
                
                return matchesSearch && matchesCategory && matchesCreator
            }
        }
        if showFavoritesOnly {
          return filteredStacks.filter { stack in
              stackVM.favoriteStackIDs.contains(stack.id)
          }
        }
        return filteredStacks
    }
    
    private func refresh() async {
        await stackVM.fetchPublicStacks()
        if let userID = auth.user?.id {
            await stackVM.fetchUserFavorites(for: userID)
        }
    }
}

#Preview {
    LibraryView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
