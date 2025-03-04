//
//  Dashboard.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("This is a dashboard")
                Button {
                    Task {
                        auth.signOut()
                    }
                } label: {
                    GeneralButton(placeholder: "sign out", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                }
                NavigationLink(destination: StackCreationView()) {
                    Text("Make a stack")
                }
            }
            .padding()
        }
        
    }
}

#Preview {
    Dashboard()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
