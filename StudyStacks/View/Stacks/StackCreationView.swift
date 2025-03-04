//
//  StackCreationView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/4/25.
//

import SwiftUI

struct StackCreationView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackService: StackViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var creator: String = ""
    @State private var creationDate: Date = Date.now
    @State private var tags: String = ""
    @State private var cards: [Card] = []
    @State private var isPublic: Bool = false
   
    @State private var cardFront: String = ""
    @State private var cardBack: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("Card Information")
                        GeneralTextField(placeholder: "title", text: $title)
                        GeneralTextField(placeholder: "Tags (comma-separated)", text: $tags)
                        Toggle(isOn: $isPublic) {
                            Text("Is this deck public?")
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Cards")
                        if cards.isEmpty {
                            Text("no cards added")
                        } else {
                            ForEach(cards) { card in
                                CardInputDisplay(card: card)
                            }
                        }
                    }
                    
                    VStack {
                        GeneralTextField(placeholder: "front", text: $cardFront)
                        GeneralTextField(placeholder: "back", text: $cardBack)
                        Button {
                            addCard()
                        } label: {
                            HStack {
                                Text("Add Card")
                                Image(systemName: "plus")
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.prim)
                            }
                        }
                        .disabled(cardFront.isEmpty || cardBack.isEmpty)
                    }
                    
                    Button {
                        Task {
                            await saveStack()
                            dismiss()
                        }
                    } label: {
                        Text("Save Stack")
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.prim)
                            }
                    }
                    .disabled(title.isEmpty || cards.isEmpty)
                }
                .padding()
                
            }
        }
    }
    
    private func addCard() {
        let newCard = Card(front: cardFront, back: cardBack, imageURL: nil)
        cards.append(newCard)
        cardFront = ""
        cardBack = ""
    }
    
    private func deleteCard(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
    }
    
    private func saveStack() async {
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let newStack = Stack(id: "", title: title, creator: auth.user?.username ?? "unknown", creationDate: Date(), tags: tagArray, cards: cards, isPublic: isPublic)
        
        let userID = (auth.user?.id)!
        await stackService.createStack(for: userID, stackToAdd: newStack)
    }
    
}



#Preview {
    StackCreationView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
