//
//  AboutView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 4/15/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("About StudyStacks")
                    .customHeading(.title)
                
                Text("""
StudyStacks is an iOS application designed to help users create, share, and study flashcards with ease, right from their mobile devices. Whether you're preparing for an exam or just love to learn, StudyStacks offers an intuitive interface and powerful features to support your study goals.

Key features include:
• Seamless flashcard stack creation  
• Personalized study reminders      
• Stack discovery based on your favorite topics  
• Progress tracking with streaks and badges  
• Stack sharing with friends

We’re building a platform that empowers continuous learning—anytime, anywhere.
""")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Link(destination: URL(string: "https://github.com/laurenindira/StudyStacks")!) {
                    HStack {
                        Image(systemName: "link")
                        Text("View our GitHub Repository")
                    }
                    .font(.headline)
                    .foregroundColor(.prim)
                }
                .padding(.top, 10)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutView()
}
