//
//  ProfileRow.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/23/25.
//

import SwiftUI

struct ProfileRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
            Spacer()
            Text(value)
                .bold()
                .foregroundStyle(Color.prim)
        }
    }
}
