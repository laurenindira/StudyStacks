//
//  ErrorView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/13/25.
//

import SwiftUI

struct ErrorView: View {
    var errorMessage: String
    var imageName: String
    var isSystemImage: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            if isSystemImage {
                Image(systemName: imageName)
                    .font(.system(size: 75))
            } else {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
            }
            
            Text(errorMessage)
                .font(.title2).bold()
                .foregroundStyle(Color.prim)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
    }
}

#Preview {
    ErrorView(errorMessage: "womp womp no stacks some more text so that i can test alignment", imageName: "surfboard", isSystemImage: true)
}
