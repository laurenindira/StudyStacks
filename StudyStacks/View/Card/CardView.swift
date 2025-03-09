//
//  CardView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/3/25.
//
// medium.com/@nikhil.vinod/create-a-card-flip-animation-in-swiftui-fe14b850b1f5

import SwiftUI

struct CardView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    
    @ObservedObject var presenter: FlipCardPresenter
    
    var card: Card
    var stack: Stack

    var body: some View {
        
        // deck title and close button
        ZStack(alignment: .topLeading) {
            VStack {
                HStack {
                    Text(stack.title)
                        .customHeading(.title2)
                        .bold()
                        .padding(.leading, 20)
                    
                    Spacer()
                    
                    Button(action: {
                        // Add close action, close out to stack detail
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                .padding(.top, 10)
                
                Spacer()
                    .frame(height: 50)
            }
        }
        
        
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
        
        Spacer()

        // remember it section
        HStack {
            Button(action: {
                // Add thumbs-down action, save to firebase
            }) {
                Image(systemName: "hand.thumbsdown.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
            }
            
            Text("remember it?")
                .font(.body)
                .foregroundColor(.black)
                .padding(.horizontal)
            
            Button(action: {
                // Add thumbs-up action, save to firebase
            }) {
                Image(systemName: "hand.thumbsup.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.green)
            }
        }
        .padding(.bottom, 40)
    }

}

#Preview {
    CardView(
        presenter: FlipCardPresenter(),
        card: Card(id: "1", front: "agile methodologies", back: "scrum"),
        stack: Stack(id: "1", title: "bj class", description: "project managment", creator: "jane", creationDate: Date(), tags: ["cs"], cards: [], isPublic: true)
    )
    .environmentObject(AuthViewModel())
    .environmentObject(StackViewModel())
}
