//
//  SmallSubjectTags.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/9/25.
//

import SwiftUI

struct SmallSubjectTags: View {
    var subjectTags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(subjectTags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .foregroundColor(tagColor(for: tag)[1])
                        .padding(.vertical, 2)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(tagColor(for: tag)[0])
                        )
                }
            }
        }
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
