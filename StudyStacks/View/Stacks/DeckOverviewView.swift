//
//  DeckOverviewView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 3/4/25.
//

import SwiftUI

struct StackDetailView: View {
    var stack: Stack
    @State private var isFavorited: Bool
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var isDeleted = false
    @State private var showDeleteConfirmation = false
    @State private var deleteErrorMessage: String?

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var stackVM: StackViewModel
    
    init(stack: Stack) {
        self.stack = stack
        _isFavorited = State(initialValue: false)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let errorMessage = deleteErrorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.headline)
                        .padding()
                }
                if isDeleted {
                    Text("The deck has been deleted.")
                        .foregroundColor(.green)
                        .font(.headline)
                        .padding()
                } else {
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
                                            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 1, y: 0, z: 0))
                                            .opacity(isFlipped ? 0 : 1)
                                    }
                                    if isFlipped {
                                        Text(stack.cards[currentCardIndex].back)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 1, y: 0, z: 0))
                                            .opacity(isFlipped ? 1 : 0)
                                    }
                                }
                            )
                            .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 1, y: 0, z: 0))
                            .animation(.easeInOut(duration: 0.6), value: isFlipped)
                            .onTapGesture {
                                withAnimation {
                                    isFlipped.toggle()
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: {
                            showDeleteConfirmation = true
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
                    Button(action: {
                        isFavorited.toggle()
                        stackVM.toggleFavorite(for: stack)
                    }) {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .foregroundColor(isFavorited ? .yellow : .gray)
                            .font(.title2)
                            .padding()
                    }
                }
            }
            .alert("Delete Deck", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) { deleteStack() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this deck? This action cannot be undone.")
            }
        }
        .onAppear() {
            isFavorited = stackVM.isFavorite(stack)
        }
    }


    
    private func deleteStack() {
        Task {
            
            await stackVM.deleteStack(stack)
            
            
            if let index = stackVM.stacks.firstIndex(where: { $0.id == stack.id }) {
                stackVM.stacks.remove(at: index)
            }
            
            
            await MainActor.run {
                isDeleted = true
                deleteErrorMessage = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }

}

struct StackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockStack = Stack(
            id: UUID().uuidString,
            title: "U.S. States & Capitals",
            description: "A deck to learn U.S. states and their capitals",
            creator: "Sarah Cameron",
            creatorID: "mockCreatorID",
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
        )

        let mockStackVM = StackViewModel()
        mockStackVM.stacks = [mockStack]

        return StackDetailView(stack: mockStack)
            .environmentObject(mockStackVM)
    }
}
