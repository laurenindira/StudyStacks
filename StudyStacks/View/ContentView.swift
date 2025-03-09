//
//  ContentView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel
    @AppStorage("isSignedIn") var isSignedIn = false
    
    var body: some View {
        Group {
            if !isSignedIn {
                SplashView()
                    .environmentObject(auth)
            } else {
                TabView() {
                    Dashboard()
                        .environmentObject(auth)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
