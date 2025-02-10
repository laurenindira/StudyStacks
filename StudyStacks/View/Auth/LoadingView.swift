//
//  LoadingView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct LoadingView: View {
    var description: String
    
    var body: some View {
        Color.over.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack (alignment: .center) {
                    ProgressView(description)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .scaleEffect(2)
                        .foregroundStyle(Color.white)
                        .font(.callout).bold()
                }
            )
    }
}

#Preview {
    LoadingView(description: "creating account...")
}
