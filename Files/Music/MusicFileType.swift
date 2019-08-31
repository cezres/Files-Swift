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
        guard let music = Music(url: file.url) else { return }

        if MusicPlayer.shared.music == music {
            if MusicPlayer.shared.state == .paused {
                MusicPlayer.shared.play()
            } else if MusicPlayer.shared.state == .playing {
                MusicPlayer.shared.pause()
            } else {
                MusicPlayer.shared.play(music)
            }
        } else {
            MusicPlayer.shared.play(music)
        }

        if MusicPlayer.shared.isPlaying {
            controller.navigationController?.pushViewController(MusicPlayerViewController(), animated: true)
//            controller.present(MusicPlayerViewController(), animated: true, completion: nil)
        }
    }
}
