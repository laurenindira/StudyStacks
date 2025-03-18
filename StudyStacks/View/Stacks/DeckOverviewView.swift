//
//  DeckOverviewView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 3/4/25.
//

import SwiftUI

struct StackDetailView: View {
    var stack: Stack
    @State private var isFavorited = false
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(stack.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Created by \(stack.creator)")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 340, height: 200)
                        .overlay(
                            ZStack {
                                
                                if !isFlipped {
                                    Text(stack.cards[currentCardIndex].front)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .rotation3DEffect(
                                            .degrees(isFlipped ? 180 : 0),
                                            axis: (x: 1, y: 0, z: 0) // flip forward
                                        )
                                        .opacity(isFlipped ? 0 : 1)
                                        .rotation3DEffect(
                                            .degrees(isFlipped ? -180 : 0),
                                            axis: (x: 1, y: 0, z: 0) // flip the text in opposite direction
                                        )
                                }
                                
                            
                                if isFlipped {
                                    Text(stack.cards[currentCardIndex].back)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .rotation3DEffect(
                                            .degrees(isFlipped ? 0 : -180), // flip back
                                            axis: (x: 1, y: 0, z: 0) // flip forward
                                        )
                                        .opacity(isFlipped ? 1 : 0)
                                        .rotation3DEffect(
                                            .degrees(isFlipped ? 180 : 0),
                                            axis: (x: 1, y: 0, z: 0)
                                        )
                                }
                            }
                        )
                        .rotation3DEffect(
                            .degrees(isFlipped ? 180 : 0),
                            axis: (x: 1, y: 0, z: 0) // Flip forward
                        )
                        .animation(.easeInOut(duration: 0.6), value: isFlipped)
                        .onTapGesture {
                            withAnimation {
                                isFlipped.toggle()  // Flip the card on tap
                            }
                        }
                    
                    HStack {
                        Button(action: {
                            withAnimation {
                                if currentCardIndex > 0 {
                                    currentCardIndex -= 1
                                    isFlipped = false  
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                if currentCardIndex < stack.cards.count - 1 {
                                    currentCardIndex += 1
                                    isFlipped = false
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.title)
                        }
                    }
                    .padding(.horizontal, 24)
                    .foregroundColor(.gray)
                }
                .padding()
                
            
                TermsListView(cards: stack.cards)
                    .padding(.horizontal)

                Button(action: {}) {
                    Text("Start Studying")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.prim)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Text("< Back")
                            .foregroundColor(Color.prim)
                            .padding()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            deleteStack()  
                        }) {
                            Label("Delete Deck", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .padding()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isFavorited.toggle() }) {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .foregroundColor(isFavorited ? Color.yellow : Color.gray)
                            .font(.title2)
                            .padding()
                    }
                }
            }
        }
    }
    
    private func deleteStack() {
        Task {
            StackViewModel.shared.deleteStack(stack)
            await MainActor.run {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


struct StackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StackDetailView(stack: Stack(
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
        ))
    }
}
