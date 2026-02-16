//
//  SavePresetView.swift
//  DF864w
//

import SwiftUI
import SwiftData

struct SavePresetView: View {
    @Environment(\.modelContext) private var modelContext
    private let store = PresetStore()
    var parameters: GlowParameters
    var onSaved: () -> Void
    var onCancel: () -> Void
    @State private var name = ""
    @FocusState private var nameFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.primaryBackground.ignoresSafeArea()
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    Text("Preset name")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Colors.secondaryText)
                    TextField("e.g. My Look", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .focused($nameFocused)
                        .submitLabel(.done)
                    Text("Style: \(parameters.style.rawValue)")
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.secondaryText)
                    Spacer()
                }
                .padding(Theme.Spacing.lg)
            }
            .navigationTitle("Save Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                        .foregroundStyle(Theme.Colors.accent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(name.isEmpty ? Theme.Colors.secondaryText : Theme.Colors.accent)
                        .disabled(name.isEmpty)
                }
            }
            .onAppear { nameFocused = true }
        }
    }

    private func save() {
        guard !name.isEmpty else { return }
        do {
            _ = try store.save(name: name.trimmingCharacters(in: .whitespacesAndNewlines), parameters: parameters, modelContext: modelContext)
            onSaved()
        } catch {
            // Could show error
        }
    }
}
