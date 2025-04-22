//
//  PrivacyView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 4/16/25.
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .customHeading(.title)

                Text("We value your privacy and are committed to protecting your personal information. This policy outlines how we handle your data.")
                    .font(.body)
                    .foregroundColor(.secondary)

                SectionView(
                    title: "Data Collection",
                    content: "We only collect data necessary to provide core functionality. We do not sell or share your data with third parties."
                )

                SectionView(
                    title: "Data Storage",
                    content: "All data is securely stored using industry-standard encryption and protection practices."
                )

                SectionView(
                    title: "Third-Party Services",
                    content: "Our app may use trusted third-party services for analytics or crash reporting, which are subject to their own privacy policies."
                )

                SectionView(
                    title: "Your Rights",
                    content: "You have the right to access, update, or delete your personal data at any time. Contact us through the app for assistance."
                )

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SectionView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        PrivacyView()
    }
}
