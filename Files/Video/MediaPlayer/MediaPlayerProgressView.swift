//
//  MediaProgressView.swift
//  Files
//
//  Created by 翟泉 on 2019/4/28.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class MediaPlayerProgressView: UISlider {

    init() {
        super.init(frame: .zero)
        minimumTrackTintColor = ColorRGB(219, 92, 92)
        maximumTrackTintColor = ColorWhite(86)
        minimumValue = 0
        maximumValue = 1
        value = 0

        if let thumbImage = generateThumbImage() {
            setThumbImage(thumbImage, for: .normal)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: (bounds.height - 4) / 2, width: bounds.width, height: 4)
    }

    func generateThumbImage() -> UIImage? {
        let width: CGFloat = 10
        UIGraphicsBeginImageContext(CGSize(width: width, height: width))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        let backgroundColor = UIColor.clear
        context.setStrokeColor(backgroundColor.cgColor)
        context.setFillColor(backgroundColor.cgColor)
        context.addRect(CGRect(x: 0, y: 0, width: width, height: width))
        context.drawPath(using: .fillStroke)

        context.setFillColor(UIColor.white.cgColor)
        context.addArc(center: CGPoint(x: width/2, y: width/2), radius: width/2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        context.drawPath(using: .fill)

        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbImage
    }
}
