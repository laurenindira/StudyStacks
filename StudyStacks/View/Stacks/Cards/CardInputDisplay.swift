//
//  CardInputDisplay.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/4/25.
//

import SwiftUI

struct CardInputDisplay: View {
    var card: Card
    //TODO: add something so that one side can be a picture
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(card.front)
                .bold()
            Text(card.back)
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.95)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surface)
        }
    }
}

#Preview {
    CardInputDisplay(card: Card(front: "this is a much longer and sorta unweildy definition", back: "this is a word"))
}
