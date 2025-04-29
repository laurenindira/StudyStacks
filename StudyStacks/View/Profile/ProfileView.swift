//
//  ProfileView.swift
//  StudyStacks
//
//  Created by Brady Katler on 3/25/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    
    var formattedDate: String {
        guard let date = auth.user?.creationDate else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var userInitials: String {
        let name = auth.user?.displayName ?? ""
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }
        return initials.map { String($0) }.joined().uppercased()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    
                    //HEADER
                    HStack(alignment: .center, spacing: 16) {
                        Text(userInitials.isEmpty ? "??" : userInitials)
                            .font(.title)
                            .bold()
                            .foregroundColor(.black)
                            .padding(24) // adjusts the "circle" size
                            .background(
                                Circle()
                                    .fill(Color("background"))
                                    .overlay(
                                        Circle().stroke(Color.black.opacity(0.1), lineWidth: 2)
                                    )
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(auth.user?.displayName ?? "Unknown User")
                                .customHeading(.title)
                            Text("@\(auth.user?.username ?? "username")")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Member since \(formattedDate)")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Stats
                    HStack {
                        VStack {
                            Image(systemName: "sparkles")
                                .font(.system(size: 22))
                                .foregroundColor(Color("stacksblue"))
                            let streak = auth.user?.currentStreak ?? 0
                            Text("\(streak) day\(streak == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal)
                        
                        VStack {
                            Image(systemName: "square.stack.3d.up")
                                .font(.system(size: 22))
                                .foregroundColor(Color("stacksblue"))
                            Text("\(stackVM.userStacks.count) stacks")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal)
                        
                        VStack {
                            Image(systemName: "medal")
                                .font(.system(size: 22))
                                .foregroundColor(Color("stacksblue"))
                            //TODO: change this to actual badge count if possible
                            Text("2 badges")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color("surface"))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // MARK: My Stacks
                    if let userID = auth.user?.id {
                        RecommendedStacksView(
                            stack: stackVM.userStacks.filter { $0.creatorID == userID }.prefix(4).map { $0 },
                            title: "My Stacks",
                            emptyMessage: "You haven't created any stacks yet."
                        )
                        
                        // MARK: Saved Stacks
                        RecommendedStacksView(
                            stack: stackVM.combinedStacks.filter { stackVM.favoriteStackIDs.contains($0.id) }.prefix(4).map { $0 },
                            title: "Saved Stacks",
                            emptyMessage: "You haven't saved any stacks yet."
                        )
                    }
                    
                }
            }
            .padding()
            .onAppear {
                Task {
                    if let userID = auth.user?.id {
                        await stackVM.fetchUserStacks(for: userID)
                        await stackVM.fetchUserFavorites(for: userID)
                        await stackVM.fetchPublicStacks()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}

private func relativeDate(from date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: date, relativeTo: Date())
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
