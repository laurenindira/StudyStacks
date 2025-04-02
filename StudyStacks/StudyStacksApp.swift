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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(StackViewModel())
                .environmentObject(AuthViewModel())
                .environmentObject(StackViewModel())
                .environmentObject(ForgottenCardsViewModel())
        }
    }
}
