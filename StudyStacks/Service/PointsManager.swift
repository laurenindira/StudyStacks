//
//  PointsManager.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/3/25.
//

import Foundation
import FirebaseFirestore

class PointsManager {
    static let shared = PointsManager()
    
    func loadPoints() -> Int {
        return UserDefaults.standard.integer(forKey: "userPoints")
    }
    
    func savePointsLocally(points: Int) {
        UserDefaults.standard.set(points, forKey: "userPoints")
    }
    
    func shouldResetPoints() -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekday, .hour], from: now)
        return (components.weekday == 1 && components.hour == 23)
    }
    
    func addPoints(points: Int, completion: @escaping (String?) -> Void) {
        var currentPoints = loadPoints()
        currentPoints += points
        savePointsLocally(points: currentPoints)
        print("SUCCESS: Points added. New total: \(currentPoints)")

        guard var user = AuthViewModel.shared.user else {
            completion(nil)
            return
        }

        user.points = currentPoints
        checkPointBadgeEligibility(user: &user, newTotal: currentPoints, completion: completion)

        if let encodedUser = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encodedUser, forKey: "cachedUser")
        }
    }

    private func checkPointBadgeEligibility(user: inout User, newTotal: Int, completion: @escaping (String?) -> Void) {
        let thresholds: [Int: String] = [
            5: "5_Points",
            25: "25_Points",
            100: "100_Points"
        ]

        guard let userID = user.id as String? else {
            completion(nil)
            return
        }

        let earned = user.earnedBadges

        for (threshold, badgeID) in thresholds where newTotal >= threshold && !earned.contains(badgeID) {
            user.earnedBadges.append(badgeID)
            AuthViewModel.shared.user = user
            let updatedBadges = user.earnedBadges

            Task {
                do {
                    try await Firestore.firestore()
                        .collection("users")
                        .document(userID)
                        .updateData(["earnedBadges": updatedBadges])
                    print("SUCCESS: Awarded badge \(badgeID)")
                    completion(badgeID)
                } catch {
                    print("ERROR: Could not update badge for points - \(error.localizedDescription)")
                    completion(nil)
                }
            }
            return
        }
    }
}
