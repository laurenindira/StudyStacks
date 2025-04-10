//
//  NotificationManager.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/8/25.
//
// help from: https://developer.apple.com/documentation/usernotifications/scheduling-a-notification-locally-from-your-app
//

import Foundation
import UserNotifications

struct NotificationManager {
    
    static func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("SUCCESS: Authorization given")
            } else if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    static func scheduleNotification(notificationTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "It's time to shake up some stacks"
        content.body = "Keep your study streak going!"
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    
        let request = UNNotificationRequest(identifier: "studyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    static func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["studyReminder"])
    }
}

struct DateHelper {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
