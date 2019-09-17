//
//  Utils.swift
//  Files
//
//  Created by 翟泉 on 2019/9/7.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

func makeToastToWindow(code: () throws -> Void) {
    do {
        try code()
    } catch {
        UIApplication.shared.keyWindow?.makeToast(error.localizedDescription)
    }
}

func generateFilePath(name: String, pathExtension: String, directory: URL) -> URL {
    var filePath = directory.appendingPathComponent(name + (pathExtension.count > 0 ? ".\(pathExtension)" : ""))
    var flag = 1
    while FileManager.default.fileExists(atPath: filePath.path) {
        if pathExtension == "" {
            filePath = directory.appendingPathComponent("\(name)\(flag)")
        } else {
            filePath = directory.appendingPathComponent("\(name)\(flag).\(pathExtension)")
        }
        flag += 1
    }
    return filePath
}
