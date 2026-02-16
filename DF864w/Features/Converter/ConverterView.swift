//
//  ConverterView.swift
//  DF864w
//
//  Конвертер физических мер — один экран.
//

import SwiftUI

struct ConverterView: View {
    @StateObject private var viewModel = ConverterViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen background so it always shows
                Color(red: 0.91, green: 0.95, blue: 1.0)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                        categorySection
                        fromToSection
                    }
                    .padding(Theme.Spacing.md)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Converter")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Category")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.primary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(UnitDimension.allCases) { dim in
                        Button {
                            viewModel.setDimension(dim)
                        } label: {
                            Text(dim.rawValue)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(viewModel.dimension == dim ? Color.white : Color.primary)
                                .padding(.horizontal, Theme.Spacing.sm)
                                .padding(.vertical, Theme.Spacing.xs)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(viewModel.dimension == dim ? Theme.Colors.accent : Color(.systemGray5))
                    }
                }
                .padding(.vertical, Theme.Spacing.xxs)
            }
        }
    }

    private var fromToSection: some View {
        VStack(spacing: Theme.Spacing.md) {
            unitRow(
                title: "From",
                units: viewModel.dimension.units,
                selectedSymbol: $viewModel.sourceUnitSymbol,
                value: $viewModel.inputText,
                isResult: false
            )

            Button {
                viewModel.swapUnits()
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.Colors.accent)
            }
            .padding(.vertical, Theme.Spacing.xxs)

            unitRow(
                title: "To",
                units: viewModel.dimension.units,
                selectedSymbol: $viewModel.targetUnitSymbol,
                value: $viewModel.resultText,
                isResult: true
            )
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.cardSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
    }

    private func unitRow(
        title: String,
        units: [Unit],
        selectedSymbol: Binding<String>,
        value: Binding<String>,
        isResult: Bool
    ) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.primary)
                .frame(width: 36, alignment: .leading)
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Picker("", selection: selectedSymbol) {
                    ForEach(units) { u in
                        Text("\(u.symbol) — \(u.name)").tag(u.symbol)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .foregroundStyle(Color.primary)
                if isResult {
                    Text(value.wrappedValue.isEmpty ? "—" : value.wrappedValue)
                        .font(.title2.monospacedDigit().weight(.semibold))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(Theme.Spacing.sm)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                .strokeBorder(Color.primary.opacity(0.25), lineWidth: 1.5)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                } else {
                    TextField("Enter value", text: value)
                        .keyboardType(.decimalPad)
                        .font(.title2.monospacedDigit().weight(.medium))
                        .foregroundStyle(Color.primary)
                        .padding(Theme.Spacing.sm)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                .strokeBorder(Color.primary.opacity(0.25), lineWidth: 1.5)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Previews
#Preview("iPhone SE") {
    ConverterView()
        .previewDevice("iPhone SE (3rd generation)")
}

#Preview("iPhone 15 Pro Max") {
    ConverterView()
        .previewDevice("iPhone 15 Pro Max")
}

#Preview("iPad Air 11") {
    ConverterView()
        .previewDevice("iPad Air 11-inch (M3)")
}
