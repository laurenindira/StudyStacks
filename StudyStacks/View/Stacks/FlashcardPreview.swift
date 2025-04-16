//
//  FlashcardPreview.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/16/25.
//

import SwiftUI

struct FlashcardPreview: View {
    let stack: Stack
    
    @State private var isFlipped = false
    @State private var currentCardIndex = 0

    var body: some View {
        let currentCard = stack.cards[currentCardIndex]
        
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 340, height: 200)
                .overlay(
                    ZStack {
                        if !isFlipped {
                            Text(currentCard.front)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 1, y: 0, z: 0))
                                .opacity(isFlipped ? 0 : 1)
                        } else {
                            Text(currentCard.back)
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
                        .padding(.leading, 20)
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
                        .padding(.trailing, 20)
                }
            }
            .padding(.horizontal, 24)
            .foregroundColor(.gray)
        }
    }
}


#Preview {
    let sampleCards = [
        Card(id: "1", front: "France", back: "Paris"),
        Card(id: "2", front: "Japan", back: "Tokyo"),
        Card(id: "3", front: "Brazil", back: "Brasília")
    ]

    let sampleStack = Stack(
        id: "sampleStack",
        title: "World Capitals",
        description: "A stack of capital cities",
        creator: "Raihana",
        creatorID: "user123",
        creationDate: .now,
        tags: ["Geography"],
        cards: sampleCards,
        isPublic: true
    )

    FlashcardPreview(stack: sampleStack)
}
