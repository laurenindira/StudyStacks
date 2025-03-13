//
//  Stack.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/4/25.
//

import Foundation
import SwiftUI

struct Stack: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var creator: String
    var creationDate: Date
    var tags: [String]
    var cards: [Card]
    var isPublic: Bool
}

extension Stack: Hashable {
    static func == (lhs: Stack, rhs: Stack) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Card: Identifiable, Codable {
    var id: String = UUID().uuidString
    var front: String
    var back: String
    var imageURL: String?
}
