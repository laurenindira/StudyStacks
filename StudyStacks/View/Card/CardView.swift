//
//  CardView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/3/25.
//
// medium.com/@nikhil.vinod/create-a-card-flip-animation-in-swiftui-fe14b850b1f5

import SwiftUI

struct CardView: View {
    var term: String
    var definition: String
    @ObservedObject var presenter: FlipCardPresenter

    var body: some View {
        Rectangle()
            .foregroundColor(Color.surface)
            .cornerRadius(20)
            .frame(width: 340, height: 524)
            .onTapGesture {
                presenter.flipButtonTapped()
            }
            .rotation3DEffect(.degrees(presenter.isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
            .animation(.default, value: presenter.isFlipped)

    }
}

#Preview {
    CardView(term: "Front of Card", definition: "Back of Card", presenter: FlipCardPresenter())
}
