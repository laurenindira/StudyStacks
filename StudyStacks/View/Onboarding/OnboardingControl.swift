//
//  OnboardingControl.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/5/25.
//

import SwiftUI

struct OnboardingControl: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var user: User
    @State private var step: Int = 1
    var body: some View {
        VStack {
            if step == 1 {
                NameInputOnboarding(user: $user, step: $step)
            } else if step == 2 {
                SubjectSelectionOnboarding(user: $user, step: $step)
            } else if step == 3 {
                StudyReminderOnboarding(user: $user, step: $step)
            } else if step == 4 {
                StudentTypeOnboarding(user: $user, step: $step)
            }
            
            
        }
        .animation(.easeInOut, value: step)
    }
}

#Preview {
    OnboardingControl(user: .constant(User(id: "", username: "", displayName: "", email: "", creationDate: Date.now, providerRef: "", selectedSubjects: [], studyReminderTime: Date.now, studentType: "", currentStreak: 0, longestStreak: 0)))
        .environmentObject(AuthViewModel())
}
