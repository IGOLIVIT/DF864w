//
//  LabeledSlider.swift
//  DF864w
//

import SwiftUI

struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    var format: (Double) -> String = { "\(Int($0))" }
    var onEditingChanged: ((Bool) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Theme.Colors.primaryText)
                Spacer()
                Text(format(value))
                    .font(.subheadline)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .monospacedDigit()
            }

            Slider(value: $value, in: range, step: step, onEditingChanged: { editing in
                onEditingChanged?(editing)
            })
                .tint(Theme.Colors.accent)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(format(value))
        .accessibilityAdjustableAction { direction in
            let stepAmount = direction == .increment ? step : -step
            value = min(range.upperBound, max(range.lowerBound, value + stepAmount))
        }
    }
}
