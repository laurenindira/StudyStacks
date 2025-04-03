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
    
    var currentPoints: Int = UserDefaults.standard.integer(forKey: "userPoints")

    var body: some View {
        NavigationStack {
            VStack {

                Text("This is a dashboard")
                
                Text("\(auth.user?.displayName ?? "this user") has a \(String(auth.user?.currentStreak ?? 0)) day streak")
                
                Text("Points: \(currentPoints)")
                    .font(.title)
                    .padding()

//                if let lastReset = auth.user?.lastPointsResetDate {
//                    let nextReset = lastReset.addingTimeInterval(7 * 24 * 60 * 60)
//                    let now = Date()
//                    let calendar = Calendar.current
//                    let components = calendar.dateComponents([.day, .hour], from: now, to: nextReset)
//                    
//                    if let days = components.day, let hours = components.hour {
//                        Text("Resets in \(days)d \(hours)h")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                }
                                


                Button {
                    Task {
                        await auth.signOut()
                    }
                } label: {
                    GeneralButton(placeholder: "Sign Out", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                }
                .padding(.top, 20)
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
            }
            .sheet(isPresented: $creatingStack) {
                NewStackView()
            }
            .padding()
        
        }
    
    }

#Preview {
    Dashboard()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
