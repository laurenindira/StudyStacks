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
    @State private var selectedCategory: String = "All"
    @State private var selectedCreator: String = "Anyone"
    
    // TODO: Revisit this later to create a consistent list of subjects across the app.
    let categories = ["All", "English", "Chemistry", "Physics", "Computer Science", "Spanish", "Psychology", "Geography"]
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
                    
                    // LIST OF CARDS
                    if searchResults.isEmpty {
                        ErrorView(errorMessage: "Womp womp... Looks like there aren't any stacks here right now :/", imageName: "empty-box", isSystemImage: false)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(searchResults, id: \.self) { stack in
                            // TODO: add in check for if card is favorite
                            NavigationLink {
                                StackDetailView(stack: stack)
                                    .environmentObject(stackVM)
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
        if searchText.isEmpty && selectedCategory == "All" && selectedCreator == "Anyone" {
            return stackVM.combinedStacks
        }
        
        return stackVM.combinedStacks.filter { stack in
            let matchesSearch = searchText.isEmpty || stack.title.localizedCaseInsensitiveContains(searchText) ||
                stack.description.localizedCaseInsensitiveContains(searchText) || stack.creator.localizedCaseInsensitiveContains(searchText)
            
            let matchesCategory = selectedCategory == "All" || stack.tags.contains(selectedCategory)
            
            
            // TODO: Update this logic once the friend feature is implemented
            let matchesCreator = selectedCreator == "Anyone" ||
                (selectedCreator == "Me" && stack.creatorID == auth.user?.id) ||
                (selectedCreator == "Friends" && stack.creatorID != auth.user?.id && stack.isPublic)
            
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
