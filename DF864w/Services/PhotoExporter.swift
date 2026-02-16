//
//  PhotoExporter.swift
//  DF864w
//

import UIKit
import Photos
import CoreImage
import os.log

enum ExportFormat: String, CaseIterable {
    case jpeg = "JPEG"
    case png = "PNG"
    case heif = "HEIF"
}

enum ExportResolution: String, CaseIterable {
    case original = "Original"
    case px2048 = "2048px"
    case px1080 = "1080px"

    var maxDimension: Int? {
        switch self {
        case .original: return nil
        case .px2048: return 2048
        case .px1080: return 1080
        }
    }
}

struct ExportResult {
    let fileURL: URL
    let thumbnailURL: URL?
    let format: String
    let sizePx: Int
}

protocol PhotoExporting {
    func export(
        ciImage: CIImage,
        format: ExportFormat,
        resolution: ExportResolution,
        jpegQuality: Double,
        progress: @escaping (Double) -> Void
    ) async throws -> ExportResult
    func saveToPhotos(url: URL) async throws
}

final class PhotoExporter: PhotoExporting {
    private let cacheManager: CacheManaging
    private let context = CIContext()
    private let logger = Logger(subsystem: "IOI.DF864w", category: "PhotoExporter")

    init(cacheManager: CacheManaging) {
        self.cacheManager = cacheManager
    }

    func export(
        ciImage: CIImage,
        format: ExportFormat,
        resolution: ExportResolution,
        jpegQuality: Double,
        progress: @escaping (Double) -> Void
    ) async throws -> ExportResult {
        progress(0.1)
        var image = ciImage
        if let maxDim = resolution.maxDimension {
            let w = image.extent.width
            let h = image.extent.height
            let scale = min(CGFloat(maxDim) / max(w, h), 1)
            if scale < 1 {
                image = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            }
        }
        progress(0.4)
        let sizePx = Int(max(image.extent.width, image.extent.height))
        let fileName = "\(UUID().uuidString).\(format == .heif ? "heic" : format.rawValue.lowercased())"
        let fileURL = cacheManager.exportsDirectory().appendingPathComponent(fileName)
        progress(0.5)
        guard let cgImage = context.createCGImage(image, from: image.extent) else {
            throw ExportError.renderingFailed
        }
        progress(0.7)
        let uiImage = UIImage(cgImage: cgImage)
        switch format {
        case .jpeg:
            guard let data = uiImage.jpegData(compressionQuality: jpegQuality) else { throw ExportError.encodingFailed }
            try data.write(to: fileURL)
        case .png:
            guard let data = uiImage.pngData() else { throw ExportError.encodingFailed }
            try data.write(to: fileURL)
        case .heif:
            if let data = uiImage.heicData(compressionQuality: jpegQuality) {
                try data.write(to: fileURL)
            } else if let data = uiImage.jpegData(compressionQuality: jpegQuality) {
                try data.write(to: fileURL)
            } else {
                throw ExportError.encodingFailed
            }
        }
        progress(0.9)
        let thumbURL = cacheManager.saveThumbnail(UIImage(cgImage: cgImage), for: fileURL)
        progress(1)
        return ExportResult(fileURL: fileURL, thumbnailURL: thumbURL, format: format.rawValue, sizePx: sizePx)
    }

    func saveToPhotos(url: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.forAsset().addResource(with: .photo, fileURL: url, options: nil)
        }
    }
}

enum ExportError: LocalizedError {
    case renderingFailed
    case encodingFailed
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .renderingFailed: return "Failed to render image."
        case .encodingFailed: return "Failed to encode image."
        case .saveFailed: return "Failed to save to Photos."
        }
    }
}

extension UIImage {
    fileprivate func heicData(compressionQuality: Double) -> Data? {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, "public.heic" as CFString, 1, nil),
              let cg = cgImage else { return nil }
        let options: [String: Any] = [kCGImageDestinationLossyCompressionQuality as String: compressionQuality]
        CGImageDestinationAddImage(destination, cg, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
