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

class MusicPlayer {
    static let shared = MusicPlayer()
    private(set) var state: State = .stopped {
        didSet {
            guard state != oldValue else { return }
            DispatchQueue.main.async {
                self.configNowPlayingInfoCenter()
                NotificationCenter.default.post(name: Notification.stateChanged, object: nil)
            }
        }
    }
    private(set) var music: Music? {
        didSet {
            NotificationCenter.default.post(name: Notification.musicChanged, object: nil)
        }
    }

    @discardableResult
    func play(_ music: Music) -> Bool {
        player.isPlaying ? player.stop() : nil
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            UIApplication.shared.beginReceivingRemoteControlEvents()

            audioFile = try AVAudioFile(forReading: music.url)
            player.scheduleFile(audioFile!, at: nil) { [weak self] in
                self?.scheduleCompletionHandler()
            }
            player.play()

            self.music = music
            startingFrame = 0
            state = .playing
            return true
        } catch {
            return false
        }
    }

    func seek(to time: TimeInterval) {
        guard let audioFile = audioFile else { return }
        guard let lastNodeTime = player.lastRenderTime, let playerTime = player.playerTime(forNodeTime: lastNodeTime) else { return }
        let sampleRate = playerTime.sampleRate
        let newSampleTime = AVAudioFramePosition(sampleRate * time)
        let framestoplay = AVAudioFrameCount(audioFile.length - newSampleTime)

        guard framestoplay > 1000 else { return }
        player.stop()
        player.scheduleSegment(audioFile, startingFrame: newSampleTime, frameCount: framestoplay, at: nil) { [weak self] in
            self?.scheduleCompletionHandler()
        }
        player.play()
        startingFrame = newSampleTime
    }

    @discardableResult func play() -> Bool {
        switch state {
        case .playing:
            return true
        case .paused:
            player.play()
            state = .playing
            return true
        case .stopped:
            if let music = music {
                return play(music)
            } else {
                return false
            }
        }
    }

    func stop() {
        player.stop()
        state = .stopped
    }

    func pause() {
        pausePlayTime = player.lastPlayTime
        player.pause()
        state = .paused
    }

    // MARK: - Private
    private let engine = AVAudioEngine()
    private let player: AVAudioPlayerNode = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var startingFrame: AVAudioFramePosition = 0
    private var pausePlayTime: AVAudioTime?

    private init(bufferSize: Int = 2048) {
        configRemoteComtrol()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        try! engine.start()
        engine.mainMixerNode.removeTap(onBus: 0)
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(bufferSize), format: nil) { (buffer, when) in
        }
    }

    private func scheduleCompletionHandler() {
        if duration - currentTime < 2 {
            state = .stopped
        }
    }
}

extension MusicPlayer {
    var currentTime: TimeInterval {
        get {
            if state == .paused || state == .stopped {
                guard let playTime = pausePlayTime else { return 0}
                return Double(playTime.sampleTime + startingFrame) / playTime.sampleRate
            }
            guard let playTime = player.lastPlayTime else { return 0 }
            return min(Double(playTime.sampleTime + startingFrame) / playTime.sampleRate, duration)
        }
        set {
            seek(to: newValue)
        }
    }
    var duration: TimeInterval {
        return audioFile?.duration ?? 0
    }
    var isPlaying: Bool {
        return player.isPlaying
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

extension AVAudioTime {
    var timeInterval: TimeInterval {
        return Double(sampleTime) / sampleRate
    }
}

extension AVAudioPlayerNode {
    var lastPlayTime: AVAudioTime? {
        guard let nodeTime = lastRenderTime else { return nil }
        return playerTime(forNodeTime: nodeTime)
    }
}

extension AVAudioFile {
    var duration: TimeInterval {
        return TimeInterval(length) / fileFormat.sampleRate
    }
}
