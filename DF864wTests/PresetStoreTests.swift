//
//  PresetStoreTests.swift
//  DF864wTests
//

import Testing
import SwiftData
@testable import DF864w

struct PresetStoreTests {

    @Test func presetStoreCRUD() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Preset.self, configurations: config)
        let context = ModelContext(container)
        let store = PresetStore()

        let params = GlowParameters.defaultFor(style: .softBloom)
        let preset = try store.save(name: "Test Preset", parameters: params, modelContext: context)
        #expect(preset.name == "Test Preset")
        #expect(preset.style == .softBloom)

        let all = try store.fetchAll(modelContext: context)
        #expect(all.count == 1)
        #expect(all[0].name == "Test Preset")

        try store.update(all[0], name: "Renamed", parameters: nil, modelContext: context)
        let afterUpdate = try store.fetchAll(modelContext: context)
        #expect(afterUpdate[0].name == "Renamed")

        try store.delete(afterUpdate[0], modelContext: context)
        let afterDelete = try store.fetchAll(modelContext: context)
        #expect(afterDelete.isEmpty)
    }
}
