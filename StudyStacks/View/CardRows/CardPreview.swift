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
                .foregroundColor(Color.text)
                .lineLimit(1)
                .truncationMode(.tail)

            SmallSubjectTags(subjectTags: stack.tags)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 140)
    }
}

#Preview {
    CardPreview(stack: Stack(id: "", title: "test time bleep bloop blap", description: "", creator: "farmer john", creatorID: "", creationDate: Date.now, tags: ["biology", "geography", "computer science", "another"], cards: [Card(front: "", back: ""), Card(front: "", back: "")], isPublic: true))
}
