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
    
    @State var creatingStack: Bool = false
    @State private var selectedCards: [Card] = []
    @State var searchText: String = ""

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    //TITLE
                    Text("My Stacks")
                        .customHeading(.title)
                    
                    Text("Stacks Count: \(stackVM.userStacks.count)")
                    
                    // SEARCH
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.callout)
                            .foregroundStyle(Color.stacksgray)
                        TextField("Search your stacks...", text: $searchText)
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
                    
                    // LIST OF STACKS
                    if searchResults.isEmpty {
                        ErrorView(errorMessage: "You don't have any stacks yet!", imageName: "empty-box", isSystemImage: false)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(searchResults, id: \.self) { stack in
                            NavigationLink {
                                CardStackView(
                                    swipeVM: SwipeableCardsViewModel(cards: stack.cards),
                                    card: stack.cards.first ?? Card(id: "0", front: "No Cards", back: "This stack is empty"),
                                    stack: stack
                                )
                            } label: {
                                StackCardView(stack: stack, isFavorite: false)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Sign Out Button
                    Button {
                        Task {
                            auth.signOut()
                        }
                    } label: {
                        GeneralButton(placeholder: "Sign Out", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                    }
                    .padding(.top, 20)
                }
            }
            .sheet(isPresented: $creatingStack) {
                NewStackView()
            }
            .padding()
            .animation(.easeInOut, value: searchResults)
            .onAppear {
                Task {
                    if let userID = auth.user?.id {
                        await stackVM.fetchUserStacks(for: userID)
                    }
                }
            }
            .refreshable {
                await refresh()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { creatingStack = true }) {
                        HStack {
                            Text("New Stack")
                            Image(systemName: "plus")
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
        if searchText.isEmpty {
            return stackVM.userStacks
        } else {
            return stackVM.userStacks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.creator.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    private func refresh() async {
        if let userID = auth.user?.id {
            await stackVM.fetchUserStacks(for: userID)
        }
    }
}

#Preview {
    let authVM = AuthViewModel()
    let stackVM = StackViewModel()

    authVM.user = User(
        id: "testUser123",
        username: "testuser",
        displayName: "Test User",
        email: "test@example.com",
        creationDate: Date(),
        lastSignIn: Date(),
        providerRef: "email",
        selectedSubjects: ["Math", "Science"],
        studyReminderTime: Date(),
        studentType: "University"
    )

    // Mock stacks
    stackVM.userStacks = [
        Stack(
            id: "1",
            title: "Swift Basics",
            description: "Learn the basics of Swift.",
            creator: "Test User",
            creatorID: "testUser123",
            creationDate: Date(),
            tags: ["Swift", "iOS", "Programming"],
            cards: [
                Card(id: "101", front: "What is Swift?", back: "Swift is a programming language for iOS and macOS."),
                Card(id: "102", front: "What is a struct?", back: "A struct is a value type in Swift.")
            ],
            isPublic: false
        ),
        Stack(
            id: "2",
            title: "Data Structures",
            description: "Stacks, Queues, and Trees.",
            creator: "Test User",
            creatorID: "testUser123",
            creationDate: Date(),
            tags: ["CS", "Algorithms", "Data Structures"],
            cards: [
                Card(id: "201", front: "What is a stack?", back: "A stack is a LIFO data structure."),
                Card(id: "202", front: "What is a queue?", back: "A queue is a FIFO data structure.")
            ],
            isPublic: false
        ),
        Stack(
            id: "2",
            title: "Data Structures",
            description: "Stacks, Queues, and Trees.",
            creator: "Test User",
            creatorID: "testUser123",
            creationDate: Date(),
            tags: ["CS", "Algorithms", "Data Structures"],
            cards: [
                Card(id: "201", front: "What is a stack?", back: "A stack is a LIFO data structure."),
                Card(id: "202", front: "What is a queue?", back: "A queue is a FIFO data structure.")
            ],
            isPublic: false
        ),
        Stack(
            id: "2",
            title: "Data Structures",
            description: "Stacks, Queues, and Trees.",
            creator: "Test User",
            creatorID: "testUser123",
            creationDate: Date(),
            tags: ["CS", "Algorithms", "Data Structures"],
            cards: [
                Card(id: "201", front: "What is a stack?", back: "A stack is a LIFO data structure."),
                Card(id: "202", front: "What is a queue?", back: "A queue is a FIFO data structure.")
            ],
            isPublic: false
        ),
        Stack(
            id: "2",
            title: "Data Structures",
            description: "Stacks, Queues, and Trees.",
            creator: "Test User",
            creatorID: "testUser123",
            creationDate: Date(),
            tags: ["CS", "Algorithms", "Data Structures"],
            cards: [
                Card(id: "201", front: "What is a stack?", back: "A stack is a LIFO data structure."),
                Card(id: "202", front: "What is a queue?", back: "A queue is a FIFO data structure.")
            ],
            isPublic: false
        ),
        Stack(
            id: "2",
            title: "Data Structures",
            description: "Stacks, Queues, and Trees.",
            creator: "Test User",
            creatorID: "testUser123",
            creationDate: Date(),
            tags: ["CS", "Algorithms", "Data Structures"],
            cards: [
                Card(id: "201", front: "What is a stack?", back: "A stack is a LIFO data structure."),
                Card(id: "202", front: "What is a queue?", back: "A queue is a FIFO data structure.")
            ],
            isPublic: false
        )
    ]

    return Dashboard()
        .environmentObject(authVM)
        .environmentObject(stackVM)
}
