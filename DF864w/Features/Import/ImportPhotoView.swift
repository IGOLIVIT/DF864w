//
//  ImportPhotoView.swift
//  DF864w
//

import SwiftUI
import PhotosUI
import Combine

struct ImportPhotoView: View {
    @ObservedObject var viewModel: ImportPhotoViewModel
    var onPhotoSelected: (CIImage, UIImage) -> Void

    var body: some View {
        Group {
            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else {
                mainView
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
        .animation(.easeInOut(duration: 0.2), value: viewModel.errorMessage != nil)
    }

    private var mainView: some View {
        EmptyStateView(
            icon: "photo.on.rectangle.angled",
            title: "Import a Photo",
            message: "Choose a photo from your library to add premium glow effects. Edits happen on-device only.",
            buttonTitle: "Import Photo",
            buttonAction: { viewModel.importPhoto(onSelected: onPhotoSelected) }
        )
        .accessibilityIdentifier("Import Photo")
    }

    private var loadingView: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Theme.Colors.accent)
            Text("Loading photo…")
                .font(.subheadline)
                .foregroundStyle(Theme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(Theme.Colors.accent)
            Text("Import Failed")
                .font(.headline)
                .foregroundStyle(Theme.Colors.primaryText)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            PrimaryButton(title: "Try Again", action: { viewModel.clearError(); viewModel.importPhoto(onSelected: onPhotoSelected) })
                .frame(maxWidth: 280)
        }
        .padding(Theme.Spacing.xl)
    }
}

final class ImportPhotoViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let photoImporter: PhotoImporting

    init(photoImporter: PhotoImporting = PhotoImporter()) {
        self.photoImporter = photoImporter
    }

    func importPhoto(onSelected: @escaping (CIImage, UIImage) -> Void) {
        isLoading = true
        errorMessage = nil
        Task { @MainActor in
            defer { isLoading = false }
            guard let image = await photoImporter.pickSingleImage() else {
                return
            }
            guard let ciImage = photoImporter.loadCIImage(from: image) else {
                errorMessage = "Could not load the selected image."
                return
            }
            onSelected(ciImage, image)
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

#Preview("Import") {
    ImportPhotoView(
        viewModel: ImportPhotoViewModel(),
        onPhotoSelected: { _, _ in }
    )
    .background(Theme.Colors.primaryBackground)
}
