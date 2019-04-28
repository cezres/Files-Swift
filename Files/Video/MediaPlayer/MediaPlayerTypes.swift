//
//  MediaPlayerTypes.swift
//  Files
//
//  Created by 翟泉 on 2019/4/26.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import IJKMediaFramework

extension MediaPlayerView {
    struct LoadState: OptionSet {
        let rawValue: UInt

        static let unknown = LoadState(rawValue: 0)
        static let playable = LoadState(rawValue: 1 << 0)
        static let playthroughOK = LoadState(rawValue: 1 << 1)
        static let stalled = LoadState(rawValue: 1 << 1)

        static let all: [LoadState] = [.unknown, .playable, .playthroughOK, .stalled]
    }

    enum PlaybackState {
        case stopped
        case playing
        case paused
        case interrupted
        case seekingForward
        case seekingBackward

        init(playbackState: IJKMPMoviePlaybackState) {
            switch playbackState {
            case .stopped:
                self = .stopped
            case .playing:
                self = .playing
            case .paused:
                self = .paused
            case .interrupted:
                self = .interrupted
            case .seekingForward:
                self = .seekingForward
            case .seekingBackward:
                self = .seekingBackward
            @unknown default:
                fatalError()
            }
        }
    }
}
