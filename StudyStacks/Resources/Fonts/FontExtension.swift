//
//  FontExtension.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

extension Font {
    static func customHeading(_ style: Font.TextStyle) -> Font {
        let fontName = "DaysOne-Regular"
        switch style {
        case .largeTitle:
            return .custom(fontName, size: 34)
        case .title:
            return .custom(fontName, size: 28)
        case .title2:
            return .custom(fontName, size: 22)
        case .title3:
            return .custom(fontName, size: 20)
        default:
            return .custom(fontName, size: 17)
        }
    }
}

struct CustomHeadingModifier: ViewModifier {
    var style: Font.TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(.customHeading(style))
    }
}

extension View {
    func customHeading(_ style: Font.TextStyle) -> some View {
        self.modifier(CustomHeadingModifier(style: style))
    }
}
