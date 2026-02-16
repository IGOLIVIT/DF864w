//
//  OnboardingView.swift
//  DF864w
//

import SwiftUI
import UIKit

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            TabView(selection: $currentPage) {
                OnboardingPage1(onNext: { currentPage = 1 })
                    .tag(0)
                OnboardingPage2(onNext: { currentPage = 2 })
                    .tag(1)
                OnboardingPage3(onFinish: {
                    hasCompletedOnboarding = true
                })
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: currentPage)

            VStack {
                Spacer()
                PageIndicator(current: currentPage, total: 3)
                    .padding(.bottom, Theme.Spacing.xl)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Onboarding")
    }
}

struct PageIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == current ? Theme.Colors.accent : Theme.Colors.divider)
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityHidden(true)
    }
}

struct OnboardingPage1: View {
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            Image(systemName: "arrow.left.arrow.right.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.Colors.accent)
            Text("Converter")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color(uiColor: .label))
            Text("Convert length, mass, temperature, and more in one tap.")
                .font(.title3)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            PrimaryButton(title: "Get Started", action: onNext)
                .accessibilityIdentifier("Get Started")
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xl)
        }
    }
}

struct OnboardingPage2: View {
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                StepRow(number: 1, title: "Choose a category", subtitle: "Length, mass, temperature, area, volume, time, speed")
                StepRow(number: 2, title: "Enter value & pick units", subtitle: "From and to units, type the number")
                StepRow(number: 3, title: "See the result", subtitle: "Conversion updates as you type")
            }
            .padding(.horizontal, Theme.Spacing.lg)
            Spacer()
            PrimaryButton(title: "Continue", action: onNext)
                .accessibilityIdentifier("Continue")
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xl)
        }
    }
}

struct StepRow: View {
    let number: Int
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.md) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Theme.Colors.accent)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .label))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.md)
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
    }
}

struct OnboardingPage3: View {
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Theme.Colors.accent)
            Text("Quick & on device")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color(uiColor: .label))
            Text("All conversions happen instantly on your device. No account, no internet required.")
                .font(.body)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Theme.Spacing.lg)
            Spacer()
            PrimaryButton(title: "Start Converting", action: onFinish)
                .accessibilityIdentifier("Start Converting")
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.bottom, Theme.Spacing.xl)
        }
    }
}

#Preview("Onboarding") {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
