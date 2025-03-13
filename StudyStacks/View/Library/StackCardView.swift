//
//  StackCardView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/12/25.
//

import SwiftUI

struct StackCardView: View {
    var stack: Stack
    var isFavorite: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surface)
            
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 10) {
                    //TITLE + FAVORITES
                    HStack(alignment: .center) {
                        Text(stack.title)
                            .customHeading(.title2)
                            .lineLimit(2)
                            .truncationMode(.tail)
                        
                        Spacer()
                        
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .font(.largeTitle)
                            .foregroundStyle(Color.sec)
                    }
                    
                    //SUBJECT TAGS
                    SubjectTags(subjectTags: stack.tags)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                //STACK INFO
                VStack(alignment:.leading, spacing: 3) {
                    Text("created by \(stack.creator)")
                    Text("\(String(stack.cards.count)) terms")
                }
                .font(.callout)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    StackCardView(stack: Stack(id: "", title: "test time", description: "", creator: "farmer john", creationDate: Date.now, tags: ["biology", "agriculture", "another", "another"], cards: [Card(front: "", back: ""), Card(front: "", back: "")], isPublic: true), isFavorite: true)
}
