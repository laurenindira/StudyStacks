//
//  StudyReminderOnboarding.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/5/25.
//

import SwiftUI

struct StudyReminderOnboarding: View {
    @Binding var user: User
    @Binding var step: Int
    
    @State var notificationAuth: Bool = false
    
    var body: some View {
        VStack(spacing: 15) {
            
            Text("Great! Now when should we remind you to study?")
                .font(.headline)
            
            DatePicker("", selection: $user.studyReminderTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
            
            Button {
                NotificationManager.requestNotificationAuthorization()
                notificationAuth = true
            } label: {
                GeneralButton(placeholder: "Allow Notifications", backgroundColor: Color.prim, foregroundColor: Color.lod, isSystemImage: false)
            }
            
            Button {
                step += 1
            } label: {
                GeneralButton(placeholder: "Next", backgroundColor: Color.prim, foregroundColor: Color.lod, imageRight: "arrow.right", isSystemImage: true)
            }
            .disabled(!notificationAuth)
            .opacity(!notificationAuth ? 0.5 : 1)
            .padding(.top, 20)
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button() {
                    step -= 1
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body)
                        Text("Back")
                    }
                    .foregroundStyle(Color.prim)
                }
            }
        }
    }
}

#Preview {
    StudyReminderOnboarding(user: .constant(User(id: "", username: "", displayName: "", email: "", creationDate: Date.now, providerRef: "", selectedSubjects: [], studyReminderTime: Date.now, studentType: "", currentStreak: 0, longestStreak: 0, points: 0, favoriteStackIDs: [])), step: .constant(3))
}
