//
//  EmptyStateView.swift
//  DF864w
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(Theme.Colors.secondaryText)

            VStack(spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.Colors.primaryText)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            if let buttonTitle, let buttonAction {
                PrimaryButton(title: buttonTitle, action: buttonAction)
                    .frame(maxWidth: 280)
                    .padding(.top, Theme.Spacing.sm)
            }
        }
        .padding(Theme.Spacing.xl)
    }
}

#Preview("EmptyState") {
    EmptyStateView(
        icon: "photo.on.rectangle.angled",
        title: "No Photos Yet",
        message: "Import a photo to start adding premium glow effects.",
        buttonTitle: "Import Photo",
        buttonAction: {}
    )
    .background(Theme.Colors.primaryBackground)
}
