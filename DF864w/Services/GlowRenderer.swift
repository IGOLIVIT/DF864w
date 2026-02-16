//
//  GlowRenderer.swift
//  DF864w
//

import CoreImage
import Metal
import UIKit
import os.log

protocol GlowRendering {
    func renderPreview(source: CIImage, parameters: GlowParameters, maxSize: CGFloat) async -> CIImage?
    func renderFullResolution(source: CIImage, parameters: GlowParameters) async -> CIImage?
}

final class GlowRenderer: GlowRendering {
    private let context: CIContext
    private let lightLeakImageNames: [String]
    private let logger = Logger(subsystem: "IOI.DF864w", category: "GlowRenderer")

    init(useMetal: Bool = true) {
        if useMetal, let device = MTLCreateSystemDefaultDevice() {
            self.context = CIContext(mtlDevice: device)
        } else {
            self.context = CIContext()
        }
        self.lightLeakImageNames = [
            "LightLeak1", "LightLeak2", "LightLeak3", "LightLeak4",
            "LightLeak5", "LightLeak6", "LightLeak7", "LightLeak8"
        ]
    }

    func renderPreview(source: CIImage, parameters: GlowParameters, maxSize: CGFloat) async -> CIImage? {
        let scale = min(maxSize / max(source.extent.width, source.extent.height), 1)
        let scaled = scale < 1 ? source.transformed(by: CGAffineTransform(scaleX: scale, y: scale)) : source
        return await applyPipeline(to: scaled, parameters: parameters)
    }

    func renderFullResolution(source: CIImage, parameters: GlowParameters) async -> CIImage? {
        await applyPipeline(to: source, parameters: parameters)
    }

    private func applyPipeline(to source: CIImage, parameters: GlowParameters) async -> CIImage? {
        var image = source

        image = applyBloom(image, intensity: parameters.intensity / 100, radius: parameters.bloom / 100 * 20)
        image = applyToneCurve(image, contrast: parameters.contrast, highlights: parameters.highlights, shadows: parameters.shadows)
        image = applyWarmth(image, warmth: parameters.warmth)
        image = applyStyleOverlay(image, parameters: parameters)
        image = applyVignette(image, amount: parameters.vignette / 100)
        image = applyGrain(image, amount: parameters.grain / 30)

        return image
    }

    private func applyBloom(_ input: CIImage, intensity: Double, radius: Double) -> CIImage {
        guard let bloomFilter = CIFilter(name: "CIBloom") else { return input }
        bloomFilter.setValue(input, forKey: kCIInputImageKey)
        bloomFilter.setValue(intensity * 0.8, forKey: kCIInputIntensityKey)
        bloomFilter.setValue(radius, forKey: kCIInputRadiusKey)
        return bloomFilter.outputImage?.cropped(to: input.extent) ?? input
    }

    private func applyToneCurve(_ input: CIImage, contrast: Double, highlights: Double, shadows: Double) -> CIImage {
        let c = 1 + (contrast / 100) * 0.5
        let h = 1 + (highlights / 100) * 0.3
        let s = 1 + (shadows / 100) * 0.4
        guard let matrixFilter = CIFilter(name: "CIColorMatrix") else { return input }
        matrixFilter.setValue(input, forKey: kCIInputImageKey)
        let bias = CGFloat((1 - s) * 0.1)
        matrixFilter.setValue(CIVector(x: CGFloat(c), y: 0, z: 0, w: bias), forKey: "inputRVector")
        matrixFilter.setValue(CIVector(x: 0, y: CGFloat(c), z: 0, w: bias), forKey: "inputGVector")
        matrixFilter.setValue(CIVector(x: 0, y: 0, z: CGFloat(c), w: bias), forKey: "inputBVector")
        matrixFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        var result = matrixFilter.outputImage ?? input
        if abs(highlights) > 0.01 {
            guard let exp = CIFilter(name: "CIExposureAdjust") else { return result }
            exp.setValue(result, forKey: kCIInputImageKey)
            exp.setValue(highlights / 100 * 0.5, forKey: kCIInputEVKey)
            result = exp.outputImage?.cropped(to: input.extent) ?? result
        }
        return result
    }

    private func applyWarmth(_ input: CIImage, warmth: Double) -> CIImage {
        guard abs(warmth) > 0.5 else { return input }
        return applyWarmthViaMatrix(input, warmth: warmth)
    }

    private func applyWarmthViaMatrix(_ input: CIImage, warmth: Double) -> CIImage {
        let t = warmth / 100
        let r = 1 + max(0, t * 0.15)
        let b = 1 - max(0, -t * 0.15)
        guard let matrixFilter = CIFilter(name: "CIColorMatrix") else { return input }
        matrixFilter.setValue(input, forKey: kCIInputImageKey)
        matrixFilter.setValue(CIVector(x: CGFloat(r), y: 0, z: 0, w: 0), forKey: "inputRVector")
        matrixFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        matrixFilter.setValue(CIVector(x: 0, y: 0, z: CGFloat(b), w: 0), forKey: "inputBVector")
        matrixFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: 1), forKey: "inputAVector")
        return matrixFilter.outputImage?.cropped(to: input.extent) ?? input
    }

    private func applyStyleOverlay(_ input: CIImage, parameters: GlowParameters) -> CIImage {
        var image = input
        let intensity = parameters.intensity / 100

        switch parameters.style {
        case .warmLightLeak, .goldenHourGlow:
            if let overlay = loadLightLeakForStyle(parameters.style),
               let blended = blendOverlay(overlay, on: image, positionX: parameters.lightPositionX, positionY: parameters.lightPositionY, opacity: intensity * 0.4) {
                image = blended
            }
        case .glassReflection where parameters.mirrorReflection:
            if let overlay = createReflectionOverlay(extent: image.extent),
               let blended = blendOverlay(overlay, on: image, positionX: parameters.lightPositionX, positionY: parameters.lightPositionY, opacity: intensity * 0.25) {
                image = blended
            }
        default:
            break
        }

        return image
    }

    private func loadLightLeakForStyle(_ style: GlowStyle) -> CIImage? {
        let index: Int
        switch style {
        case .warmLightLeak: index = 0
        case .goldenHourGlow: index = 1
        default: index = 2
        }
        let name = lightLeakImageNames[min(index, lightLeakImageNames.count - 1)]
        guard let uiImage = UIImage(named: name),
              let ci = CIImage(image: uiImage) else { return nil }
        return ci
    }

    private func createReflectionOverlay(extent: CGRect) -> CIImage? {
        let width = Int(extent.width)
        let height = Int(extent.height)
        guard width > 0, height > 0 else { return nil }
        let centerX = extent.midX
        let centerY = extent.midY
        let maxDist = sqrt(extent.width * extent.width + extent.height * extent.height) / 2
        guard let cgContext = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        let buffer = cgContext.data!.assumingMemoryBound(to: UInt8.self)
        for y in 0..<height {
            for x in 0..<width {
                let dx = Double(x) - centerX
                let dy = Double(y) - centerY
                let d = sqrt(dx * dx + dy * dy)
                let t = min(1, d / maxDist)
                let a = UInt8((1 - t * t) * 80)
                let i = (y * width + x) * 4
                buffer[i] = 255
                buffer[i + 1] = 255
                buffer[i + 2] = 255
                buffer[i + 3] = a
            }
        }
        guard let cgImage = cgContext.makeImage() else { return nil }
        return CIImage(cgImage: cgImage)
    }

    private func blendOverlay(_ overlay: CIImage, on base: CIImage, positionX: Double, positionY: Double, opacity: Double) -> CIImage? {
        let scaleX = base.extent.width / max(overlay.extent.width, 1)
        let scaleY = base.extent.height / max(overlay.extent.height, 1)
        let scale = max(scaleX, scaleY)
        let scaled = overlay.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let dx = base.extent.minX + (base.extent.width - scaled.extent.width) * positionX
        let dy = base.extent.minY + (base.extent.height - scaled.extent.height) * positionY
        let positioned = scaled.transformed(by: CGAffineTransform(translationX: dx - scaled.extent.minX, y: dy - scaled.extent.minY))
        guard let blend = CIFilter(name: "CISourceOverCompositing") else { return nil }
        guard let opacityFilter = CIFilter(name: "CIColorMatrix") else { return nil }
        opacityFilter.setValue(positioned, forKey: kCIInputImageKey)
        opacityFilter.setValue(CIVector(x: 1, y: 0, z: 0, w: 0), forKey: "inputRVector")
        opacityFilter.setValue(CIVector(x: 0, y: 1, z: 0, w: 0), forKey: "inputGVector")
        opacityFilter.setValue(CIVector(x: 0, y: 0, z: 1, w: 0), forKey: "inputBVector")
        opacityFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(opacity)), forKey: "inputAVector")
        let faded = opacityFilter.outputImage?.cropped(to: positioned.extent) ?? positioned
        blend.setValue(faded, forKey: kCIInputImageKey)
        blend.setValue(base, forKey: kCIInputBackgroundImageKey)
        return blend.outputImage?.cropped(to: base.extent)
    }

    private func applyVignette(_ input: CIImage, amount: Double) -> CIImage {
        guard amount > 0.01 else { return input }
        guard let vignette = CIFilter(name: "CIVignette") else { return input }
        vignette.setValue(input, forKey: kCIInputImageKey)
        vignette.setValue(CIVector(x: input.extent.midX, y: input.extent.midY), forKey: kCIInputCenterKey)
        vignette.setValue(amount * 2.5, forKey: kCIInputIntensityKey)
        return vignette.outputImage?.cropped(to: input.extent) ?? input
    }

    private func applyGrain(_ input: CIImage, amount: Double) -> CIImage {
        guard amount > 0.01 else { return input }
        guard let noise = CIFilter(name: "CIRandomGenerator") else { return input }
        let noiseImage = noise.outputImage?.cropped(to: input.extent) ?? input
        guard let blend = CIFilter(name: "CISourceOverCompositing") else { return input }
        guard let opacityFilter = CIFilter(name: "CIColorMatrix") else { return input }
        opacityFilter.setValue(noiseImage, forKey: kCIInputImageKey)
        opacityFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: CGFloat(amount * 0.15)), forKey: "inputAVector")
        let fadedNoise = opacityFilter.outputImage?.cropped(to: input.extent) ?? noiseImage
        blend.setValue(fadedNoise, forKey: kCIInputImageKey)
        blend.setValue(input, forKey: kCIInputBackgroundImageKey)
        return blend.outputImage?.cropped(to: input.extent) ?? input
    }
}
