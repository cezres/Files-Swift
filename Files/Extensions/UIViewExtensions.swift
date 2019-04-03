//
//  UIViewExtensions.swift
//  Files
//
//  Created by 翟泉 on 2019/4/2.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

extension UIView {
    // MARK: - origin

    var origin: CGPoint {
        get {
            return frame.origin
        }
        set {
            frame = CGRect(origin: newValue, size: size)
        }
    }

    var x: CGFloat {
        get {
            return origin.x
        }
        set {
            origin = CGPoint(x: newValue, y: y)
        }
    }

    var y: CGFloat {
        get {
            return origin.y
        }
        set {
            origin = CGPoint(x: x, y: newValue)
        }
    }

    // MARK: - Size

    var size: CGSize {
        get {
            return frame.size
        }
        set {
            frame = CGRect(origin: origin, size: newValue)
        }
    }

    var width: CGFloat {
        get {
            return size.width
        }
        set {
            size = CGSize(width: newValue, height: height)
        }
    }

    var height: CGFloat {
        get {
            return size.height
        }
        set {
            size = CGSize(width: width, height: newValue)
        }
    }
}

extension UIView {
    var viewController: UIViewController? {
        var response = next
        while response != nil  {
            if (response as? UIViewController) != nil {
                break
            }
            response = response?.next
        }
        return response as? UIViewController
    }
}
