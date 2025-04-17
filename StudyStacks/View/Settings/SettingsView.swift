//
//  SettingsView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 4/16/25.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    Text("Settings")
                        .customHeading(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .padding(.bottom, 16)
//                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Group {
                        NavigationLink(destination: PlaceholderView(title: "Profile")) {
                            SettingsRow(icon: "person.crop.circle", title: "Profile")
                                .padding(.vertical, 20)
                        }
                        Divider()

                        NavigationLink(destination: NotificationSettings()) {
                            SettingsRow(icon: "bell", title: "Notifications")
                                .padding(.vertical, 20)
                        }
                        Divider()

                        NavigationLink(destination: PrivacyView()) {
                            SettingsRow(icon: "lock", title: "Privacy")
                                .padding(.vertical, 20)
                        }
                        Divider()

                        NavigationLink(destination: AboutView()) {
                            SettingsRow(icon: "info.circle", title: "About")
                                .padding(.vertical, 20)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()
                
                VStack(spacing: 24) {
                    Button(action: {
                        Task {
                            await auth.signOut()
                        }
                    }) {
                        GeneralButton(
                            placeholder: "Log out",
                            backgroundColor: Color.prim,
                            foregroundColor: .white,
                            isSystemImage: false
                        )
                    }

                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        GeneralButton(
                            placeholder: "Delete account",
                            backgroundColor: Color.error,
                            foregroundColor: .white,
                            isSystemImage: false
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)

            }
            .frame(maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.secondarySystemGroupedBackground).ignoresSafeArea())
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

struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack {
            Text("\(title) Page")
                .font(.title)
                .padding()

            Text("Still in progress.")
                .font(.subheadline)
                .padding()

            Spacer()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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
    }
}
