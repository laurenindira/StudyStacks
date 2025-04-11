//
//  NotificationSettings.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/9/25.
//

import SwiftUI

struct NotificationSettings: View {
    @EnvironmentObject var auth: AuthViewModel
    @AppStorage("isScheduled") var isScheduled = false
    @AppStorage("notificationTime") var notificationTime: Date = Date()
    
    @State var isEditing: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Notification Settings")
                    .customHeading(.title)
                
                Toggle("Allow study reminders", isOn: $isScheduled)
                    .tint(Color.prim)
                    .onChange(of: isScheduled) { isScheduled in
                        handleIsScheduledChange(isScheduled: isScheduled)
                    }
                
                HStack {
                    Text("Reminder Time")
                    Spacer()
                    Text(auth.user?.studyReminderTime ?? Date(), style: .time)
                        .font(.headline)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.surface)
                        }
                }
                
                if isScheduled && isEditing {
                    DatePicker("", selection: Binding(
                        get: {
                            auth.user?.studyReminderTime ?? Date()
                        },
                        set: {
                            notificationTime = $0
                        }
                    ), displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                }
                
                Spacer()
                
                if isEditing {
                    Button {
                        isEditing.toggle()
                        Task {
                            if notificationTime != auth.user?.studyReminderTime {
                                handleNotificationTimeChange()
                                guard let user = auth.user else {
                                   print("user not logged in")
                                   return
                                }
                                await auth.updateStudyReminder(for: user.id, newReminderTime: notificationTime)
                                await auth.loadUserFromFirebase()
                            }
                        }
                    } label: {
                        GeneralButton(placeholder: "Done Editing", backgroundColor: Color.stacksgreen, foregroundColor: Color.white, isSystemImage: false)
                    }
                } else {
                    Button {
                        isEditing.toggle()
                    } label: {
                        GeneralButton(placeholder: "Edit Reminder", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                    }
                }
            }
            .padding()
        }
    }
}

private extension NotificationSettings {
    private func handleIsScheduledChange(isScheduled: Bool) {
        if isScheduled {
            NotificationManager.requestNotificationAuthorization()
            NotificationManager.scheduleNotification(notificationTime: notificationTime)
        } else {
            NotificationManager.cancelNotification()
        }
    }
    
    private func handleNotificationTimeChange() {
        NotificationManager.cancelNotification()
        NotificationManager.requestNotificationAuthorization()
        NotificationManager.scheduleNotification(notificationTime: notificationTime)
    }
}

#Preview {
    NotificationSettings()
        .environmentObject(AuthViewModel())
}
