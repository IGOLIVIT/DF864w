//
//  RootView.swift
//  DF864w
//

import SwiftUI
import SwiftData
import CoreImage

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var settings = SettingsStore()
    @StateObject private var importViewModel = ImportPhotoViewModel(photoImporter: PhotoImporter())
    private let cacheManager = CacheManager()
    private let presetStore = PresetStore()
    private let renderer = GlowRenderer()
    private var exporter: PhotoExporter { PhotoExporter(cacheManager: cacheManager) }

    @State private var hasCompletedOnboarding: Bool = false
    @State private var importedImage: ImportedPhotoPair?

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .onChange(of: hasCompletedOnboarding) { _, new in
                        settings.hasCompletedOnboarding = new
                    }
            } else {
                mainFlow
            }
        }
        .preferredColorScheme(preferredColorScheme)
        .onAppear {
            hasCompletedOnboarding = settings.hasCompletedOnboarding
        }
    }

    private var preferredColorScheme: ColorScheme? {
        switch settings.appTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    private var mainFlow: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.primaryBackground.ignoresSafeArea()
                mainContent
            }
            .fullScreenCover(item: $importedImage) { pair in
                NavigationStack {
                    editorView(for: pair)
                }
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if let _ = importedImage {
            EmptyView()
        } else {
            homeView
        }
    }

    private var homeView: some View {
        VStack(spacing: 0) {
            ImportPhotoView(
                viewModel: importViewModel,
                onPhotoSelected: { ci, ui in
                    importedImage = ImportedPhotoPair(ciImage: ci, uiImage: ui)
                }
            )
            .padding(.top, Theme.Spacing.xl)

            HStack(spacing: Theme.Spacing.lg) {
                NavigationLink(value: "Gallery") {
                    Label("Gallery", systemImage: "photo.stack")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Colors.accent)
                }
                NavigationLink(value: "Presets") {
                    Label("Presets", systemImage: "square.stack.3d.up")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Colors.accent)
                }
                NavigationLink(value: "Settings") {
                    Label("Settings", systemImage: "gearshape")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Colors.accent)
                }
            }
            .padding(Theme.Spacing.lg)
        }
        .navigationDestination(for: String.self) { value in
            if value == "Gallery" {
                GalleryView()
            } else if value == "Presets" {
                PresetsView(
                    currentParameters: .default,
                    onApply: { _ in },
                    onDismiss: { }
                )
            } else if value == "Settings" {
                SettingsView(settings: settings, cacheManager: cacheManager)
            }
        }
    }

    @ViewBuilder
    private func editorView(for pair: ImportedPhotoPair) -> some View {
        EditorContainerView(
            pair: pair,
            renderer: renderer,
            exporter: exporter,
            settingsStore: settings,
            modelContext: modelContext,
            onBack: { importedImage = nil }
        )
    }
}

private struct EditorContainerView: View {
    @StateObject private var viewModel: EditorViewModel
    let onBack: () -> Void

    init(
        pair: ImportedPhotoPair,
        renderer: GlowRendering,
        exporter: PhotoExporting,
        settingsStore: SettingsStoring,
        modelContext: ModelContext,
        onBack: @escaping () -> Void
    ) {
        let vm = EditorViewModel(
            sourceCIImage: pair.ciImage,
            sourceImage: pair.uiImage,
            renderer: renderer,
            exporter: exporter,
            settingsStore: settingsStore
        )
        vm.onExportComplete = { result in
            let item = ExportedItem(
                localFileURL: result.fileURL,
                thumbnailURL: result.thumbnailURL,
                format: result.format,
                sizePx: result.sizePx
            )
            modelContext.insert(item)
            try? modelContext.save()
        }
        _viewModel = StateObject(wrappedValue: vm)
        self.onBack = onBack
    }

    var body: some View {
        EditorView(viewModel: viewModel, onBack: onBack)
    }
}

struct ImportedPhotoPair: Identifiable {
    let id = UUID()
    let ciImage: CIImage
    let uiImage: UIImage
}
