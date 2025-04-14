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
            // Card Image
            Image(CoverImage(from: stack.tags))
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 180)
                .clipped()
                .cornerRadius(20)

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
    
    
    //
    private func CoverImage(from tags: [String]) -> String {
        let validTags: Set<String> = [
            "accounting", "biology", "chemistry", "computer science",
            "english", "geography", "history",
            "physics", "psychology", "spanish"
        ]

        for tag in tags {
            let lower = tag.lowercased()
            if validTags.contains(lower) {
                return lower
            }
        }

        return "default"
    }

}

#Preview {
    CardPreview(stack: Stack(id: "", title: "test time bleep bloop blap", description: "", creator: "farmer john", creatorID: "", creationDate: Date.now, tags: ["beelp", "geography", "computer science", "another"], cards: [Card(front: "", back: ""), Card(front: "", back: "")], isPublic: true))
}
