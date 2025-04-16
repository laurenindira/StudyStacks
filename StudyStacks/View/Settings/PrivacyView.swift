//
//  PrivacyView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 4/16/25.
//


import SwiftUI

struct PrivacyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Privacy Policy")
                .customHeading(.title)

            Text("We value your privacy. Your data is encrypted and securely stored. Read our full privacy policy to learn more.")
                .font(.body)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    PrivacyView()
}