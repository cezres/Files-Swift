//
//  MusicPlayer+MPNowPlayingInfo.swift
//  Files
//
//  Created by 翟泉 on 2019/4/24.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import MediaPlayer

extension MusicPlayer {
    func configNowPlayingInfoCenter() {
        var info = [String: Any]()
        defer {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
        guard let metadata = music?.metadata else { return }
        info[MPMediaItemPropertyTitle] = metadata.song
        info[MPMediaItemPropertyArtist] = metadata.singer
        info[MPMediaItemPropertyAlbumTitle] = metadata.albumName
        info[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: metadata.duration)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: currentTime)
        if let artworkImage = metadata.artwork {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size, requestHandler: { _ in artworkImage })
        }
    }
}
