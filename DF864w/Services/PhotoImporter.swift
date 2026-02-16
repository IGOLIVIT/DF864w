//
//  PhotoImporter.swift
//  DF864w
//

import PhotosUI
import UIKit
import CoreImage
import os.log

protocol PhotoImporting {
    func pickSingleImage() async -> UIImage?
    func loadCIImage(from image: UIImage) -> CIImage?
    func generateThumbnail(from image: UIImage, maxSize: CGFloat) -> UIImage?
}

final class PhotoImporter: PhotoImporting {
    private let logger = Logger(subsystem: "IOI.DF864w", category: "PhotoImporter")

    func pickSingleImage() async -> UIImage? {
        await withCheckedContinuation { continuation in
            Task { @MainActor in
                var config = PHPickerConfiguration()
                config.selectionLimit = 1
                let picker = PHPickerViewController(configuration: config)
                let delegate = PickerDelegate(continuation: continuation)
                picker.delegate = delegate
                objc_setAssociatedObject(picker, &AssociatedKeys.delegate, delegate, .OBJC_ASSOCIATION_RETAIN)
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let root = windowScene.windows.first?.rootViewController else {
                    continuation.resume(returning: nil)
                    return
                }
                var top = root
                while let presented = top.presentedViewController { top = presented }
                top.present(picker, animated: true)
            }
        }
    }

    func loadCIImage(from image: UIImage) -> CIImage? {
        guard let cg = image.cgImage else { return CIImage(image: image) }
        return CIImage(cgImage: cg)
    }

    func generateThumbnail(from image: UIImage, maxSize: CGFloat) -> UIImage? {
        let size = image.size
        let scale = min(maxSize / size.width, maxSize / size.height, 1)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

private enum AssociatedKeys {
    static var delegate = 0
}

private final class PickerDelegate: NSObject, PHPickerViewControllerDelegate {
    let continuation: CheckedContinuation<UIImage?, Never>

    init(continuation: CheckedContinuation<UIImage?, Never>) {
        self.continuation = continuation
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else {
            continuation.resume(returning: nil)
            return
        }
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
            self?.continuation.resume(returning: obj as? UIImage)
        }
    }
}
