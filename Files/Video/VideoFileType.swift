//
//  VideoFileType.swift
//  Files
//
//  Created by 翟泉 on 2019/4/2.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

struct VideoFileType: FileType {
    var pathExtensions: [String] = ["mp4", "flv"]
    static var pathExtensions: [String] = ["mp4", "flv"]

    func thumbnail(file: File, completion: @escaping (UIImage) -> Void) {
        FileThumbnailCache.shared.retrieveImage(identifier: file.identifier, sourceImage: { () -> UIImage? in
            return nil
        }) { (_, image) in
            completion(image ?? UIImage(named: "icon_video")!)
        }
    }

    func openFile(_ file: File, document: Document, controller: DocumentBrowserViewController) {
    }
}
