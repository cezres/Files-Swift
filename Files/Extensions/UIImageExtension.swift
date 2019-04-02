//
//  UIImageExtension.swift
//  Files
//
//  Created by 翟泉 on 2019/3/20.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func decode() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = ByteAlignForCoreAnimation(bytesPerRow: width * 4)
        let bitmapInfo = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        let context: CGContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo)!
        context.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: height)))
        let inflatedCGImage = context.makeImage()!
        return UIImage(cgImage: inflatedCGImage)
    }

    private func ByteAlignForCoreAnimation(bytesPerRow: Int) -> Int {
        return ((bytesPerRow + (64 - 1)) / 64) * 64
    }

    func scale(width: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: width / self.size.width * self.size.height)
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: CGPoint(x: 0,y: 0), size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    func square() -> UIImage {
        let rect: CGRect
        if size.width > size.height {
            rect = CGRect(x: (size.width-size.height)/2, y: 0, width: size.height, height: size.height)
        }
        else if size.width < size.height {
            rect = CGRect(x: 0, y: (size.height-size.width)/2, width: size.width, height: size.width)
        }
        else {
            return self
        }

        if let imageRef = cgImage!.cropping(to: rect) {
            return UIImage(cgImage: imageRef)
        }
        return self
    }
}
