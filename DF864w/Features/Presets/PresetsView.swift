//
//  PresetsView.swift
//  DF864w
//

import SwiftUI
import SwiftData

struct PresetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Preset.createdAt, order: .reverse) private var presets: [Preset]
    private let store = PresetStore()
    var currentParameters: GlowParameters
    var onApply: (GlowParameters) -> Void
    var onDismiss: () -> Void
    @State private var presetToRename: Preset?
    @State private var renameText = ""
    @State private var presetToDelete: Preset?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.primaryBackground.ignoresSafeArea()
                if presets.isEmpty {
                    EmptyStateView(
                        icon: "square.stack.3d.up",
                        title: "No Presets",
                        message: "Save your current edits as a preset from the editor, or use the built-in styles in the style carousel."
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 140), spacing: Theme.Spacing.md)
                        ], spacing: Theme.Spacing.md) {
                            ForEach(presets, id: \.id) { preset in
                                PresetCard(
                                    preset: preset,
                                    onTap: { apply(preset) },
                                    onRename: { presetToRename = preset; renameText = preset.name },
                                    onDelete: { presetToDelete = preset }
                                )
                            }
                        }
                        .padding(Theme.Spacing.md)
                    }
                }
            }
            .navigationTitle("Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDismiss() }
                        .foregroundStyle(Theme.Colors.accent)
                }
            }
            .onAppear {
                try? store.insertBuiltInIfNeeded(modelContext: modelContext)
            }
            .alert("Rename Preset", isPresented: .constant(presetToRename != nil)) {
                TextField("Name", text: $renameText)
                Button("Cancel") { presetToRename = nil }
                Button("Save") {
                    if let p = presetToRename, !renameText.isEmpty {
                        try? store.update(p, name: renameText, parameters: nil, modelContext: modelContext)
                    }
                    presetToRename = nil
                }
            } message: {
                Text("Enter a new name for this preset.")
            }
            .confirmationDialog("Delete Preset", isPresented: .constant(presetToDelete != nil)) {
                Button("Delete", role: .destructive) {
                    if let p = presetToDelete {
                        try? store.delete(p, modelContext: modelContext)
                    }
                    presetToDelete = nil
                }
                Button("Cancel", role: .cancel) { presetToDelete = nil }
            } message: {
                Text("Are you sure you want to delete this preset?")
            }
        }
    }

    private func apply(_ preset: Preset) {
        guard let params = preset.parameters else { return }
        onApply(params)
        onDismiss()
    }
}

struct PresetCard: View {
    let preset: Preset
    let onTap: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                .fill(Theme.Colors.cardSurface)
                .frame(height: 100)
                .overlay(
                    Text(preset.style.rawValue)
                        .font(.caption2)
                        .foregroundStyle(Theme.Colors.secondaryText)
                )
            Text(preset.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Theme.Colors.primaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button("Apply", action: onTap)
            Button("Rename", action: onRename)
            Button("Delete", role: .destructive, action: onDelete)
        }
        .accessibilityLabel(preset.name)
        .accessibilityHint("Double tap to apply")
    }
}

#Preview("Presets") {
    PresetsView(
        currentParameters: .default,
        onApply: { _ in },
        onDismiss: {}
    )
    .modelContainer(for: [Preset.self], inMemory: true)
}
