//
//  CardView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/3/25.
//
// medium.com/@nikhil.vinod/create-a-card-flip-animation-in-swiftui-fe14b850b1f5
// medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8

import SwiftUI

struct CardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var presenter: FlipCardPresenter
    
    enum SwipeDirection {
        case left, right, none
    }
    
    var card: Card
    var stack: Stack
    
    var dragOffset: CGSize
    var isTopCard: Bool
    var isSecondCard: Bool

    var body: some View {
        // card & card flipping
        ZStack {
            // front side, term
            Rectangle()
                .foregroundColor(Color.surface)
                .cornerRadius(20)
                .frame(width: 340, height: 524)
                .overlay(
                    Text(card.front)
                        .font(.title)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                )
                .opacity(presenter.isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(presenter.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            
            // back side, definition
            Rectangle()
                .foregroundColor(Color.surface)
                .cornerRadius(20)
                .frame(width: 340, height: 524)
                .overlay(
                    Text(card.back)
                        .font(.title)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // mirrors text properly
                )
                .opacity(presenter.isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(presenter.isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))

        }
        .rotation3DEffect(.degrees(presenter.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.default, value: presenter.isFlipped)
        .onTapGesture {
            presenter.flipButtonTapped()
        }
        .frame(width: 340, height: 524)
    }
}

#Preview {
    CardView(
        presenter: FlipCardPresenter(),
        card: Card(id: "1", front: "agile methodologies", back: "scrum"),
        stack: Stack(
            id: "1",
            title: "bj class",
            description: "project management",
            creator: "jane",
            creatorID: "",
            creationDate: Date(),
            tags: ["cs"],
            cards: [],
            isPublic: true
        ),
        dragOffset: .zero,
        isTopCard: true,
        isSecondCard: false
    )
    .environmentObject(AuthViewModel())
    .environmentObject(StackViewModel())
}
