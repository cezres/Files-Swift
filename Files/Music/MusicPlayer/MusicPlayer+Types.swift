//
//  MusicPlayer+Types.swift
//  Files
//
//  Created by 翟泉 on 2019/4/24.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

extension MusicPlayer {
    enum State {
        case playing
        case stopped
        case paused
    }

    enum PlayMode {
        case loopAll
        case loopSingle
        case random
    }

    struct Notification {
        static let didChangeState = NSNotification.Name("MusicPlayer.didChangeState")
        static let didChangeMusic = NSNotification.Name("MusicPlayer.didChangeMusic")
        static let didReceivePCMBuffer = NSNotification.Name("MusicPlayer.didReceivePCMBuffer") // userInfo: ["buffer": buffer]
    }
}
