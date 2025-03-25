//
//  Dashboard.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var auth: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("This is a dashboard")
                
                NavigationLink(destination: SettingsView()) {
                    GeneralButton(placeholder: "Go to Settings", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                }
                
                Button {
                    Task {
                        auth.signOut()
                    }
                } label: {
                    GeneralButton(placeholder: "sign out", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                }
            }
            .padding()
        }
    }
}

#Preview {
    Dashboard()
        .environmentObject(AuthViewModel())
}
