//
//  GeneralTextField.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct GeneralTextField: View {
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .padding()
            .foregroundStyle(Color.secondaryText)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.surface)
                    .stroke(Color.secondaryText.opacity(0.25), style: StrokeStyle(lineWidth: 0.5))
            }
    }
}

#Preview {
    GeneralTextField(placeholder: "", text: .constant(""))
}
