//
//  CardStackView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/8/25.
//

import SwiftUI

import SwiftUI

struct CardStackView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    
    @State private var currentIndex = 0
    
    var stack: Stack
    var cards: [Card]
    
    var body: some View {
        VStack {
            if cards.isEmpty {
                Text("No Cards Available")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                CardView(presenter: FlipCardPresenter(), card: cards[currentIndex], stack: stack)

                // Navigation buttons
                HStack {
                    Button(action: {
                        if currentIndex > 0 {
                            currentIndex -= 1
                        }
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(currentIndex > 0 ? .blue : .gray)
                    }
                    .disabled(currentIndex == 0)

                    Spacer()

                    Button(action: {
                        if currentIndex < cards.count - 1 {
                            currentIndex += 1
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(currentIndex < cards.count - 1 ? .blue : .gray)
                    }
                    .disabled(currentIndex == cards.count - 1)
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
            }
        }
        .navigationTitle(stack.title)
    }
}

#Preview {
    CardStackView(
            stack: Stack(id: "1", title: "Sample Stack", description: "Test Description", creator: "User123", creationDate: Date(), tags: ["Swift"], cards: [
                Card(id: "1", front: "What is Swift?", back: "A programming language by Apple."),
                Card(id: "2", front: "What is Xcode?", back: "An IDE for Apple platforms.")
            ], isPublic: true),
            cards: []
        )
    .environmentObject(AuthViewModel())
    .environmentObject(StackViewModel())
}
