//
//  MusicPlayer.swift
//  Files
//
//  Created by 翟泉 on 2019/3/21.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class MusicPlayer: NSObject {
    static let shared = MusicPlayer()
    private(set) var state: State = .stopped {
        didSet {
            configNowPlayingInfoCenter()
            NotificationCenter.default.post(name: Notification.stateChanged, object: nil)
        }
    }
    private(set) var music: Music? {
        didSet {
            NotificationCenter.default.post(name: Notification.musicChanged, object: nil)
        }
    }
    var currentTime: TimeInterval {
        get {
            return player?.currentTime ?? 0
        }
        set {
            player?.currentTime = newValue
        }
    }
    var duration: TimeInterval {
        configNowPlayingInfoCenter()
        return player?.duration ?? 0
    }
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }

    @discardableResult
    func play(_ music: Music) -> Bool {
        guard music.url != player?.url else { return play() }
        stop()
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            UIApplication.shared.beginReceivingRemoteControlEvents()
            player = try AVAudioPlayer(contentsOf: music.url)
            player?.delegate = self
            self.music = music
            return play()
        } catch {
            return false
        }
    }

    @discardableResult
    func play() -> Bool {
        guard let player = player else { return false }
        if player.play() {
            state = .playing
            return true
        } else {
            return false
        }
    }

    func stop() {
        guard let player = player else { return }
        player.stop()
        self.player = nil
        self.music = nil
        state = .stopped
    }

    func pause() {
        guard let player = player else { return }
        player.pause()
        state = .paused
    }

    // MARK: - Private
    private var player: AVAudioPlayer?

    private override init() {
        super.init()
        configRemoteComtrol()
    }
}

extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        state = .stopped
    }
}

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
}

extension MusicPlayer {
    struct Notification {
        static let stateChanged = NSNotification.Name("MusicPlayer_State_Changed")
        static let musicChanged = NSNotification.Name("MusicPlayer_Music_Changed")
    }
}

// MARK: - RemoteComtrol
extension MusicPlayer {
    func configRemoteComtrol() {
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
            self?.pause()
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().playCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
            guard let weakself = self else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
            if weakself.play() {
                return MPRemoteCommandHandlerStatus.success
            }
            else {
                return MPRemoteCommandHandlerStatus.commandFailed
            }
        }
        MPRemoteCommandCenter.shared().stopCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
            self?.stop()
            return MPRemoteCommandHandlerStatus.success
        }

        // MARK: Previous/Next
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
//            self?.next()
            return MPRemoteCommandHandlerStatus.success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget { [weak self](event) -> MPRemoteCommandHandlerStatus in
//            self?.previous()
            return MPRemoteCommandHandlerStatus.success
        }
    }
}

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
