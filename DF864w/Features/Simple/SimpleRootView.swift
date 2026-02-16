//
//  SimpleRootView.swift
//  DF864w
//

import SwiftUI
import PhotosUI
import Combine

final class SimpleEditorViewModel: ObservableObject {
    @Published var originalImage: UIImage? = nil
    @Published var glow: Double = 0.5
    @Published var warmth: Double = 0.0
    @Published var vignette: Double = 0.3
    @Published var isExporting: Bool = false
    @Published var exportURL: URL? = nil
}

struct SimpleRootView: View {
    @StateObject private var viewModel = SimpleEditorViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var showShare = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.primaryBackground.ignoresSafeArea()

                if let image = viewModel.originalImage {
                    editorContent(image: image)
                } else {
                    importContent
                }
            }
            .navigationTitle("GlowLab")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Import state

    private var importContent: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
            EmptyStateView(
                icon: "sparkles",
                title: "One-tap glow edits",
                message: "Import a photo, adjust a couple of sliders and share your look.",
                buttonTitle: "Import Photo",
                buttonAction: { }
            )
            PhotosPicker(selection: $selectedItem, matching: .images) {
                PrimaryButton(title: "Import Photo") { }
            }
            .onChange(of: selectedItem) { _, newItem in
                loadImage(from: newItem)
            }
            Spacer()
        }
        .padding()
    }

    // MARK: - Editor state

    private func editorContent(image: UIImage) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()
            GeometryReader { geo in
                editedView(for: image)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .aspectRatio(1, contentMode: .fit)

            VStack(spacing: Theme.Spacing.md) {
                LabeledSlider(
                    label: "Glow",
                    value: $viewModel.glow,
                    range: 0...1,
                    step: 0.01,
                    format: { String(format: "%.2f", $0) }
                )
                LabeledSlider(
                    label: "Warmth",
                    value: $viewModel.warmth,
                    range: -0.5...0.5,
                    step: 0.01,
                    format: { String(format: "%.2f", $0) }
                )
                LabeledSlider(
                    label: "Vignette",
                    value: $viewModel.vignette,
                    range: 0...1,
                    step: 0.01,
                    format: { String(format: "%.2f", $0) }
                )
            }
            .padding()
            .background(Theme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))

            HStack(spacing: Theme.Spacing.md) {
                PrimaryButton(title: "Change Photo", action: { viewModel.originalImage = nil }, style: .secondary)
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    PrimaryButton(title: "Import", action: { })
                }
                .onChange(of: selectedItem) { _, newItem in
                    loadImage(from: newItem)
                }
            }

            PrimaryButton(title: "Export", action: exportImage)
                .padding(.top, Theme.Spacing.sm)

            Spacer(minLength: Theme.Spacing.lg)
        }
        .padding()
        .sheet(isPresented: $showShare) {
            if let url = viewModel.exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func editedView(for image: UIImage) -> some View {
        let glow = viewModel.glow
        let warmth = viewModel.warmth
        let vignette = viewModel.vignette

        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .brightness(glow * 0.1)
            .contrast(1 + glow * 0.4)
            .saturation(1 + glow * 0.2)
            .colorMultiply(
                Color(
                    red: 1 + warmth * 0.6,
                    green: 1 + warmth * 0.2,
                    blue: 1 - warmth * 0.4
                )
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(vignette),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 500
                )
            )
            .shadow(color: .white.opacity(glow * 0.4), radius: 40 * glow)
    }

    // MARK: - Load & export

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                await MainActor.run {
                    viewModel.originalImage = uiImage
                }
            }
        }
    }

    private func exportImage() {
        guard let image = viewModel.originalImage else { return }
        let content = editedView(for: image)
        let renderer = ImageRenderer(content: content)
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage,
           let data = uiImage.jpegData(compressionQuality: 0.95) {
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("GlowLab-\(UUID().uuidString).jpg")
            try? data.write(to: url)
            viewModel.exportURL = url
            showShare = true
        }
    }
}

