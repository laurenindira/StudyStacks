//
//  RecommendedStacksView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/8/25.
//

import SwiftUI

struct RecommendedStacksView: View {
    var stack: [Stack]
    var title: String
    var emptyMessage: String?
    var isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.customHeading(.headline))
                .bold()

            // Loading progress view
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    Spacer()
                }
                .frame(height: 100)
                .background(Color.surface)
                .cornerRadius(20)
            }
            else if stack.isEmpty {
                // Empty state
                HStack {
                    Text(emptyMessage ?? "No stacks available.")
                        .font(.headline)
                        .foregroundColor(Color.text)
                        .padding()
                    Spacer()
                }
                .frame(height: 100)
                .background(Color.surface)
                .cornerRadius(20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(stack) { stack in
                            NavigationLink(destination: StackDetailView(stack: stack)) {
                                CardPreview(stack: stack)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}


#Preview {
    RecommendedStacksView(
        stack: [],
        title: "Interest in Psychology",
        emptyMessage: "No stacks found for your interest.",
        isLoading: true
    )
}
