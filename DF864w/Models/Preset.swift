//
//  Preset.swift
//  DF864w
//

import Foundation
import SwiftData

@Model
final class Preset {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var name: String
    var styleRaw: String
    var parametersBlob: Data?

    init(id: UUID = UUID(), createdAt: Date = Date(), name: String, style: GlowStyle, parameters: GlowParameters) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.styleRaw = parameters.style.rawValue
        self.parametersBlob = (try? JSONEncoder().encode(parameters)) ?? nil
    }

    var style: GlowStyle {
        get { GlowStyle(rawValue: styleRaw) ?? .softBloom }
        set { styleRaw = newValue.rawValue }
    }

    var parameters: GlowParameters? {
        get {
            guard let data = parametersBlob else { return nil }
            return try? JSONDecoder().decode(GlowParameters.self, from: data)
        }
        set {
            parametersBlob = (try? JSONEncoder().encode(newValue)) ?? nil
        }
    }
}
