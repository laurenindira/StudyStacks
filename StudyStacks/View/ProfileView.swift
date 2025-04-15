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
                    
                    // Profile
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
                                .font(.system(size: 22, weight: .bold))
                            Text("@\(auth.user?.username ?? "username")")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Member since \(formattedDate)")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Stats
                    HStack(spacing: 40) {
                        VStack {
                            Image(systemName: "sparkles")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color("stacksblue"))
                            let streak = auth.user?.currentStreak ?? 0
                            Text("\(streak) day\(streak == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        VStack {
                            Image(systemName: "square.stack.3d.up")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color("stacksblue"))
                            Text("\(stackVM.userStacks.count) stacks")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                        
                        VStack {
                            Image(systemName: "medal")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color("stacksblue"))
                            //TODO: Replace hardcoded badges when implemented (or use friends)
                            Text("2 badges")
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .background(Color("surface"))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // MARK: My Stacks
                    if let userID = auth.user?.id {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("My Stacks")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(stackVM.userStacks.filter { $0.creatorID == userID }.prefix(4)) { stack in
                                        NavigationLink(destination: StackDetailView(stack: stack)
                                            .environmentObject(stackVM)) {
                                                StackCardView(stack: stack, isFavorite: stackVM.isFavorite(stack))
                                            }
                                            .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // MARK: Saved Stacks
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Saved Stacks")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if stackVM.favoriteStackIDs.isEmpty {
                                Text("You haven't saved any stacks yet.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(stackVM.combinedStacks.filter { stackVM.favoriteStackIDs.contains($0.id) }.prefix(4)) { stack in
                                            NavigationLink(destination: StackDetailView(stack: stack)
                                                .environmentObject(stackVM)) {
                                                    StackCardView(stack: stack, isFavorite: true)
                                                        .frame(maxWidth: .infinity)
                                                }
                                                .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
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
                        NavigationLink(destination: Text("Settings")) {
                            Image(systemName: "gearshape")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
        }
    }

    private func relativeDate(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
