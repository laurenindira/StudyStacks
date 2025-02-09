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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
