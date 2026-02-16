//
//  ExportPipelineTests.swift
//  DF864wTests
//

import Testing
import CoreImage
@testable import DF864w

struct ExportPipelineTests {

    @Test func exportCreatesFileAndMetadata() async throws {
        let cache = CacheManager()
        let exporter = PhotoExporter(cacheManager: cache)
        let extent = CGRect(x: 0, y: 0, width: 200, height: 200)
        let source = CIImage(color: CIColor(red: 0.2, green: 0.4, blue: 0.8))
            .cropped(to: extent)

        var progressValues: [Double] = []
        let result = try await exporter.export(
            ciImage: source,
            format: .jpeg,
            resolution: .px1080,
            jpegQuality: 0.9,
            progress: { progressValues.append($0) }
        )

        #expect(FileManager.default.fileExists(atPath: result.fileURL.path))
        #expect(result.format == "JPEG")
        #expect(result.sizePx > 0)
        #expect(!progressValues.isEmpty)
        #expect(progressValues.last == 1.0)
    }
}
