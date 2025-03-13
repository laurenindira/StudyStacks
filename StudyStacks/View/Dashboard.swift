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
    @State var creatingStack: Bool = false
    
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
                
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { creatingStack = true }) {
                        HStack {
                            Text("New Stack")
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $creatingStack) {
                NewStackView()
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
