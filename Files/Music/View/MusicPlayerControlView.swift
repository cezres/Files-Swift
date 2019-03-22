//
//  MusicPlayerToolView.swift
//  Files
//
//  Created by 翟泉 on 2019/3/21.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class MusicPlayerControlView: UIView {
    var playButton: UIButton!
    var nextButton: UIButton!
    var prevButton: UIButton!
    var playModeButton: UIButton!
    var moreButton: UIButton!

    init() {
        super.init(frame: CGRect())
        backgroundColor = UIColor(white: 0.4, alpha: 0.4)
        initSubviews()
        handlePlayStateChangedNotification()
        NotificationCenter.default.addObserver(self, selector: #selector(MusicPlayerControlView.handlePlayStateChangedNotification), name: MusicPlayer.Notification.stateChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func clickPlay() {
        if MusicPlayer.shared.state == .playing {
            MusicPlayer.shared.pause()
        }
        else {
            MusicPlayer.shared.play()
        }
    }

    @objc func clickNext() {
    }

    @objc func clickPrev() {
    }

    @objc func handlePlayStateChangedNotification() {
        if MusicPlayer.shared.state == .playing {
            playButton.setImage(#imageLiteral(resourceName: "icon-pause"), for: .normal)
        }
        else if MusicPlayer.shared.state == .paused {
            playButton.setImage(#imageLiteral(resourceName: "icon-play"), for: .normal)
        }
        else if MusicPlayer.shared.state == .stopped {
            playButton.setImage(#imageLiteral(resourceName: "icon-play"), for: .normal)
        }
    }

    func initSubviews() {
        playButton = UIButton(type: .system)
        playButton.addTarget(self, action: #selector(MusicPlayerControlView.clickPlay), for: .touchUpInside)
        playButton.tintColor = UIColor.white
        playButton.setImage(#imageLiteral(resourceName: "icon-play"), for: .normal)
        addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }

        nextButton = UIButton(type: .system)
        nextButton.addTarget(self, action: #selector(MusicPlayerControlView.clickNext), for: .touchUpInside)
        nextButton.tintColor = UIColor.white
        nextButton.setImage(UIImage(named: "icon-next"), for: .normal)
        addSubview(nextButton)
        nextButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(playButton.snp.right).offset(15)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }

        prevButton = UIButton(type: .system)
        prevButton.addTarget(self, action: #selector(MusicPlayerControlView.clickPrev), for: .touchUpInside)
        prevButton.tintColor = UIColor.white
        prevButton.setImage(UIImage(named: "icon-prev"), for: .normal)
        addSubview(prevButton)
        prevButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(playButton.snp.left).offset(-15)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }

        playModeButton = UIButton(type: .system)
        playModeButton.tintColor = UIColor.white
        playModeButton.setImage(UIImage(named: "icon_loopAll"), for: .normal)
        addSubview(playModeButton)
        playModeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }

        moreButton = UIButton(type: .system)
        moreButton.tintColor = UIColor.white
        moreButton.setImage(UIImage(named: "icon_more"), for: .normal)
        addSubview(moreButton)
        moreButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(-20)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }
}
