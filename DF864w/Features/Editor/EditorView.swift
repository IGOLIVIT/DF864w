//
//  EditorView.swift
//  DF864w
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel: EditorViewModel
    let onBack: () -> Void
    @State private var showControls = false
    @State private var isComparing = false
    @State private var showPresets = false
    @State private var showSavePreset = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    private var isCompact: Bool { horizontalSizeClass == .compact }

    var body: some View {
        ZStack {
            Theme.Colors.primaryBackground.ignoresSafeArea()

            if isCompact {
                compactLayout
            } else {
                iPadLayout
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") { onBack() }
                    .foregroundStyle(Theme.Colors.accent)
            }
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: Theme.Spacing.sm) {
                    Menu {
                        Button {
                            showSavePreset = true
                        } label: {
                            Label("Save as Preset", systemImage: "square.and.arrow.down")
                        }
                        Button {
                            showPresets = true
                        } label: {
                            Label("Presets", systemImage: "square.stack.3d.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    compareButton
                    undoRedoButtons
                    exportButton
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
        .sheet(isPresented: $showPresets) {
            PresetsView(
                currentParameters: viewModel.parameters,
                onApply: { params in
                    viewModel.parameters = params
                    viewModel.renderPreview()
                    showPresets = false
                },
                onDismiss: { showPresets = false }
            )
        }
        .sheet(isPresented: $showSavePreset) {
            SavePresetView(
                parameters: viewModel.parameters,
                onSaved: { showSavePreset = false },
                onCancel: { showSavePreset = false }
            )
        }
        .sheet(isPresented: $viewModel.showExportSheet) {
            if let url = viewModel.exportedURL {
                ShareSheet(items: [url])
                    .onDisappear { viewModel.exportedURL = nil }
            }
        }
        .alert("Export Failed", isPresented: .constant(viewModel.exportError != nil)) {
            Button("OK") { viewModel.exportError = nil }
        } message: {
            if let msg = viewModel.exportError { Text(msg) }
        }
        .overlay {
            if viewModel.exportInProgress {
                exportProgressOverlay
            }
        }
    }

    private var compactLayout: some View {
        VStack(spacing: 0) {
            previewArea
            styleCarousel
            if showControls {
                controlsPanel
            } else {
                Button(action: { withAnimation(.easeInOut(duration: 0.2)) { showControls = true } }) {
                    Label("Adjustments", systemImage: "slider.horizontal.3")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Colors.accent)
                }
                .padding(.vertical, Theme.Spacing.sm)
            }
        }
    }

    private var iPadLayout: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    styleCarousel
                    controlsPanel
                }
                .padding(Theme.Spacing.md)
                .frame(maxWidth: 320)
            }
            .background(Theme.Colors.secondaryBackground)
            previewArea
        }
    }

    private var previewArea: some View {
        GeometryReader { geo in
            ZStack {
                if isComparing {
                    Image(uiImage: viewModel.sourceImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity)
                } else if let cgImage = viewModel.previewImage {
                    Image(decorative: cgImage, scale: 1, orientation: .up)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.isRendering {
                    ProgressView()
                        .scaleEffect(1.2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 0.3) {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
                    isComparing = true
                }
            } onPressingChanged: { pressing in
                if !pressing && isComparing {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                        isComparing = false
                    }
                }
            }
            .accessibilityLabel(isComparing ? "Showing original photo" : "Edited preview")
            .accessibilityHint("Press and hold to compare with original")
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, isCompact ? 0 : Theme.Spacing.md)
    }

    private var compareButton: some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                isComparing.toggle()
            }
        } label: {
            Image(systemName: isComparing ? "eye.slash" : "eye")
                .font(.body.weight(.medium))
        }
        .foregroundStyle(Theme.Colors.accent)
        .accessibilityLabel(isComparing ? "Show edited" : "Compare with original")
    }

    private var undoRedoButtons: some View {
        HStack(spacing: 4) {
            Button {
                viewModel.undo()
            } label: {
                Image(systemName: "arrow.uturn.backward")
            }
            .keyboardShortcut("z", modifiers: .command)
            .disabled(!viewModel.canUndo)
            .foregroundStyle(viewModel.canUndo ? Theme.Colors.accent : Theme.Colors.secondaryText)
            Button {
                viewModel.redo()
            } label: {
                Image(systemName: "arrow.uturn.forward")
            }
            .keyboardShortcut("z", modifiers: [.command, .shift])
            .disabled(!viewModel.canRedo)
            .foregroundStyle(viewModel.canRedo ? Theme.Colors.accent : Theme.Colors.secondaryText)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Undo and redo")
    }

    private var exportButton: some View {
        Button("Export") {
            viewModel.export()
        }
        .keyboardShortcut("e", modifiers: .command)
        .fontWeight(.semibold)
        .foregroundStyle(Theme.Colors.accent)
        .disabled(viewModel.exportInProgress)
    }

    private var styleCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(GlowStyle.allCases) { style in
                    StyleCard(
                        style: style,
                        isSelected: viewModel.parameters.style == style
                    ) {
                        viewModel.setStyle(style)
                    }
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
        }
        .frame(height: 88)
        .background(Theme.Colors.secondaryBackground.opacity(0.8))
    }

    private var controlsPanel: some View {
        GlassPanel {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                if isCompact {
                    HStack {
                        Text("Adjustments")
                            .font(.headline)
                            .foregroundStyle(Theme.Colors.primaryText)
                        Spacer()
                        Button(action: { withAnimation { showControls = false } }) {
                            Image(systemName: "chevron.down")
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                    }
                }

                LabeledSlider(label: "Intensity", value: Binding(
                    get: { viewModel.parameters.intensity },
                    set: { val in viewModel.updateParameters { $0.intensity = val } }
                ), range: 0...100, step: 1)
                LabeledSlider(label: "Bloom", value: Binding(
                    get: { viewModel.parameters.bloom },
                    set: { val in viewModel.updateParameters { $0.bloom = val } }
                ), range: 0...100, step: 1)
                LabeledSlider(label: "Warmth", value: Binding(
                    get: { viewModel.parameters.warmth },
                    set: { val in viewModel.updateParameters { $0.warmth = val } }
                ), range: -50...50, step: 1, format: { "\(Int($0))" })
                LabeledSlider(label: "Contrast", value: Binding(
                    get: { viewModel.parameters.contrast },
                    set: { val in viewModel.updateParameters { $0.contrast = val } }
                ), range: -50...50, step: 1, format: { "\(Int($0))" })
                LabeledSlider(label: "Highlights", value: Binding(
                    get: { viewModel.parameters.highlights },
                    set: { val in viewModel.updateParameters { $0.highlights = val } }
                ), range: -50...50, step: 1, format: { "\(Int($0))" })
                LabeledSlider(label: "Shadows", value: Binding(
                    get: { viewModel.parameters.shadows },
                    set: { val in viewModel.updateParameters { $0.shadows = val } }
                ), range: -50...50, step: 1, format: { "\(Int($0))" })
                LabeledSlider(label: "Vignette", value: Binding(
                    get: { viewModel.parameters.vignette },
                    set: { val in viewModel.updateParameters { $0.vignette = val } }
                ), range: 0...100, step: 1)
                LabeledSlider(label: "Grain", value: Binding(
                    get: { viewModel.parameters.grain },
                    set: { val in viewModel.updateParameters { $0.grain = val } }
                ), range: 0...30, step: 1)

                if viewModel.parameters.style.supportsMirrorReflection {
                    Toggle("Mirror Reflection", isOn: Binding(
                        get: { viewModel.parameters.mirrorReflection },
                        set: { val in viewModel.updateParameters { $0.mirrorReflection = val } }
                    ))
                    .tint(Theme.Colors.accent)
                }

                LabeledSlider(label: "Light X", value: Binding(
                    get: { viewModel.parameters.lightPositionX * 100 },
                    set: { val in viewModel.updateParameters { $0.lightPositionX = val / 100 } }
                ), range: 0...100, step: 2, format: { "\(Int($0))%" })
                LabeledSlider(label: "Light Y", value: Binding(
                    get: { viewModel.parameters.lightPositionY * 100 },
                    set: { val in viewModel.updateParameters { $0.lightPositionY = val / 100 } }
                ), range: 0...100, step: 2, format: { "\(Int($0))%" })
            }
        }
    }

    private var exportProgressOverlay: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            VStack(spacing: Theme.Spacing.md) {
                ProgressView(value: viewModel.exportProgress)
                    .progressViewStyle(.linear)
                    .frame(width: 200)
                    .tint(Theme.Colors.accent)
                Text("Exporting…")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(Theme.Spacing.xl)
            .background(Theme.Colors.cardSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        }
    }
}

struct StyleCard: View {
    let style: GlowStyle
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .fill(Theme.Colors.cardSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                            .stroke(isSelected ? Theme.Colors.accent : Color.clear, lineWidth: 3)
                    )
                    .frame(width: 56, height: 56)
                Text(style.rawValue)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Theme.Colors.accent : Theme.Colors.secondaryText)
                    .lineLimit(1)
            }
            .frame(width: 72)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(style.rawValue)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#if canImport(UIKit)
import UIKit
#endif
