//
//  MusicIndicatorView.swift
//  Files
//
//  Created by 翟泉 on 2019/3/22.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import ESTMusicIndicator

class MusicIndicatorView: UIView {
    private var musicIndicator: ESTMusicIndicatorView!

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 18, height: 18))

        musicIndicator = ESTMusicIndicatorView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        musicIndicator.hidesWhenStopped = true
        addSubview(musicIndicator)
        musicIndicator.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tapMusicIndicator))
        addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerStateChangedNotification), name: MusicPlayer.Notification.stateChanged, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didMoveToWindow() {
        handlePlayerStateChangedNotification()
    }

    @objc func tapMusicIndicator() {
        guard let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        navigationController.pushViewController(MusicPlayerViewController(), animated: true)
    }

    @objc func handlePlayerStateChangedNotification() {
        switch MusicPlayer.shared.state {
        case .playing:
            musicIndicator.state = .playing
        case .paused:
            musicIndicator.state = .paused
        case .stopped:
            musicIndicator.state = .stopped
        }
    }
}
