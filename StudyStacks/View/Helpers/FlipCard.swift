//
//  FlipCard.swift
//  StudyStacks
//
//  Created by Raihana Zahra on 3/3/25.
//
// medium.com/@nikhil.vinod/create-a-card-flip-animation-in-swiftui-fe14b850b1f5

import Foundation
import SwiftUI

// Protocol defining the behavior of a flip card
protocol FlipCardProtocol: ObservableObject {
    var isFlipped: Bool { get }
    func flipButtonTapped()
}

// Manages the flip card state
class FlipCardPresenter: FlipCardProtocol {
    @Published var isFlipped: Bool = false

    func flipButtonTapped() {
        isFlipped.toggle()
    }
}

