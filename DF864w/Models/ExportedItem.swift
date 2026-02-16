//
//  ExportedItem.swift
//  DF864w
//

import Foundation
import SwiftData

@Model
final class ExportedItem {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var localFileURL: URL?
    var thumbnailURL: URL?
    var formatRaw: String
    var sizePx: Int

    init(id: UUID = UUID(), createdAt: Date = Date(), localFileURL: URL?, thumbnailURL: URL?, format: String, sizePx: Int) {
        self.id = id
        self.createdAt = createdAt
        self.localFileURL = localFileURL
        self.thumbnailURL = thumbnailURL
        self.formatRaw = format
        self.sizePx = sizePx
    }

    var format: String {
        get { formatRaw }
        set { formatRaw = newValue }
    }
}
