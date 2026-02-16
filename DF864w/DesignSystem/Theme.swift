//
//  Theme.swift
//  DF864w
//
//  GlowLab design system — semantic colors and tokens.
//

import SwiftUI

enum Theme {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum CornerRadius {
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum Typography {
        static func largeTitle(_ color: Color = Theme.Colors.primaryText) -> some View {
            Text("") // placeholder; use .font(.largeTitle) + color at call site
        }
    }
}

// MARK: - Semantic Colors (reference from Assets; use Theme to avoid conflict with generated asset symbols)
extension Theme {
    enum Colors {
        static let primaryBackground = Color("PrimaryBackground")
        static let secondaryBackground = Color("SecondaryBackground")
        static let cardSurface = Color("CardSurface")
        static let primaryText = Color("PrimaryText")
        static let secondaryText = Color("SecondaryText")
        static let accent = Color("Accent")
        static let accentMuted = Color("AccentMuted")
        static let divider = Color("Divider")
    }
}
