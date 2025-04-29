//
//  MultiSelectPicker.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/23/25.
//

import SwiftUI

struct MultiSelectPicker: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .foregroundStyle(Color.prim)
                }
            }
        }
    }
}
