//
//  AuthManager.swift
//  ProfileApp
//
//  Created by brady katler on 3/3/25.
//

import SwiftUI

class AuthManager: ObservableObject {
    @Published var user = User(
        name: "John Michael",
        username: "@dasani4ever",
        memberSince: "Member since 2067",
        streak: 126,
        stacks: 5,
        badges: 2
    )
}
