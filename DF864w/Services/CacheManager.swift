//
//  CacheManager.swift
//  DF864w
//

import Foundation
import UIKit
import os.log

protocol CacheManaging {
    func exportsDirectory() -> URL
    func saveThumbnail(_ image: UIImage, for fileURL: URL) -> URL?
    func usedStorageBytes() -> Int64
    func clearExports() throws
}

final class CacheManager: CacheManaging {
    private let fileManager = FileManager.default
    private let logger = Logger(subsystem: "IOI.DF864w", category: "CacheManager")

    private var exportsDir: URL {
        let dir = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("GlowLabExports", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    private var thumbnailsDir: URL {
        let dir = exportsDir.appendingPathComponent("Thumbnails", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func exportsDirectory() -> URL {
        exportsDir
    }

    func saveThumbnail(_ image: UIImage, for fileURL: URL) -> URL? {
        let name = fileURL.deletingPathExtension().lastPathComponent + "_thumb.jpg"
        let thumbURL = thumbnailsDir.appendingPathComponent(name)
        guard let data = image.jpegData(compressionQuality: 0.6) else { return nil }
        try? data.write(to: thumbURL)
        return thumbURL
    }

    func usedStorageBytes() -> Int64 {
        func sizeOfDirectory(at url: URL) -> Int64 {
            guard let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) else { return 0 }
            var total: Int64 = 0
            for case let fileURL as URL in enumerator {
                let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
                total += Int64(size)
            }
            return total
        }
        return sizeOfDirectory(at: exportsDir)
    }

    func clearExports() throws {
        let contents = try fileManager.contentsOfDirectory(at: exportsDir, includingPropertiesForKeys: nil)
        for url in contents {
            try fileManager.removeItem(at: url)
        }
    }
}
