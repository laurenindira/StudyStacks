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
    @State private var selectedCards: [Card] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("My Stacks")
                    .font(.title)
                    .bold()
                    .padding(.top, 20)
                
                Text("Stacks Count: \(stackVM.stacks.count)")
                
                if stackVM.stacks.isEmpty {
                    Text("You don't have any stacks yet!")
                        .font(.body)
                } else {
                    // List of Stacks
                    List(stackVM.stacks) { stack in
                        NavigationLink(destination: CardStackView(
                            swipeVM: SwipeableCardsViewModel(cards: stack.cards),
                            card: stack.cards.first ?? Card(id: "0", front: "No Cards", back: "This stack is empty"),
                            stack: stack
                        )){
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
                        await stackVM.fetchStacks()
                    }
                }

                // Sign Out Button
                Button {
                    Task {
                        auth.signOut()
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
            .padding()
            .onAppear {
                print("Stacks in ViewModel: \(stackVM.stacks)")
            }
        }
    }
}

#Preview {
    Dashboard()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
