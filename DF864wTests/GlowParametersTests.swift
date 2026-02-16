//
//  GlowParametersTests.swift
//  DF864wTests
//

import Testing
@testable import DF864w

struct GlowParametersTests {

    @Test func defaultParametersEncodesAndDecodes() throws {
        let params = GlowParameters.default
        let data = try JSONEncoder().encode(params)
        let decoded = try JSONDecoder().decode(GlowParameters.self, from: data)
        #expect(decoded.style == params.style)
        #expect(decoded.intensity == params.intensity)
        #expect(decoded.bloom == params.bloom)
    }

    @Test func defaultForEachStyleProducesDistinctStyle() throws {
        for style in GlowStyle.allCases {
            let params = GlowParameters.defaultFor(style: style)
            #expect(params.style == style)
        }
    }

    @Test func undoRedoSnapshotEquality() throws {
        var a = GlowParameters.default
        var b = GlowParameters.default
        a.intensity = 80
        b.intensity = 80
        #expect(a == b)
        b.bloom = 60
        #expect(a != b)
    }
}
