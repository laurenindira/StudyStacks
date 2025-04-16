//
//  SearchBar.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/26/25.
//

import SwiftUI

struct SearchBar: View {
    @State var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .font(.callout)
                .foregroundStyle(Color.stacksgray)
            TextField("Looking for something specific?", text: $searchText)
                .foregroundStyle(Color.secondaryText)
            if !searchText.isEmpty {
                Button(action: { self.searchText = ""}) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.stacksgray)
                }
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surface)
        }
    }
}

#Preview {
    SearchBar(searchText: "")
}
