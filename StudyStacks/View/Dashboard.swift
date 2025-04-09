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
    @EnvironmentObject var friendVM: FriendsViewModel
    
    @State var creatingStack: Bool = false
   
    @AppStorage("userPoints") var currentPoints: Int = 0
  
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Welcome back, \(auth.user?.displayName ?? "user")!")
                        .font(.customHeading(.title2))

                    // Weekly Progress Card
                    WeeklyProgressView(rank: "1st", cardsStudied: currentPoints)

                    // Streaks + Cards Studied
                    HStack(alignment: .center, spacing: 16) {
                        StatCardView(number: 6, text: "day streak")
                        StatCardView(number: 2345, text: "lifetime cards")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Recommended Stacks
                    if let selectedSubjects = auth.user?.selectedSubjects {
                        ForEach(selectedSubjects, id: \.self) { subject in
                            let subjectStacks = stackVM.publicStacks.filter { stack in
                                stack.tags.contains { $0.localizedCaseInsensitiveContains(subject) }
                            }

                            Group {
                                if !subjectStacks.isEmpty {
                                    RecommendedStacksView(
                                        stack: subjectStacks,
                                        title: "So you're interested in \(subject)..."
                                    )
                                }
                            }
                        }
                    }
                }
                
                Button {
                    Task {
                        await auth.signOut()
                    }
                } label: {
                    GeneralButton(placeholder: "Sign Out", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                }
                .padding(.top, 20)

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
                    await friendVM.fetchFriends(userID: auth.user?.id)
                    await friendVM.fetchFriendRequests(userID: auth.user?.id)
                    //await stackVM.fetchPublicStacks()
                }
            }
            .padding()
        }
    
    }
}

#Preview {
    // Mock user
    let mockUser = User(
        id: "1",
        username: "raihana_z",
        displayName: "Raihana",
        email: "rai@study.com",
        profilePicture: nil,
        creationDate: .now,
        lastSignIn: nil,
        providerRef: "",
        selectedSubjects: ["biology", "computer science", "geography"],
        studyReminderTime: .now,
        studentType: "college",
        currentStreak: 6,
        longestStreak: 15,
        lastStudyDate: nil,
        points: 2345
    )

    // Mock stacks
    let mockStacks = [
        Stack(
            id: "1",
            title: "Intro to Biology",
            description: "Learn the basics of life",
            creator: "Raihana",
            creatorID: "1",
            creationDate: .now,
            tags: ["biology"],
            cards: [],
            isPublic: true
        ),
        Stack(
            id: "2",
            title: "SwiftUI Essentials",
            description: "Study core SwiftUI components",
            creator: "Raihana",
            creatorID: "1",
            creationDate: .now,
            tags: ["computer science"],
            cards: [],
            isPublic: true
        ),
        Stack(
            id: "3",
            title: "World Maps & More",
            description: "Explore geography flashcards",
            creator: "Raihana",
            creatorID: "1",
            creationDate: .now,
            tags: ["geography"],
            cards: [],
            isPublic: true
        )
    ]

    // Mock view models
    let mockAuth = AuthViewModel()
    mockAuth.user = mockUser

    let mockStackVM = StackViewModel()
    mockStackVM.publicStacks = mockStacks

    return Dashboard()
        .environmentObject(mockAuth)
        .environmentObject(mockStackVM)
        .environmentObject(FriendsViewModel()) // Or mock this too if needed
}
