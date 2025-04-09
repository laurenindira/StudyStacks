//
//  NameInputOnboarding.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/5/25.
//

import SwiftUI

struct NameInputOnboarding: View {
    @Binding var user: User
    @Binding var step: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("So, what do you want us to call you?")
                .font(.headline)
            
            GeneralTextField(placeholder: "enter your name", text: $user.displayName)
            
            Button {
                if !user.displayName.isEmpty { step += 1 }
            } label: {
                GeneralButton(placeholder: "Next", backgroundColor: Color.prim, foregroundColor: Color.lod, imageRight: "arrow.right", isSystemImage: true)
            }
            .disabled(user.displayName.isEmpty)
            .opacity((user.displayName == "") ? 0.5 : 1)
            .padding(.top, 20)
            
        }
        .padding()
        
    }
}

#Preview {
    StudyReminderOnboarding(
        user: .constant(User(
            id: "",
            username: "",
            displayName: "",
            email: "",
            creationDate: Date.now,
            providerRef: "",
            selectedSubjects: [],
            studyReminderTime: Date.now,
            studentType: "",
            currentStreak: 0,
            longestStreak: 0,
            points: 0  
        )),
        step: .constant(1)
    )
}
