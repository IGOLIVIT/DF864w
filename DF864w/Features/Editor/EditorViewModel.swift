//
//  EditorViewModel.swift
//  DF864w
//

import SwiftUI
import CoreImage
import Combine
import os.log

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var parameters: GlowParameters
    @Published var previewImage: CGImage?
    @Published var isRendering = false
    @Published var canUndo = false
    @Published var canRedo = false
    @Published var exportInProgress = false
    @Published var exportProgress: Double = 0
    @Published var exportError: String?
    @Published var showExportSheet = false
    @Published var exportedURL: URL?
    var onExportComplete: ((ExportResult) -> Void)?

    let sourceCIImage: CIImage
    let sourceImage: UIImage
    private let renderer: GlowRendering
    private let exporter: PhotoExporting
    private let settingsStore: SettingsStoring
    private var undoStack: [GlowParameters] = []
    private var redoStack: [GlowParameters] = []
    private var renderTask: Task<Void, Never>?
    private var debounceTask: Task<Void, Never>?
    private let logger = Logger(subsystem: "IOI.DF864w", category: "Editor")
    private var previewMaxSize: CGFloat {
        settingsStore.performanceMode ? 800 : 1200
    }

    init(
        sourceCIImage: CIImage,
        sourceImage: UIImage,
        renderer: GlowRendering,
        exporter: PhotoExporting,
        settingsStore: SettingsStoring
    ) {
        self.sourceCIImage = sourceCIImage
        self.sourceImage = sourceImage
        self.renderer = renderer
        self.exporter = exporter
        self.settingsStore = settingsStore
        self.parameters = GlowParameters.defaultFor(style: .softBloom)
    }

    func onAppear() {
        pushUndoSnapshot()
        renderPreview()
    }

    func setStyle(_ style: GlowStyle) {
        parameters = GlowParameters.defaultFor(style: style)
        redoStack.removeAll()
        pushUndoSnapshot()
        renderPreview()
    }

    func updateParameters(_ update: (inout GlowParameters) -> Void) {
        var next = parameters
        update(&next)
        parameters = next
        redoStack.removeAll()
        debouncedRender()
    }

    func undo() {
        guard let last = undoStack.popLast() else { return }
        redoStack.append(parameters)
        parameters = last
        updateCanUndoRedo()
        renderPreview()
    }

    func redo() {
        guard let last = redoStack.popLast() else { return }
        undoStack.append(parameters)
        parameters = last
        updateCanUndoRedo()
        renderPreview()
    }

    func pushUndoSnapshot() {
        undoStack.append(parameters)
        if undoStack.count > 30 { undoStack.removeFirst() }
        updateCanUndoRedo()
    }

    private func updateCanUndoRedo() {
        canUndo = !undoStack.isEmpty
        canRedo = !redoStack.isEmpty
    }

    private func debouncedRender() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: 60_000_000)
            guard !Task.isCancelled else { return }
            renderPreview()
        }
    }

    func renderPreview() {
        renderTask?.cancel()
        renderTask = Task { @MainActor in
            isRendering = true
            defer { isRendering = false }
            let params = parameters
            let maxSize = previewMaxSize
            guard let result = await renderer.renderPreview(source: sourceCIImage, parameters: params, maxSize: maxSize) else {
                return
            }
            guard !Task.isCancelled else { return }
            let context = CIContext()
            if let cgImage = context.createCGImage(result, from: result.extent) {
                previewImage = cgImage
            }
        }
    }

    func export() {
        exportError = nil
        exportInProgress = true
        exportProgress = 0
        Task { @MainActor in
            defer { exportInProgress = false }
            do {
                let format = settingsStore.defaultExportFormat
                let resolution = settingsStore.defaultExportResolution
                let quality = settingsStore.jpegQuality
                guard let rendered = await renderer.renderFullResolution(source: sourceCIImage, parameters: parameters) else {
                    exportError = "Rendering failed."
                    return
                }
                let result = try await exporter.export(
                    ciImage: rendered,
                    format: format,
                    resolution: resolution,
                    jpegQuality: quality,
                    progress: { [weak self] p in
                        Task { @MainActor in
                            self?.exportProgress = p
                        }
                    }
                )
                exportedURL = result.fileURL
                onExportComplete?(result)
                showExportSheet = true
            } catch {
                exportError = error.localizedDescription
            }
        }
    }

    func saveToPhotos() {
        guard let url = exportedURL else { return }
        Task { @MainActor in
            do {
                try await exporter.saveToPhotos(url: url)
                showExportSheet = false
            } catch {
                exportError = error.localizedDescription
            }
        }
    }
}
