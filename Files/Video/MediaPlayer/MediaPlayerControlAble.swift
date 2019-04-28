//
//  MediaPlayerControlAble.swift
//  Files
//
//  Created by 翟泉 on 2019/4/26.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

protocol MediaPlayerCtrlAble {
    var playerView: MediaPlayerView? { get set }

    func reset()

    func cleanup()

    // MAKR: - View
    var isCanHideCtrlView: Bool { get }

    func setControlViewHidden(_ hidden: Bool)

    func layoutView(for bounds: CGRect)

    // MAKR: - State
    func playerDidChangeLoadState(_ loadState: MediaPlayerView.LoadState)

    func playerDidChangePlayBackState(_ backState: MediaPlayerView.PlaybackState)
}

