//
//  GlowLabSchema.swift
//  DF864w
//

import SwiftData

enum GlowLabSchema {
    static var schema: Schema {
        Schema([
            Preset.self,
            ExportedItem.self
        ])
    }

    static var modelConfiguration: ModelConfiguration {
        ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
    }
}
