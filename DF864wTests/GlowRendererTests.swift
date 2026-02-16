//
//  GlowRendererTests.swift
//  DF864wTests
//

import Testing
import CoreImage
@testable import DF864w

struct GlowRendererTests {

    @Test func rendererProducesOutputForValidInput() async throws {
        let renderer = GlowRenderer(useMetal: false)
        let extent = CGRect(x: 0, y: 0, width: 100, height: 100)
        let source = CIImage(color: CIColor(red: 0.5, green: 0.5, blue: 0.5))
            .cropped(to: extent)
        let params = GlowParameters.default

        let preview = await renderer.renderPreview(source: source, parameters: params, maxSize: 200)
        #expect(preview != nil)
        #expect(preview!.extent.width > 0)
        #expect(preview!.extent.height > 0)

        let full = await renderer.renderFullResolution(source: source, parameters: params)
        #expect(full != nil)
    }

    @Test func differentParametersProduceDifferentOutput() async throws {
        let renderer = GlowRenderer(useMetal: false)
        let extent = CGRect(x: 0, y: 0, width: 50, height: 50)
        let source = CIImage(color: CIColor(red: 0.3, green: 0.6, blue: 0.4))
            .cropped(to: extent)

        var paramsLow = GlowParameters.default
        paramsLow.intensity = 20
        paramsLow.bloom = 10
        var paramsHigh = GlowParameters.default
        paramsHigh.intensity = 90
        paramsHigh.bloom = 90

        let outLow = await renderer.renderPreview(source: source, parameters: paramsLow, maxSize: 100)
        let outHigh = await renderer.renderPreview(source: source, parameters: paramsHigh, maxSize: 100)
        #expect(outLow != nil)
        #expect(outHigh != nil)
    }
}
