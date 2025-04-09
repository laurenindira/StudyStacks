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
        Text("\(number) \(text)")
            .font(.customHeading(.headline))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(width: 175, height: 80)
            .background(Color.prim)
            .cornerRadius(20)
    }
}


#Preview {
    StatCardView(number: 7, text: "day streak")
}
