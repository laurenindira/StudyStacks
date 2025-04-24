//
//  BadgePopupView.swift
//  StudyStacks
//
//  Created by brady katler on 4/15/25.
//

import SwiftUI

struct BadgePopupView: View {
    let badgeID: String
    let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 20) {
                Image(badgeID)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)

                Text("🎉 You earned the \(badgeID.replacingOccurrences(of: "_", with: " ")) badge!")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .padding(.horizontal)

                Button {
                    dismiss()
                } label: {
                    Text("Nice!")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(40)

            // Optional X dismiss button
            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(12)
            }
        }
        .transition(.scale)
    }
}
