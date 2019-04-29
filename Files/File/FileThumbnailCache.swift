//
//  FileThumbnail.swift
//  Files
//
//  Created by 翟泉 on 2019/3/20.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import FastImageCache

class FileThumbnailCache: NSObject {
    typealias CompletionBlock = (String, UIImage?) -> Void

    static let shared = FileThumbnailCache()

    private let imageCache: FICImageCache = FICImageCache.shared()
    private let formatFamily = "ImageFormatFamily"
    private let formatName = "FileIconCacheFormatName"
    private let queue = OperationQueue()

    private override init() {
        super.init()
        let format = FICImageFormat(name: formatName, family: formatFamily, imageSize: CGSize(width: 160, height: 160), style: .style32BitBGR, maximumCount: 200, devices: .phone, protectionMode: .none)!
        imageCache.setFormats([format])
        imageCache.delegate = self
//        imageCache.reset()
        queue.maxConcurrentOperationCount = 1
    }

    func retrieveImage(identifier: String, sourceImage: @escaping () -> UIImage?, completion: @escaping CompletionBlock) {
        let entity = FileThumbnail(identifier: identifier, sourceImage: sourceImage)
        let completionBlock: FICImageCacheCompletionBlock = { (entity, _, image) in
            guard let entity = entity as? FileThumbnail else { return }
            if Thread.isMainThread {
                completion(entity.identifier, image)
            } else {
                DispatchQueue.main.async {
                    completion(entity.identifier, image)
                }
            }
        }

        queue.addOperation {
            if self.imageCache.imageExists(for: entity, withFormatName: self.formatName) {
                self.imageCache.retrieveImage(for: entity, withFormatName: self.formatName, completionBlock: completionBlock)
            } else {
                self.imageCache.retrieveImage(for: entity, withFormatName: self.formatName, completionBlock: completionBlock)
            }
        }
    }
}

extension FileThumbnailCache: FICImageCacheDelegate {
}


private class FileThumbnail: NSObject, FICEntity {
    var identifier: String
    var sourceImage: () -> UIImage?

    init(identifier: String, sourceImage: @escaping () -> UIImage?) {
        self.identifier = identifier
        self.sourceImage = sourceImage
    }

    // MARK: - FICEntity

    @objc(UUID) var uuid: String! {
        return self.identifier
    }

    var sourceImageUUID: String! {
        return self.identifier
    }

    func sourceImageURL(withFormatName formatName: String!) -> URL! {
        return URL(fileURLWithPath: "/")
    }

    func image(for format: FICImageFormat!) -> UIImage! {
        return sourceImage()
    }

    func drawingBlock(for image: UIImage!, withFormatName formatName: String!) -> FICEntityImageDrawingBlock! {
        return { (context: CGContext?, contextSize: CGSize) -> Void in
            guard let context = context else {
                return
            }
            let contextBounds = CGRect(origin: .zero, size: contextSize)
//            context.clear(contextBounds)
            context.setFillColor(UIColor.white.cgColor)
            context.fill(contextBounds)

            var drawRect = CGRect.zero
            let imageSize = image.size
            let contextAspectRatio = contextSize.width / contextSize.height
            let imageAspectRatio = imageSize.width / imageSize.height
            if contextAspectRatio == imageAspectRatio {
                drawRect = contextBounds
            } else if contextAspectRatio > imageAspectRatio {
                let drawWidth = contextSize.height * imageAspectRatio
                drawRect = CGRect(x: (contextSize.width - drawWidth) / 2, y: 0, width: drawWidth, height: contextSize.height)
            } else {
                let drawHeight = contextSize.width * imageSize.height / imageSize.width
                drawRect = CGRect(x: 0, y: (contextSize.height - drawHeight) / 2, width: contextSize.width, height: drawHeight)
            }

            UIGraphicsPushContext(context)
            image.draw(in: drawRect)
            UIGraphicsPopContext()
        }
    }
}
