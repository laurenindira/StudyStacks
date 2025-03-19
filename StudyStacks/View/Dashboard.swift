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
                
                NavigationLink(destination: StackDetailView(stack: Stack(
                                    id: UUID().uuidString,
                                    title: "U.S. States & Capitals",
                                    creator: "Sarah Cameron",
                                    creationDate: Date(),
                                    tags: ["Geography", "States", "Capitals"],
                                    cards: [
                                        Card(front: "California", back: "Sacramento"),
                                        Card(front: "Texas", back: "Austin"),
                                        Card(front: "Florida", back: "Tallahassee"),
                                        Card(front: "New York", back: "Albany"),
                                        Card(front: "Illinois", back: "Springfield")
                                    ],
                                    isPublic: true
                                ))) {
                                    Text("Preview Deck Overview")
                                        .padding()
                                        .foregroundColor(.prim)
                                }
                            }
            }
            .padding()
        }
        
    }

#Preview {
    Dashboard()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
