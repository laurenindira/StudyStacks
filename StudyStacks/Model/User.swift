//
//  User.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import Foundation
import SwiftUI

struct User: Identifiable, Codable {
    var id: String
    var username: String
    var displayName: String
    var email: String
    var profilePicture: String? //TODO: potentially change to Image if we allow Firebase uploads
    var creationDate: Date
    var lastSignIn: Date?
    var providerRef: String
    
    //ONBOARDING
    var selectedSubjects: [String]
    var studyReminderTime: Date
    var studentType: String
    
    //STREAKS
    var currentStreak: Int
    var longestStreak: Int
    var lastStudyDate: Date?
    
    //points
    var points: Int

    //FAVORITES
    var favoriteStackIDs: [String]

}
