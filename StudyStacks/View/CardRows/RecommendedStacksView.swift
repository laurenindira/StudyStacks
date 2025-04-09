//
//  RecommendedStacksView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/8/25.
//

import SwiftUI

struct RecommendedStacksView: View {
    var stack: [Stack]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Heard you were interested in...")
                .font(.customHeading(.headline))
                .bold()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(stack) { stack in
                        CardPreview(stack: stack)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical)
        .padding(.horizontal)
    }
}



#Preview {
    RecommendedStacksView(stack: [
        Stack(id: "1", title: "Test Time", description: "", creator: "Farmer John", creatorID: "", creationDate: .now, tags: ["biology", "agriculture"], cards: [], isPublic: true),
        Stack(id: "2", title: "Photosynthesis", description: "", creator: "Farmer Jane", creatorID: "", creationDate: .now, tags: ["science"], cards: [], isPublic: true)
    ])
}
