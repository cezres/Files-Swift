//
//  PhotoFileType.swift
//  Files
//
//  Created by 翟泉 on 2019/3/19.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import UIKit

struct PhotoFileType: FileType {
    var pathExtensions: [String] = ["jpg",  "png"]

    func thumbnail(file: File, completion: @escaping (UIImage) -> Void) {
        FileThumbnailCache.shared.retrieveImage(identifier: file.identifier, sourceImage: { () -> UIImage in
            return UIImage(contentsOfFile: file.url.path)!
        }) { (_, image) in
            completion(image!)
        }
    }

    func openFile(_ file: File, document: Document, controller: DocumentBrowserViewController) {
        let results = document.contents.filter({ $0.type is PhotoFileType })
        let photoBrowser = PhotoBrowserViewController(files: results)
        controller.navigationController?.pushViewController(photoBrowser, animated: true)
    }
}
