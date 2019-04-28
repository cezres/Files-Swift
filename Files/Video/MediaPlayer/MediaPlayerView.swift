//
//  VideoPlayer.swift
//  Files
//
//  Created by 翟泉 on 2019/4/1.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import MediaPlayer
import IJKMediaFramework

class MediaPlayerView: UIView {
    private(set) var url: URL?

    func play(_ url: URL) {
        if playbackState == .paused && loadState.isDisjoint(with: .playable) && self.url == url {
            play()
        } else {
            stop()
            self.url = url
            initPlayer(with: url)
            player?.prepareToPlay()
        }
    }

    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.view.removeFromSuperview()
        player?.shutdown()
        player = nil
        controls.forEach({ $0.playerDidChangePlayBackState(.stopped) })
    }

    func shutdown() {

    }

    func addControl(_ control: MediaPlayerCtrlAble) {

    }

    private var player: IJKMediaPlayback?
    private var controls = [MediaPlayerCtrlAble]()

    init() {
        super.init(frame: .zero)

        NotificationCenter.default.addObserver(self, selector: #selector(playerPlaybackStateDidChange(_:)), name: .IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerLoadStateDidChange(_:)), name: .IJKMPMoviePlayerLoadStateDidChange, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func playerPlaybackStateDidChange(_ notification: Notification) {

    }

    @objc func playerLoadStateDidChange(_ notification: Notification) {

    }

    func initPlayer(with url: URL) {
        let MIMEType = MediaPlayerView.MIMEType(with: url) ?? ""
        if AVURLAsset.isPlayableExtendedMIMEType(MIMEType) {
            player = IJKAVMoviePlayerController(contentURL: url)
        } else {
            player = IJKFFMoviePlayerController(contentURL: url, with: .byDefault())
        }
        player?.view.autoresizingMask = UIView.AutoresizingMask(arrayLiteral: .flexibleWidth, .flexibleHeight)
        player?.scalingMode = .aspectFit
        player?.shouldAutoplay = true
        insertSubview(player!.view, at: 0)
    }
}

extension MediaPlayerView {
    var currentPlaybackTime: TimeInterval {
        return player?.currentPlaybackTime ?? 0
    }

    var duration: TimeInterval {
        return player?.duration ?? 0
    }

    var playbackState: PlaybackState {
        return PlaybackState(playbackState: player?.playbackState ?? .stopped)
    }

    var loadState: LoadState {
        return LoadState(rawValue: player?.loadState.rawValue ?? 0)
    }
}
