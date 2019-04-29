//
//  MediaPlayerGestureRecognizer.swift
//  Files
//
//  Created by 翟泉 on 2019/4/29.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import MediaPlayer

class MediaPlayerGestureRecognizer: MediaPlayerCtrlAble {
    enum PanGestureMode {
        case none
        case volume
        case brightness
        case progress
    }

    weak var playerView: MediaPlayerView! = nil {
        didSet {
            playerView.addGestureRecognizer(tapGestureRecognizer)
            playerView.addGestureRecognizer(panGestureRecognizer)
        }
    }

    var panGestureMode: PanGestureMode = .none
    var tempPlayTime: TimeInterval = 0

    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var panGestureRecognizer: UIPanGestureRecognizer!

    init() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    }

    // MARK: Event

    @objc func handleTapGesture() {
        playerView.isControlHidden = !playerView.isControlHidden
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        print(gesture)

        let translation = gesture.translation(in: playerView)
        let location = gesture.location(in: playerView)
        if panGestureMode == .none {
            if abs(translation.y) > abs(translation.x) {
                if location.x < playerView.width / 2 {
                    panGestureMode = .brightness
                } else {
                    panGestureMode = .volume
                }
            } else if abs(translation.x) > abs(translation.y) {
                if playerView.playbackState == .playing || playerView.playbackState == .paused {
                    panGestureMode = .progress
                    tempPlayTime = playerView.currentPlaybackTime
                }
            } else {
                return
            }
            print(panGestureMode)
        }

        if gesture.state == .changed {
            if panGestureMode == .progress {
                if playerView.playbackState == .playing || playerView.playbackState == .paused {
                    let offset = TimeInterval(translation.x / playerView.width * CGFloat(playerView.duration))
                    let playTime = min(max(tempPlayTime + offset, 0), playerView.duration)
                    MediaPlayerProgressHUD.show(with: playTime, duration: playerView.duration)
                } else {
                    MediaPlayerProgressHUD.hide()
                }
            } else if panGestureMode == .brightness || panGestureMode == .volume {
                let offset = -translation.y / 200
                if panGestureMode == .brightness {
                    UIScreen.main.brightness += offset
                } else if panGestureMode == .volume {
                    let volumeView = MPVolumeView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
                    var volumeSlider: UISlider?
                    for view in volumeView.subviews {
                        if let slider = view as? UISlider {
                            volumeSlider = slider
                            break
                        }
                    }
                    if let volumeSlider = volumeSlider {
                        volumeSlider.setValue(volumeSlider.value + Float(offset), animated: false)
                    }
                }
            }
        } else if gesture.state == .ended {
            if panGestureMode == .progress {
                let offset = TimeInterval(translation.x / playerView.width * CGFloat(playerView.duration))
                let playTime = min(max(tempPlayTime + offset, 0), playerView.duration)
                playerView.currentPlaybackTime = playTime
                MediaPlayerProgressHUD.hide()
            }
            panGestureMode = .none
        }
    }

    // MARK: MediaPlayerCtrlAble

    func reset() {
    }

    func cleanup() {
    }

    var isCanHideCtrlView: Bool = true

    func setControlViewHidden(_ hidden: Bool) {
    }

    func layoutView(for bounds: CGRect) {
    }

    func playerDidChangeLoadState(_ loadState: MediaPlayerView.LoadState) {
    }

    func playerDidChangePlayBackState(_ backState: MediaPlayerView.PlaybackState) {
    }
}
