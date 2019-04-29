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
    var isControlHidden = false
    var hideControlTimeinterval: TimeInterval = 6

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
        controls.forEach { $0.cleanup() }
        controls.removeAll()
        player?.view.removeFromSuperview()
        player?.shutdown()
        player = nil
    }

    func registerControl(_ control: MediaPlayerCtrlAble) {
        var control = control
        control.playerView = self
        control.reset()
        controls.append(control)
    }

    private var player: IJKMediaPlayback?
    private var controls = [MediaPlayerCtrlAble]()

    init() {
        super.init(frame: .zero)

        IJKFFMoviePlayerController.setLogLevel(IJKLogLevel(rawValue: 7))
        IJKFFMoviePlayerController.setLogReport(false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerPlaybackStateDidChange(_:)), name: .IJKMPMoviePlayerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerLoadStateDidChange(_:)), name: .IJKMPMoviePlayerLoadStateDidChange, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private var tempBounds: CGRect = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        if tempBounds != bounds {
            tempBounds = bounds
            player?.view.frame = bounds
            controls.forEach({ $0.layoutView(for: bounds) })
        }
    }

    @objc func playerPlaybackStateDidChange(_ notification: Notification) {
        guard let playbackState = player?.playbackState else { return }
        self.playbackState = PlaybackState(playbackState:  playbackState)
    }

    @objc func playerLoadStateDidChange(_ notification: Notification) {
        guard let loadState = player?.loadState else { return }
        self.loadState = LoadState(rawValue: loadState.rawValue)
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
        get {
            return player?.currentPlaybackTime ?? 0
        }
        set {
            play()
            player?.currentPlaybackTime = newValue
        }
    }

    var duration: TimeInterval {
        return player?.duration ?? 0
    }

    private(set) var playbackState: PlaybackState {
        get {
            return PlaybackState(playbackState: player?.playbackState ?? .stopped)
        }
        set {
            controls.forEach { $0.playerDidChangePlayBackState(newValue) }

            if newValue == .stopped {
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateControlHideState(_:)), object: NSNumber(booleanLiteral: true))
            } else if newValue == .playing {
                if !isControlHidden && hideControlTimeinterval > 0 {

                }
            }
        }
    }

    private(set) var loadState: LoadState {
        get {
            return LoadState(rawValue: player?.loadState.rawValue ?? 0)
        }
        set {
            controls.forEach { $0.playerDidChangeLoadState(newValue) }
        }
    }
}

extension MediaPlayerView {
    @objc func updateControlHideState(_ state: NSNumber) {
    }
}
