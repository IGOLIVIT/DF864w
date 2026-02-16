//
//  PresetStore.swift
//  DF864w
//

import Foundation
import SwiftData
import os.log

protocol PresetStoring {
    func fetchAll(modelContext: ModelContext) throws -> [Preset]
    func save(name: String, parameters: GlowParameters, modelContext: ModelContext) throws -> Preset
    func delete(_ preset: Preset, modelContext: ModelContext) throws
    func update(_ preset: Preset, name: String?, parameters: GlowParameters?, modelContext: ModelContext) throws
    func insertBuiltInIfNeeded(modelContext: ModelContext) throws
}

final class PresetStore: PresetStoring {
    private let logger = Logger(subsystem: "IOI.DF864w", category: "PresetStore")

    static let builtInPresetNames = [
        "Morning Light",
        "Studio Portrait",
        "Cinematic Mood",
        "Warm Fade",
        "Cool Edge",
        "Golden Hour"
    ]

    func fetchAll(modelContext: ModelContext) throws -> [Preset] {
        let descriptor = FetchDescriptor<Preset>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }

    func save(name: String, parameters: GlowParameters, modelContext: ModelContext) throws -> Preset {
        let preset = Preset(name: name, style: parameters.style, parameters: parameters)
        modelContext.insert(preset)
        try modelContext.save()
        return preset
    }

    func delete(_ preset: Preset, modelContext: ModelContext) throws {
        modelContext.delete(preset)
        try modelContext.save()
    }

    func update(_ preset: Preset, name: String?, parameters: GlowParameters?, modelContext: ModelContext) throws {
        if let name { preset.name = name }
        if let parameters {
            preset.style = parameters.style
            preset.parameters = parameters
        }
        try modelContext.save()
    }

    func insertBuiltInIfNeeded(modelContext: ModelContext) throws {
        let descriptor = FetchDescriptor<Preset>()
        let existing = try modelContext.fetch(descriptor)
        let existingNames = Set(existing.map(\.name))
        let builtInParams: [(String, GlowParameters)] = [
            ("Morning Light", { var p = GlowParameters.defaultFor(style: .goldenHourGlow); p.warmth = 30; p.intensity = 65; return p }()),
            ("Studio Portrait", { var p = GlowParameters.defaultFor(style: .softBloom); p.bloom = 45; p.vignette = 35; return p }()),
            ("Cinematic Mood", { var p = GlowParameters.defaultFor(style: .cinematicHalo); p.contrast = -12; p.vignette = 45; return p }()),
            ("Warm Fade", { var p = GlowParameters.defaultFor(style: .warmLightLeak); p.grain = 10; return p }()),
            ("Cool Edge", { var p = GlowParameters.defaultFor(style: .coolStudioGlow); p.bloom = 60; return p }()),
            ("Golden Hour", { var p = GlowParameters.defaultFor(style: .goldenHourGlow); return p }())
        ]
        for (name, params) in builtInParams where !existingNames.contains(name) {
            let preset = Preset(name: name, style: params.style, parameters: params)
            modelContext.insert(preset)
        }
        try modelContext.save()
    }
}
