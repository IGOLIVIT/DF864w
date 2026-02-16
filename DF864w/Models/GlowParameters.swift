//
//  GlowParameters.swift
//  DF864w
//

import Foundation

struct GlowParameters: Equatable, Codable {
    var style: GlowStyle
    var intensity: Double
    var bloom: Double
    var warmth: Double
    var contrast: Double
    var highlights: Double
    var shadows: Double
    var vignette: Double
    var grain: Double
    var lightPositionX: Double
    var lightPositionY: Double
    var mirrorReflection: Bool

    static let `default` = GlowParameters(
        style: .softBloom,
        intensity: 70,
        bloom: 50,
        warmth: 0,
        contrast: 0,
        highlights: 0,
        shadows: 0,
        vignette: 30,
        grain: 5,
        lightPositionX: 0.5,
        lightPositionY: 0.5,
        mirrorReflection: false
    )

    static func defaultFor(style: GlowStyle) -> GlowParameters {
        var p = GlowParameters.default
        p.style = style
        switch style {
        case .softBloom:
            p.intensity = 70
            p.bloom = 60
            p.vignette = 25
        case .cinematicHalo:
            p.intensity = 65
            p.bloom = 45
            p.contrast = -10
            p.vignette = 40
        case .glassReflection:
            p.intensity = 55
            p.bloom = 70
            p.highlights = 15
            p.vignette = 20
        case .warmLightLeak:
            p.intensity = 60
            p.warmth = 25
            p.vignette = 50
            p.grain = 8
        case .coolStudioGlow:
            p.intensity = 65
            p.warmth = -15
            p.bloom = 55
            p.vignette = 35
        case .goldenHourGlow:
            p.intensity = 75
            p.warmth = 35
            p.highlights = 20
            p.vignette = 40
        case .matteGlow:
            p.intensity = 50
            p.contrast = -15
            p.bloom = 40
            p.vignette = 45
        case .crispShine:
            p.intensity = 80
            p.bloom = 55
            p.contrast = 10
            p.highlights = 25
            p.vignette = 20
        }
        return p
    }
}
