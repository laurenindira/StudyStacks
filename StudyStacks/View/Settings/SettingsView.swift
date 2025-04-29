//
//  SettingsView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 4/16/25.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    @EnvironmentObject var stackVM: StackViewModel
    
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Settings")
                    .customHeading(.title)
                
                VStack(spacing: 15) {
                    NavigationLink {
                        UserInfoOverview()
                    } label: {
                        SettingsRow(icon: "person.crop.circle", title: "Profile")
                    }
                    
                    Divider()
                    
                    NavigationLink {
                        NotificationSettings()
                    } label: {
                        SettingsRow(icon: "bell", title: "Notifications")
                    }
                    
                    Divider()
                    
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        SettingsRow(icon: "lock", title: "Privacy")
                    }
                    
                    Divider()
                    
                    NavigationLink {
                        AboutView()
                    } label: {
                        SettingsRow(icon: "info.circle", title: "About")
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                VStack {
                    Button {
                        Task { await AuthViewModel.shared.signOut() }
                    } label: {
                        GeneralButton(placeholder: "Log out", backgroundColor: Color.prim, foregroundColor: Color.lod, isSystemImage: false)
                    }
                    
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        GeneralButton(placeholder: "Delete account", backgroundColor: Color.error, foregroundColor: Color.lod, isSystemImage: false)
                    }
                }
            }
            .padding()
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("This action will permanently delete your account and all associated data."),
                    primaryButton: .destructive(Text("Delete")) {
                        Task {
                            do {
                                try await auth.deleteUserAccount { error in
                                    if let error = error {
                                        print("Error deleting account: \(error.localizedDescription)")
                                    } else {
                                        print("Account successfully deleted")
                                    }
                                }
                            } catch {
                                print("Failed to delete account: \(error.localizedDescription)")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}


struct SettingsRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
            Text(title)
                .font(.system(size: 20))
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
            .environmentObject(FriendsViewModel())
            .environmentObject(StackViewModel())
    }
}
