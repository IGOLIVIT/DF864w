//
//  PrimaryButton.swift
//  DF864w
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var style: Style = .filled

    enum Style {
        case filled
        case secondary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style == .filled ? .white : Theme.Colors.accent))
                        .scaleEffect(0.9)
                } else {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .accessibilityLabel(title)
        .accessibilityHint(isLoading ? "Loading" : "Button")
    }

    private var backgroundColor: Color {
        switch style {
        case .filled: return Theme.Colors.accent
        case .secondary: return Theme.Colors.cardSurface
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .filled: return .white
        case .secondary: return Theme.Colors.primaryText
        }
    }
}

#Preview("PrimaryButton") {
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue", action: {})
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
        PrimaryButton(title: "Secondary", action: {}, style: .secondary)
    }
    .padding()
    .background(Theme.Colors.primaryBackground)
}
