//
//  SecureTextField.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct SecureTextField: View {
    var placeholder: String
    @State var showPassword: Bool
    @Binding var text: String
    
    var body: some View {
        if showPassword {
            GeneralTextField(placeholder: placeholder, text: $text)
                .textContentType(.password)
                .overlay(alignment: .trailing) {
                    Button(role: .cancel) {
                        withAnimation(.easeIn) {
                            showPassword = false
                        }
                    } label: {
                        Image(systemName: "eye")
                            .foregroundStyle(Color.prim.opacity(0.8))
                            .padding()
                            .contentTransition(.symbolEffect)
                    }
                }
        } else {
            SecureField(placeholder, text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .foregroundStyle(Color.secondaryText)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.surface)
                        .stroke(Color.secondaryText.opacity(0.25), style: StrokeStyle(lineWidth: 0.5))
                }
                .overlay(alignment: .trailing) {
                    Button(role: .cancel) {
                        withAnimation(.easeIn) {
                            showPassword = true
                        }
                    } label: {
                        Image(systemName: "eye.slash")
                            .foregroundStyle(Color.prim.opacity(0.8))
                            .padding()
                            .contentTransition(.symbolEffect)
                    }
                }
        }
    }
}

#Preview {
    SecureTextField(placeholder: "This is placeholder text", showPassword: false, text: .constant(""))
}
