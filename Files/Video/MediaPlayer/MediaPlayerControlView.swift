//
//  MediaPlayerControlView.swift
//  Files
//
//  Created by 翟泉 on 2019/4/26.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class MediaPlayerControlView: UIView, MediaPlayerCtrlAble {

    weak var playerView: MediaPlayerView? = nil
    var isCanHideCtrlView: Bool = true

    init() {
        super.init(frame: .zero)
        setupUI()

        progressView.addTarget(self, action: #selector(sliderDidTouchDown), for: .touchDown)
        progressView.addTarget(self, action: #selector(sliderDidTouchCancel), for: .touchCancel)
        progressView.addTarget(self, action: #selector(sliderDidTouchUpOutside), for: .touchUpOutside)
        progressView.addTarget(self, action: #selector(sliderDidTouchUpInside), for: .touchUpInside)
        progressView.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
        playButton.addTarget(self, action: #selector(triggerPlay), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Event

    @objc func triggerPlay() {
        if playerView?.playbackState == MediaPlayerView.PlaybackState.playing {
            playerView?.pause()
        } else if playerView?.playbackState == MediaPlayerView.PlaybackState.paused {
            playerView?.play()
        } else if playerView?.playbackState == MediaPlayerView.PlaybackState.stopped {
            playerView?.currentPlaybackTime = 0
            playerView?.play()
        }
    }

    @objc func refresh() {
        progressView.value = Float(playerView?.currentPlaybackTime ?? 0)
        currentTimeLabel.text = playerView?.currentPlaybackTime.formatterToTime() ?? "--:--"

        if !isHidden && playerView?.playbackState == MediaPlayerView.PlaybackState.playing {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refresh), object: nil)
            perform(#selector(refresh), with: nil, afterDelay: 0.5)
        }
    }

    @objc func sliderDidTouchDown() {
        isCanHideCtrlView = false
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refresh), object: nil)
    }

    @objc func sliderDidTouchCancel() {
        isCanHideCtrlView = true
        MediaPlayerProgressHUD.hide()
        refresh()
    }

    @objc func sliderDidTouchUpOutside() {
        isCanHideCtrlView = true
        MediaPlayerProgressHUD.hide()
        refresh()
    }

    @objc func sliderDidTouchUpInside() {
        isCanHideCtrlView = true
        playerView?.currentPlaybackTime = TimeInterval(progressView.value)
        MediaPlayerProgressHUD.hide()
        refresh()
    }

    @objc func sliderDidChangeValue() {
        MediaPlayerProgressHUD.show(with: TimeInterval(progressView!.value), duration: playerView?.duration ?? 0)
    }



    // MARK: CtrlAble

    func reset() {
        progressView.value = 0
        currentTimeLabel.text = "--:--"
        durationLabel.text = "--:--"
    }

    func cleanup() {
        removeFromSuperview()
    }

    func setControlViewHidden(_ hidden: Bool) {
        self.layer.removeAllAnimations()

        if hidden {
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(translationX: 0, y: 50)
            }) { (finished) in
                guard finished else { return }
                UIView.animate(withDuration: 0.2, animations: {
                    self.alpha = 0
                }, completion: { (finished) in
                    self.alpha = 1
                    if finished {
                        self.isHidden = true
                    }
                })
            }
        } else {
            isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = .identity
            }) { (finished) in
                if finished {
                    self.isHidden = false
                }
            }
        }
    }

    func layoutView(for bounds: CGRect) {
        playerView?.addSubview(self)
        snp.makeConstraints { (maker) in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.bottom.equalTo(0)
            maker.height.equalTo(100)
        }
    }

    func playerDidChangeLoadState(_ loadState: MediaPlayerView.LoadState) {

    }

    func playerDidChangePlayBackState(_ backState: MediaPlayerView.PlaybackState) {
        print("\(#function)  \(backState)")
        switch backState {
        case .playing:
            progressView.maximumValue = Float(playerView!.duration)
            durationLabel.text = playerView!.duration.formatterToTime()
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refresh), object: nil)
            perform(#selector(refresh), with: nil, afterDelay: 0.5)
            playButton.setImage(UIImage(named: "icon_media_player_pause"), for: .normal)
            progressView.isEnabled = true
        case .paused:
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refresh), object: nil)
            playButton.setImage(UIImage(named: "icon_media_player_play"), for: .normal)
            progressView.isEnabled = true
        case .stopped:
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refresh), object: nil)
            reset()
            playButton.setImage(UIImage(named: "icon_media_player_play"), for: .normal)
            progressView.isEnabled = false
        default:
            break
        }
    }



    var progressView: MediaPlayerProgressView!
    var currentTimeLabel: UILabel!
    var durationLabel: UILabel!
    var playButton: UIButton!

    func setupUI() {
        let contentView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        addSubview(contentView)

        progressView = MediaPlayerProgressView()
        progressView.isEnabled = false
        contentView.contentView.addSubview(progressView)

        currentTimeLabel = UILabel()
        currentTimeLabel.textColor = .white
        currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        currentTimeLabel.textAlignment = .right
        currentTimeLabel.text = "--:--"
        contentView.contentView.addSubview(currentTimeLabel)

        durationLabel = UILabel()
        durationLabel.textColor = .white
        durationLabel.font = UIFont.systemFont(ofSize: 12)
        durationLabel.textAlignment = .left
        durationLabel.text = "--:--"
        contentView.contentView.addSubview(durationLabel)

        playButton = UIButton(type: .custom)
        addSubview(playButton)

        contentView.snp.makeConstraints { (maker) in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.height.equalTo(50)
            maker.bottom.equalTo(0)
        }
        currentTimeLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(15)
            maker.width.equalTo(55)
            maker.height.equalTo(14)
            maker.centerY.equalTo(contentView.contentView)
        }
        durationLabel.snp.makeConstraints { (maker) in
            maker.right.equalTo(-15)
            maker.width.equalTo(55)
            maker.height.equalTo(14)
            maker.centerY.equalTo(contentView.contentView)
        }
        progressView.snp.makeConstraints { (maker) in
            maker.left.equalTo(currentTimeLabel.snp.right).offset(15)
            maker.right.equalTo(durationLabel.snp.left).offset(-15)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
        }

        playButton.snp.makeConstraints { (maker) in
            maker.width.equalTo(55)
            maker.height.equalTo(50)
            maker.right.equalTo(-10)
            maker.bottom.equalTo(contentView.snp.top)
        }
    }
}
