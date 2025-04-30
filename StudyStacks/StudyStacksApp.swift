//
//  StudyStacksApp.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

@main
struct StudyStacksApp: App {
    @UIApplicationDelegateAdaptor(StudyStacksAppDelegate.self) var appDelegate
    @AppStorage("isSignedIn") var isSignedIn = false
    
    @StateObject private var auth = AuthViewModel.shared
    @StateObject private var stackVM = StackViewModel.shared
    @StateObject private var forgottenCardsVM = ForgottenCardsViewModel()
    @StateObject private var friendVM = FriendsViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(stackVM)
                .environmentObject(forgottenCardsVM)
                .environmentObject(friendVM)
        }
    }
}
