//
//  EditStackView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/5/25.
//

import SwiftUI

struct EditStackView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var creator: String = ""
    @State private var creationDate: Date = Date.now
    @State private var tags: String = ""
//    @State private var cards: [Card] = []
    @State private var isPublic: Bool = false
    @State private var editedCards: [Card] = []
   
    @State private var cardFront: String = ""
    @State private var cardBack: String = ""
    
    @Binding var stack: Stack
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        //TITLE
                        Text("Edit Stack")
                            .font(.customHeading(.title))
                            .padding(.bottom, 20)
                        
                        //CARD INFORMATION
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Stack Title")
                                .font(.headline)
                            TextField("Stack Title", text: $title)
                                .textInputAutocapitalization(.never)
                                .padding(10)
                                .foregroundStyle(Color.secondaryText)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.surface)
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Description")
                                .font(.headline)
                            TextField("This stack is for...", text: $description, axis: .vertical)
                                .textInputAutocapitalization(.never)
                                .padding(10)
                                .foregroundStyle(Color.secondaryText)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.surface)
                                }
                        }
                        //TODO: add tags as dropdown instead of list
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Tags (comma-separated)")
                                .font(.headline)
                            TextField("eg. Biology, Midterm, Microbiology...", text: $tags)
                                .textInputAutocapitalization(.never)
                                .padding(10)
                                .foregroundStyle(Color.secondaryText)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.surface)
                                }
                        }
                        Toggle("Is deck public?", isOn: $isPublic)
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        Divider()
                        
                        //CARDS
                        VStack(alignment: .leading) {
                            Text("Cards")
                                .font(.headline)
                            
                            //EMPTY LIST
                            if editedCards.isEmpty {
                                //TODO: make prettier error message
                                Text("No cards here! You should add some")
                                    .padding()
                                    .frame(width: UIScreen.main.bounds.width * 0.9)
                            } else {
                                LazyVStack(alignment: .leading) {
                                    ForEach(editedCards.indices, id: \.self) { index in
                                        HStack(alignment: .center) {
                                            //TEXT
                                            VStack(alignment: .leading) {
                                                TextField("Front", text: $editedCards[index].front)
                                                    .font(.headline).bold()
                                                    .foregroundStyle(Color.prim)
                                                    .padding(.bottom, 5)
                                                    .overlay(
                                                        Rectangle()
                                                            .frame(height: 1)
                                                            .foregroundColor(Color.prim.opacity(0.5)), alignment: .bottom
                                                    )
                                                TextField("Back", text: $editedCards[index].back)
                                            }
                                            
                                            Spacer()
                                            
                                            //DELETE BUTTON
                                            Button(action: { deleteCard(at: index) }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(Color.stacksred)
                                                    .padding(5)
                                            }
                                        }
                                        
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.surface)
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            Divider()
                            
                            //NEW CARD
                            VStack(alignment: .leading) {
                                TextField("This is a word", text: $cardFront)
                                    .textInputAutocapitalization(.never)
                                    .font(.headline).bold()
                                    .foregroundStyle(Color.prim)
                                    .padding([.top, .bottom], 5)
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color.prim), alignment: .bottom
                                    )
                                TextField("This is a definition", text: $cardBack, axis: .vertical)
                                    .textInputAutocapitalization(.never)
                                    .padding([.top, .bottom], 5)
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(Color.secondary.opacity(0.5)), alignment: .bottom
                                    )
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.surface)
                            }
                            
                            Button {
                                addCard()
                            } label: {
                                GeneralButton(placeholder: "Add a Card", backgroundColor: Color.prim, foregroundColor: .white, imageRight: "plus", isSystemImage: true)
                            }
                            .disabled(cardFront.isEmpty || cardBack.isEmpty)
                            .padding(.top, 20)
                        }
                        
                    }
                }
                .padding()
                .onAppear {
                    title = stack.title
                    description = stack.description
                    creator = stack.creator
                    creationDate = stack.creationDate
                    tags = stack.tags.joined(separator: ", ")
                    editedCards = stack.cards
                    isPublic = stack.isPublic
                }
            }
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Update Stack") {
                        Task {
                            await saveStack()
                        }
                        stackVM.creatingStack = false
                        dismiss()
                    }
                    .disabled(title.isEmpty || editedCards.isEmpty)
                }
            }
        }
    }
    
    //FUNCTIONS
    private func addCard() {
        let newCard = Card(front: cardFront, back: cardBack, imageURL: nil)
        editedCards.append(newCard)
        cardFront = ""
        cardBack = ""
    }
    
    private func deleteCard(at index: Int) {
        guard index < editedCards.count else { return }
        editedCards.remove(at: index)
    }
    
    private func saveStack() async {
        guard let userID = auth.user?.id else {
            print("ERROR: User ID is nil")
            return
        }
        
        if !cardFront.isEmpty || !cardBack.isEmpty {
            let newCard = Card(front: cardFront, back: cardBack, imageURL: nil)
            editedCards.append(newCard)
            cardFront = ""
            cardBack = ""
        }

        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let updatedStack = Stack(
            id: stack.id,
            title: title,
            description: description.isEmpty ? "No description given" : description,
            creator: stack.creator,
            creationDate: stack.creationDate,
            tags: tagArray,
            cards: editedCards,
            isPublic: isPublic
        )
        
//        stack.cards = editedCards

        await stackVM.updateStack(for: userID, stackToUpdate: updatedStack)
        dismiss()
    }
    
}

#Preview {
    EditStackView(stack: .constant(Stack(
        id: "",
        title: "",
        description: "",
        creator: "",
        creationDate: Date(),
        tags: [],
        cards: [],
        isPublic: false
    )))
    .environmentObject(AuthViewModel())
    .environmentObject(StackViewModel())
}
