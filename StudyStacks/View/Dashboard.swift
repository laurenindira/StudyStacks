//
//  DashboardView.swift
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
                Text("My Stacks")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)

                // List of Stacks
                List($stackVM.stacks) { $stack in
                    NavigationLink(destination: EditStackView(stack: $stack)) {
                        VStack(alignment: .leading) {
                            Text(stack.title)
                                .font(.headline)
                                .bold()
                            Text("Created by \(stack.creator)")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .task {
                    if let userID = auth.user?.id {
                        await stackVM.fetchUserStacks(for: userID)
                    }
                }

                // Sign Out Button
                Button {
                    Task {
                        auth.signOut()
                    }
                } label: {
                    GeneralButton(
                        placeholder: "Sign Out",
                           backgroundColor: Color.prim,
                           foregroundColor: Color.white,
                           isSystemImage: false
                    )
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
