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
