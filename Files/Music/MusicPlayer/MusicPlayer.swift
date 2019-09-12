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
    var playMode: PlayMode = .loopAll
    private(set) var items = [Music]()
    private(set) var music: Music? {
        didSet {
            DispatchQueue.main.async {
                self.configNowPlayingInfoCenter()
                NotificationCenter.default.post(name: Notification.didChangeMusic, object: nil)
            }
        }
    }
    private(set) var state: State = .stopped {
        didSet {
            guard state != oldValue else { return }
            DispatchQueue.main.async {
                self.configNowPlayingInfoCenter()
                NotificationCenter.default.post(name: Notification.didChangeState, object: nil)
            }
        }
    }
    var currentTime: TimeInterval {
        get {
            if state == .paused || state == .stopped {
                guard let playTime = pausePlayTime else { return 0 }
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

    /// Private
    private let engine = AVAudioEngine()
    private let player: AVAudioPlayerNode = AVAudioPlayerNode()
    private var audioFile: AVAudioFile?
    private var startingFrame: AVAudioFramePosition = 0
    private var pausePlayTime: AVAudioTime?
    let bufferSize: Int

    init(bufferSize: Int = 2048) {
        self.bufferSize = bufferSize
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
        configRemoteComtrol()
    }
}

// MARK: - Control
extension MusicPlayer {
    func next() throws {
        guard let music = music else { return }
        guard let currentIndex = items.firstIndex(of: music) else { return }
        let targetIndex = currentIndex == items.count - 1 ? 0 : currentIndex + 1
        try play(music: items[targetIndex])
    }
    func previous() throws {
        guard let music = music else { return }
        guard let currentIndex = items.firstIndex(of: music) else { return }
        let targetIndex = currentIndex == 0 ? items.count - 1 : currentIndex - 1
        try play(music: items[targetIndex])
    }

    func play(_ music: Music) throws {
        try play([music])
    }

    func play(_ items: [Music], index: Int = 0) throws {
        self.items = items
        try play(music: items[index])
    }

    func resume() throws {
        switch state {
        case .playing:
            break
        case .paused:
            player.play()
            state = .playing
        case .stopped:
            if let music = music {
                try play(music: music)
            }
        }
    }

    func stop() {
        if isPlaying {
            player.stop()
        }
        state = .stopped
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }

    func pause() {
        pausePlayTime = player.lastPlayTime
        player.pause()
        state = .paused
    }


    private func play(music: Music) throws {
        if player.isPlaying {
            stop()
        }

        try AVAudioSession.sharedInstance().setActive(true)
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        UIApplication.shared.beginReceivingRemoteControlEvents()

        audioFile = try AVAudioFile(forReading: music.url)
        player.scheduleFile(audioFile!, at: nil) { [weak self] in
            self?.playerDidFinishPlaying()
        }
        player.play()

        self.music = music
        startingFrame = 0
        state = .playing
    }

    private func seek(to time: TimeInterval) {
        guard let audioFile = audioFile else { return }
        guard let lastNodeTime = player.lastRenderTime, let playerTime = player.playerTime(forNodeTime: lastNodeTime) else { return }
        let sampleRate = playerTime.sampleRate
        let newSampleTime = AVAudioFramePosition(sampleRate * time)
        let framestoplay = AVAudioFrameCount(audioFile.length - newSampleTime)

        guard framestoplay > 1000 else { return }
        player.stop()
        player.scheduleSegment(audioFile, startingFrame: newSampleTime, frameCount: framestoplay, at: nil) { [weak self] in
            self?.playerDidFinishPlaying()
        }
        player.play()
        startingFrame = newSampleTime
    }

    private func playerDidFinishPlaying() {
        guard duration - currentTime < 2 else { return }
        switch (playMode) {
        case .loopSingle:
            try? resume()
        case .loopAll:
            try? next()
        case .random:
            let index = Int(arc4random_uniform(UInt32(items.count)))
            try? play(music: items[index])
        }
    }
}
