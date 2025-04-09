//
//  CardPreview.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/8/25.
//

import SwiftUI

struct CardPreview: View {
    var stack: Stack

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Card Placeholder
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surface)
                .frame(width: 140, height: 180)

            // Stack Details
            Text(stack.title)
                .font(.headline)
                .bold()
                .foregroundColor(Color.text)

            Text("\(String(stack.cards.count)) terms")
                .font(.caption)
                .foregroundColor(.secondaryText)
        }
        .frame(width: 140)
    }
}

#Preview {
    CardPreview(stack: Stack(id: "", title: "test time", description: "", creator: "farmer john", creatorID: "", creationDate: Date.now, tags: ["biology", "agriculture", "another", "another"], cards: [Card(front: "", back: ""), Card(front: "", back: "")], isPublic: true))
}
