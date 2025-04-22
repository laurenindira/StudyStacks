//
//  WeeklyProgressView.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 4/8/25.
//

import SwiftUI

struct WeeklyProgressView: View {
    var rank: String?
    var cardsStudied: Int?

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Text("Weekly Progress")
                .font(.customHeading(.title))
                .foregroundColor(Color.text)

            HStack(alignment: .center, spacing: 40) {
                // Leaderboard Icon
                Image(systemName: "chart.bar.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.text)
                    .padding(.leading, 25)

                // Leaderboard and Weekly Points
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(rank ?? "1st")
                            .font(.customHeading(.title2))
                        Text("on leaderboard")
                            .font(.headline)
                            .foregroundColor(Color.text)
                    }

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(cardsStudied ?? 0)")
                            .font(.customHeading(.title2))
                        Text("cards studied")
                            .font(.headline)
                            .foregroundColor(Color.text)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .cornerRadius(25)
    }
}


#Preview {
    WeeklyProgressView()
}
