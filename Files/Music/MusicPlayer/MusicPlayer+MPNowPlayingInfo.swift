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
        guard let music = music else { return }
        info[MPMediaItemPropertyTitle] = music.song
        info[MPMediaItemPropertyArtist] = music.singer
        info[MPMediaItemPropertyAlbumTitle] = music.albumName
        info[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: music.duration)
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: currentTime)
        if let artworkImage = music.artwork {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size, requestHandler: { _ in artworkImage })
        }
    }
}
