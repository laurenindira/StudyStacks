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
        VStack(alignment: .center, spacing: 20) {
            // Top Bar with Settings
            HStack {
                Spacer()
                NavigationLink(destination: Text("Settings")) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            // Profile Section
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color("background"))
                        .frame(width: 72, height: 72)
                        .overlay(
                            Circle()
                                .stroke(Color.black.opacity(0.1), lineWidth: 2)
                        )
                    Text(userInitials.isEmpty ? "??" : userInitials)
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                }

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

            // Stats Container
            HStack(spacing: 40) {
                VStack {
                    Image(systemName: "sparkles")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color("stacksblue"))

                    // TODO: Replace hardcoded streak value with actual user data in future PR
                    Text("126 days")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }

                VStack {
                    Image(systemName: "square.stack.3d.up")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color("stacksblue"))

                    // ✅ Corrected: use userStacks
                    Text("\(stackVM.userStacks.count) stacks")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }

                VStack {
                    Image(systemName: "medal")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color("stacksblue"))
                    Text("2 badges")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
            }
            .padding()
            .background(Color("background"))
            .cornerRadius(20)
            .padding(.horizontal)

            Spacer()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
