//
//  Friend.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/31/25.
//

import Foundation

struct Friend: Identifiable, Codable {
    var id: String
    var username: String
    var displayName: String
    var email: String
    var creationDate: Date
    var currentStreak: Int
    //var badgeCount: Int
}

extension Friend: Hashable {
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
