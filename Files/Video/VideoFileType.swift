//
//  VideoFileType.swift
//  Files
//
//  Created by 翟泉 on 2019/4/2.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import IJKMediaFramework

struct VideoFileType: FileType {
    var pathExtensions: [String] = ["mp4", "flv"]
    static var pathExtensions: [String] = ["mp4", "flv"]

    func thumbnail(file: File, completion: @escaping (UIImage) -> Void) {
        FileThumbnailCache.shared.retrieveImage(identifier: file.identifier, sourceImage: { () -> UIImage? in
            let result = IJKFFMovieScreenshot.screenshot(withVideo: file.url.path, forSeconds: 4)
            return result  ?? UIImage(named: "icon_video")
        }) { (_, image) in
            completion(image ?? UIImage(named: "icon_video")!)
        }
    }

    func openFile(_ file: File, document: Document, controller: DocumentBrowserViewController) {
        let mediaPlayer = MediaPlayerViewController(url: file.url)
        controller.present(mediaPlayer, animated: true, completion: nil)
    }
}
