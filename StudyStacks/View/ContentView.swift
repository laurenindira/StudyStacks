//
//  ContentView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    @AppStorage("isSignedIn") var isSignedIn = false
    
    var body: some View {
        Group {
            if !isSignedIn {
                SplashView()
                    .environmentObject(auth)
                    .environmentObject(stackVM)
            } else {
                TabView() {
                    Dashboard()
                        .environmentObject(auth)
                        .environmentObject(stackVM)
                        .tabItem {
                            Label("Dashboard", systemImage: "house")
                        }
                    
                    LibraryView()
                        .environmentObject(auth)
                        .environmentObject(stackVM)
                        .tabItem {
                            Label("Library", systemImage: "square.stack.3d.up.fill")
                        }
                    
                    FriendManagerView()
                        .environmentObject(auth)
                        .environmentObject(stackVM)
                        .environmentObject(friendVM)
                        .tabItem {
                            Label("Social", systemImage: "person.3")
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
