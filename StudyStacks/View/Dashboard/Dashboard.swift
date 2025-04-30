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
                    let rank = getCurrentUserRank(from: friendVM.friends, user: auth.user)
                    let rankDisplay = rankString(from: rank)
                    
                    // Header
                    Text("Welcome back, \(auth.user?.displayName ?? "user")!")
                        .font(.customHeading(.title2))

                    // Weekly Progress Card
                    WeeklyProgressView(rank: rankDisplay, cardsStudied: currentPoints)

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
                                emptyMessage: "No stacks found for your interest.",
                                isLoading: stackVM.isLoading
                            )
                        }
                    }
                }
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
                    if let currentUser = auth.user {
                        await friendVM.fetchFriends(userID: currentUser.id)
                        await friendVM.fetchFriendRequests(userID: currentUser.id)
                    }
                    await stackVM.fetchPublicStacks()
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
    
    // functions
    func getCurrentUserRank(from friends: [Friend], user: User?) -> Int? {
        guard let user = user else { return nil }
        
        var allFriends = friends
        let currentUserAsFriend = Friend(
            id: user.id,
            username: user.username,
            displayName: user.displayName,
            email: user.email,
            creationDate: user.creationDate,
            currentStreak: user.currentStreak,
            points: user.points
        )
        
        allFriends.append(currentUserAsFriend)
        let sorted = allFriends.sorted { $0.points > $1.points }
        
        return sorted.firstIndex(where: { $0.id == user.id }).map { $0 + 1 }
    }
    
    func rankString(from rank: Int?) -> String {
        guard let rank = rank else { return "N/A" }
        let suffix: String
        switch rank {
        case 11, 12, 13:
            suffix = "th"
        default:
            switch rank % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(rank)\(suffix)"
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
        points: 2345,
        favoriteStackIDs: []
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
