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
                    // TODO: change once leaderboard is implemented
                    WeeklyProgressView(rank: "1st", cardsStudied: currentPoints)

                    // Streaks + Cards Studied
                    HStack(alignment: .center, spacing: 16) {
                        StatCardView(number: auth.user?.currentStreak ?? 0, text: "day streak")
                        StatCardView(number: stackVM.userStacks.count, text: "stacks created")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Recommended Stacks
                    if let selectedSubjects = auth.user?.selectedSubjects {
                        let filteredSubjects = selectedSubjects.prefix(3)
                        
                        ForEach(filteredSubjects, id: \.self) { subject in
                            let filteredStacks = stackVM.publicStacks.filter { stack in
                                stack.tags.contains { $0.caseInsensitiveCompare(subject) == .orderedSame }
                            }

                            RecommendedStacksView(
                                stack: filteredStacks,
                                title: "Interest in \(subject.capitalized)...",
                                emptyMessage: "No stacks found for your interest."
                            )
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
    let mockUser = User(
        id: "1",
        username: "raihana_z",
        displayName: "Raihana",
        email: "rai@study.com",
        profilePicture: nil,
        creationDate: .now,
        lastSignIn: nil,
        providerRef: "",
        selectedSubjects: ["biology", "geography", "political science", "computer science"],
        studyReminderTime: .now,
        studentType: "college",
        currentStreak: 6,
        longestStreak: 15,
        lastStudyDate: nil,
        points: 2345
    )

    // Only add stacks for biology, geography, and computer science
    let mockStacks: [Stack] = ["biology", "geography", "computer science"].flatMap { subject in
        (1...3).map { index in
            Stack(
                id: "\(subject)-\(index)",
                title: "\(subject.capitalized) Stack \(index)",
                description: "Preview stack for \(subject)",
                creator: "Raihana",
                creatorID: "1",
                creationDate: .now,
                tags: [subject],
                cards: [],
                isPublic: true
            )
        }
    }

    let mockAuth = AuthViewModel()
    mockAuth.user = mockUser

    let mockStackVM = StackViewModel()
    mockStackVM.publicStacks = mockStacks

    return Dashboard()
        .environmentObject(mockAuth)
        .environmentObject(mockStackVM)
        .environmentObject(FriendsViewModel())
}
