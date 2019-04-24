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
                NotificationCenter.default.post(name: Notification.didChangeState, object: nil)
            }
        }
    }
    private(set) var music: Music? {
        didSet {
            NotificationCenter.default.post(name: Notification.didChangeMusic, object: nil)
        }
    }

    @discardableResult func play(_ music: Music) -> Bool {
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
    let bufferSize: Int

    private init(bufferSize: Int = 2048) {
        self.bufferSize = bufferSize
        configRemoteComtrol()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        try! engine.start()
        engine.mainMixerNode.removeTap(onBus: 0)
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(bufferSize), format: nil) { (buffer, when) in
            guard self.state == .playing else { return }
            buffer.frameLength = AVAudioFrameCount(self.bufferSize)
            NotificationCenter.default.post(name: Notification.didReceivePCMBuffer, object: nil, userInfo: ["buffer": buffer])
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
