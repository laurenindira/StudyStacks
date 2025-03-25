//
//  SubjectTags.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/12/25.
//

import SwiftUI

struct SubjectTags: View {
    var subjectTags: [String]
    
    var body: some View {
        //TAGS ASSOCIATED
        ScrollView(.horizontal) {
            HStack {
                ForEach(subjectTags, id: \.self) { tag in
                    Text(tag)
                        .font(.callout)
                        .foregroundStyle(tagColor(for: tag)[1])
                        .frame(minWidth: 100)
                        .padding(3)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(tagColor(for: tag)[0])
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private func tagColor(for subjectTags: String) -> [Color] {
        switch subjectTags.lowercased() {
        case "english":
            return [Color.stacksviolet, Color.lod]
        case "chemistry":
            return [Color.stacksindigo, Color.lod]
        case "biology":
            return [Color.stacksgreen, Color.lod]
        case "computer science":
            return [Color.stacksblue, Color.lod]
        case "geography":
            return [Color.stacksorange, Color.text]
        case "spanish":
            return [Color.stacksyellow, Color.text]
        case "psychology":
            return [Color.stacksred, Color.lod]
        default:
            return [Color.disabled, Color.text]
        }
    }
}
