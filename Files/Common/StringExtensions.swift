//
//  StringExtensions.swift
//  Files
//
//  Created by 翟泉 on 2019/9/4.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation

extension String {
    var pathExtension: String {
        let array = components(separatedBy: ".")
        guard array.count > 1 else {
            return ""
        }
        return array[array.count - 1]
    }

    var lastPathComponent: String {
        let array = components(separatedBy: "/")
        return array[array.count - 1]
    }

    var deletingPathExtension: String {
        guard let range = range(of: ".", options: String.CompareOptions.backwards, range: nil, locale: nil) else {
            return self
        }
        return String(prefix(upTo: range.lowerBound))
    }

    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }

    var relativePath: String {
        guard let range = range(of: DocumentDirectory.path) else {
            return ""
        }
        return String(suffix(from: range.upperBound))
    }
}

extension String {
    public var urlParametersDecode: [String: String] {
        guard let string = self.components(separatedBy: "?").last else { return [:] }
        var parameters = [String: String]()
        string.components(separatedBy: "&").forEach { (keyValue) in
            let components = keyValue.components(separatedBy: "=")
            guard components.count == 2 else { return }
            parameters[components[0]] = components[1].removingPercentEncoding
        }
        return parameters
    }
}
