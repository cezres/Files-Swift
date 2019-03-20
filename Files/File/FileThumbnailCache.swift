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

    private override init() {
        super.init()
        let format = FICImageFormat(name: formatName, family: formatFamily, imageSize: CGSize(width: 160, height: 160), style: .style32BitBGR, maximumCount: 200, devices: .phone, protectionMode: .none)!
        imageCache.setFormats([format])
        imageCache.delegate = self
    }

    func retrieveImage(identifier: String, sourceImage: @escaping () -> UIImage, completion: @escaping CompletionBlock) {
        let entity = FileThumbnail(identifier: identifier, sourceImage: sourceImage)
        let completionBlock: FICImageCacheCompletionBlock = { (entity, _, image) in
            guard let entity = entity as? FileThumbnail else { return }
            completion(entity.identifier, image)
        }

        if imageCache.imageExists(for: entity, withFormatName: formatName) {
            imageCache.retrieveImage(for: entity, withFormatName: formatName, completionBlock: completionBlock)
        } else {
            imageCache.retrieveImage(for: entity, withFormatName: formatName, completionBlock: completionBlock)
        }
    }
}

extension FileThumbnailCache: FICImageCacheDelegate {
}


private class FileThumbnail: NSObject, FICEntity {
    var identifier: String
    var sourceImage: () -> UIImage

    init(identifier: String, sourceImage: @escaping () -> UIImage) {
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
            context.clear(contextBounds)
            context.setFillColor(UIColor.white.cgColor)
            context.fill(contextBounds)

            UIGraphicsPushContext(context)
            image.square().draw(in: contextBounds)
            UIGraphicsPopContext()
        }
    }
}
