//
//  StudyStacksAppDelegate.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

class StudyStacksAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        let settings = Firestore.firestore().settings
        let cacheSettings = PersistentCacheSettings()
        settings.cacheSettings = cacheSettings
        Firestore.firestore().settings = settings
        
        return true
      }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
    
    //saves points to firebase at EOD AND resets points every week
    func scheduleEndOfDayPointUpdate() {
        let timer = Timer(fire: Calendar.current.nextDate(after: Date(), matching: DateComponents(hour: 23, minute: 59), matchingPolicy: .nextTime) ?? Date(), interval: 86400, repeats: true) { _ in
            Task {
                if PointsManager.shared.shouldResetPoints() {
                    PointsManager.shared.savePointsLocally(points: 0)
                }
                await AuthViewModel.shared.updatePointsInFirebase()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
    }
}
