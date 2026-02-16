//
//  GlowStyle.swift
//  DF864w
//

import Foundation

enum GlowStyle: String, CaseIterable, Codable, Identifiable {
    case softBloom = "Soft Bloom"
    case cinematicHalo = "Cinematic Halo"
    case glassReflection = "Glass Reflection"
    case warmLightLeak = "Warm Light Leak"
    case coolStudioGlow = "Cool Studio Glow"
    case goldenHourGlow = "Golden Hour Glow"
    case matteGlow = "Matte Glow"
    case crispShine = "Crisp Shine"

    var id: String { rawValue }

    var supportsMirrorReflection: Bool {
        switch self {
        case .glassReflection, .cinematicHalo: return true
        default: return false
        }
    }
}
