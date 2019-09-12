//
//  MusicFileType.swift
//  Files
//
//  Created by 翟泉 on 2019/3/21.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Toast_Swift

struct MusicFileType: FileType {
    let name = "Music"
    let pathExtensions = ["mp3", "wav"]

    func thumbnail(file: File, completion: @escaping (UIImage) -> Void) {
        FileThumbnailCache.shared.retrieveImage(identifier: file.identifier, sourceImage: { () -> UIImage? in
            return Music.artwork(for: file.url) ?? UIImage(named: "icon_audio")
        }) { (_, image) in
            completion(image!)
        }
    }

    func openFile(_ file: File, document: Document, controller: DocumentBrowserViewController) {
        let music = Music(url: file.url)
        let items = document.contents.filter { type(of: $0.type) == type(of: MusicFileType()) }.map { Music(url: $0.url) }
        let index = items.firstIndex(of: music)!

        do {
            if MusicPlayer.shared.music == music {
                if MusicPlayer.shared.state == .paused {
                    try MusicPlayer.shared.resume()
                } else if MusicPlayer.shared.state == .playing {
                    MusicPlayer.shared.pause()
                } else {
                    try MusicPlayer.shared.play(items, index: index)
                }
            } else {
                try MusicPlayer.shared.play(items, index: index)
            }

            if MusicPlayer.shared.isPlaying {
                controller.navigationController?.pushViewController(MusicPlayerViewController(), animated: true)
            }
        } catch {
            controller.view.makeToast(error.localizedDescription)
        }
    }
}
