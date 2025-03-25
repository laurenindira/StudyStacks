//
//  Settings.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 3/25/25.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        
                        NavigationLink(destination: PlaceholderView(title: "Profile")) {
                            SettingsRow(icon: "person.crop.circle", title: "Profile")
                                .padding(.vertical, 10)
                        }
                        
                        
                        NavigationLink(destination: PlaceholderView(title: "Notifications")) {
                            SettingsRow(icon: "bell", title: "Notifications")
                                .padding(.vertical, 10)
                        }
                        
                        
                        NavigationLink(destination: PlaceholderView(title: "Privacy")) {
                            SettingsRow(icon: "lock", title: "Privacy")
                                .padding(.vertical, 10)
                        }
                        
                        
                        NavigationLink(destination: PlaceholderView(title: "About")) {
                            SettingsRow(icon: "info.circle", title: "About")
                                .padding(.vertical, 10)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .padding(.top, 10)
                
                Spacer()
                
                VStack(spacing: 10) {
                    Button(action: {
                        auth.signOut()
                    }) {
                        Text("Log out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.prim)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                    
                    }) {
                        Text("Delete account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.error)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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
                .font(.system(size: 18))
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
