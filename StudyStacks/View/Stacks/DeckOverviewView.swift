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
    @State private var isDeleted = false
    @State private var showDeleteConfirmation = false
    @State private var deleteErrorMessage: String?

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var forgottenCardsVM: ForgottenCardsViewModel
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

                    // Start Studying entire stack
                    NavigationLink(destination: CardStackView(
                        swipeVM: SwipeableCardsViewModel(cards: stack.cards.map { card in
                            Card(id: card.id, front: card.front, back: card.back, imageURL: card.imageURL)
                        }),
                        forgottenCardsVM: forgottenCardsVM,
                        card: stack.cards.first ?? Card(id: "0", front: "No Cards", back: "This stack is empty"),
                        stack: stack
                    )) {
                        Text("Start Studying")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.prim)
                            .cornerRadius(12)
                    }
                    .padding()
                    
                    // Forgotten Cards Button
                    let forgotten = forgottenCardsVM.getForgottenCards(from: stack.cards, for: stack.id)

                    if forgotten.isEmpty {
                        Text("Haven't forgotten anything yet!")
                            .font(.subheadline)
                            .foregroundColor(Color.prim)
                    } else {
                        NavigationLink(destination: ForgottenCardStackView(
                            swipeVM: SwipeableCardsViewModel(cards: forgotten),
                            forgottenCardsVM: forgottenCardsVM,
                            card: forgotten.first ?? Card(id: "0", front: "No Cards", back: "This stack is empty"),
                            stack: stack)
                        ) {
                            Text("Review Forgotten Cards")
                                .font(.headline)
                                .foregroundColor(Color.prim)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.prim, lineWidth: 2)
                                )
                        }
                        .padding(.horizontal)
                    }
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
                    Button(action: { isFavorited.toggle() }) {
                        Image(systemName: isFavorited ? "star.fill" : "star")
                            .foregroundColor(isFavorited ? Color.yellow : Color.gray)
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
            
            .onAppear {
                print("📦 View appeared for stack \(stack.id)")
                if let userID = auth.user?.id {
                    print("✅ User already set: \(userID)")
                    forgottenCardsVM.load(for: userID)
                } else {
                    print("⏳ Waiting for user...")
                }
            }

            .onChange(of: auth.user?.id) {
                if let userID = auth.user?.id {
                    print("✅ User ID now available (onChange): \(userID)")
                    forgottenCardsVM.load(for: userID)
                }
            }


            
//            .onAppear {
//                print("StackDetailView appeared for stack: \(stack.id)")
//                if let userID = auth.user?.id {
//                    print("Loading forgotten cards for user: \(userID)")
//                    forgottenCardsVM.load(for: userID)
//                    let forgotten = forgottenCardsVM.getForgottenCards(from: stack.cards, for: stack.id)
//                    print("Found \(forgotten.count) forgotten cards for stack: \(stack.id)")
//                } else {
//                    print("No user ID available")
//                }
//            }
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

#Preview{
    let forgottenCards = [
        Card(id: "1", front: "California", back: "Sacramento"),
        Card(id: "2", front: "Texas", back: "Austin"),
        Card(id: "3", front: "Florida", back: "Tallahassee"),
        Card(id: "4", front: "New York", back: "Albany"),
        Card(id: "5", front: "Illinois", back: "Springfield")
    ]

    let mockStack = Stack(
        id: "stack1",
        title: "U.S. States & Capitals",
        description: "A deck to learn U.S. states and their capitals",
        creator: "Sarah Cameron",
        creatorID: "mockCreatorID",
        creationDate: .now,
        tags: ["Geography", "States", "Capitals"],
        cards: forgottenCards,
        isPublic: true
    )

    let mockAuth = AuthViewModel()
    mockAuth.user = User(
        id: "previewUser123",
        username: "preview_user",
        displayName: "Preview User",
        email: "preview@example.com",
        profilePicture: nil,
        creationDate: .now,
        lastSignIn: nil,
        providerRef: "preview_provider",
        selectedSubjects: ["Geography"],
        studyReminderTime: .now,
        studentType: "College",
        currentStreak: 1,
        longestStreak: 3,
        lastStudyDate: .now
    )

    let mockStackVM = StackViewModel()
    mockStackVM.stacks = [mockStack]

    let forgottenVM = ForgottenCardsViewModel()
    forgottenVM.localForgottenCards = [
        "stack1": Set(forgottenCards.map { $0.id })
    ]
    // Important: must call load to assign userID
    forgottenVM.load(for: "previewUser123")

    return StackDetailView(stack: mockStack)
        .environmentObject(mockStackVM)
        .environmentObject(mockAuth)
        .environmentObject(forgottenVM)
}
