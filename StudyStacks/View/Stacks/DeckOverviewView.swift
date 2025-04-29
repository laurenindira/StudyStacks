//
//  DeckOverviewView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 3/4/25.
//

import SwiftUI

struct StackDetailView: View {
    var stack: Stack
    @State private var currentCardIndex = 0
    @State private var isFlipped = false
    @State private var isDeleted = false
    @State private var showDeleteConfirmation = false
    @State private var deleteErrorMessage: String?
    @State private var isFavorite: Bool = false
    @State private var showCardStackView = false

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var auth: AuthViewModel
    
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(stack.title)
                            .customHeading(.title)
                        Text("Created by \(stack.creator)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    ZStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 300, height: 200)
                                .overlay(
                                    Text(stack.cards[currentCardIndex].front)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(20)
                                        .minimumScaleFactor(0.5)
                                )
                                .opacity(isFlipped ? 0 : 1)
                                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 300, height: 200)
                                .overlay(
                                    Text(stack.cards[currentCardIndex].back)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .multilineTextAlignment(.center)
                                        .padding(20)
                                        .minimumScaleFactor(0.5)
                                )
                                .opacity(isFlipped ? 1 : 0)
                                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
                        }
                        .animation(.easeInOut(duration: 0.5), value: isFlipped)
                        .onTapGesture { isFlipped.toggle() }

                        HStack {
                            Button {
                                withAnimation {
                                    if currentCardIndex > 0 {
                                        currentCardIndex -= 1
                                        isFlipped = false
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title)
                                    .padding(10)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    if currentCardIndex < stack.cards.count - 1 {
                                        currentCardIndex += 1
                                        isFlipped = false
                                    }
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.title)
                                    .padding(10)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal, 8)
                        .frame(width: 340)
                    }
                    .frame(width: 340, height: 220)
//                    .padding(.horizontal, 20)
                    
                    TermsListView(cards: stack.cards)
//                        .padding(.horizontal)
//                        .padding(.horizontal, 10)

                    Button {
                        showCardStackView = true
                    } label: {
                        Text("Start Studying")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.prim)
                            .cornerRadius(12)
                    }
                    .padding()
                    .navigationDestination(isPresented: $showCardStackView) {
                        CardStackView(
                            swipeVM: SwipeableCardsViewModel(cards: stack.cards),
                            card: stack.cards.first ?? Card(front: "", back: ""),
                            stack: stack
                        )
                    }
                    
                }
            }
            .padding(.horizontal, 10)
            .onAppear {
                self.isFavorite = stackVM.isFavorite(stack)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.error)
                                .font(.title3)
                        }
                        Button {
                            Task {
                                isFavorite.toggle()
                                await stackVM.toggleFavorite(for: stack.id)
                            }
                        } label: {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .foregroundColor(isFavorite ? Color.prim : .gray)
                                .font(.title2)
                                .padding(.vertical)
                        }
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

#Preview {
    StackDetailView(stack: Stack(
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
    ))
    .environmentObject(StackViewModel())
    .environmentObject(AuthViewModel())
}
