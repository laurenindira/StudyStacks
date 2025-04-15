//
//  StatCardView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/8/25.
//

import SwiftUI

struct StatCardView: View {
    var number: Int
    var text: String

    var body: some View {
        HStack(spacing: 4) {
            Text("\(number)")
                .font(.headline)
                .foregroundColor(.white)

            Text(text)
                .font(.body)
                .foregroundColor(.white)
        }
        .multilineTextAlignment(.center)
        .frame(width: 175, height: 80)
        .background(Color.prim)
        .cornerRadius(20)
    }
}



#Preview {
    StatCardView(number: 7, text: "day streak")
}
