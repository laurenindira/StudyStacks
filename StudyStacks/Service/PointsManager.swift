//
//  PointsManager.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/3/25.
//

import Foundation

class PointsManager {
    static let shared = PointsManager()
    
    func loadPoints() -> Int {
        return UserDefaults.standard.integer(forKey: "userPoints")
    }
    
    func savePointsLocally(points: Int) {
        return UserDefaults.standard.set(points, forKey: "userPoints")
    }
    
    func shouldResetPoints() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .hour], from: now)
        return (components.weekday == 1 && components.hour == 23)
    }
    
    func addPoints(points: Int) {
        var currentPoints = loadPoints()
        currentPoints += points
        savePointsLocally(points: currentPoints)
        print("SUCCESS: Points added. New total: \(currentPoints)")
        
        var user = AuthViewModel.shared.user
        user?.points = currentPoints
        
        if UserDefaults.standard.data(forKey: "cachedUser") != nil {
            if let encodedUser = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encodedUser, forKey: "cachedUser")
            }
        }
    }
}
