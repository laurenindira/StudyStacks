//
//  TermsListView.swift
//  StudyStacks
//
//  Created by Giselle Eliasi on 3/17/25.
//

import SwiftUI

struct TermsListView: View {
    var cards: [Card]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Terms:")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 8)
                .padding(.leading, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(cards) { card in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.front)
                                    .font(.headline)
                                    .foregroundColor(Color.prim)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(card.back)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, minHeight: 100)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

struct TermsListView_Previews: PreviewProvider {
    static var previews: some View {
        TermsListView(cards: [
            Card(front: "California", back: "Sacramento"),
            Card(front: "Texas", back: "Austin"),
            Card(front: "Florida", back: "Tallahassee"),
            Card(front: "New York", back: "Albany"),
            Card(front: "Illinois", back: "Springfield")
        ])
    }
}
