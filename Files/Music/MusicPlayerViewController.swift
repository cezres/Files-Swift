//
//  MusicPlayerViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/3/21.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerStateChangedNotification), name: MusicPlayer.Notification.stateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerMusicChangedNotification), name: MusicPlayer.Notification.musicChanged, object: nil)

        handlePlayerMusicChangedNotification()
        handlePlayerStateChangedNotification()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(popController))
        view.addGestureRecognizer(tapGestureRecognizer)

        guard let internalTargets = self.navigationController?.interactivePopGestureRecognizer?.value(forKey: "targets") as? NSArray else { return }
        guard let internalTarget = internalTargets.lastObject as? NSObject else { return }
        guard let target = internalTarget.value(forKey: "target") else { return }
        let action = NSSelectorFromString("handleNavigationTransition:")
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.addTarget(target, action: action)
        view.addGestureRecognizer(panGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barStyle = .black
    }

    @objc func popController() {
        _ = navigationController?.popViewController(animated: true)
    }

    // MARK: - Notification
    @objc func handlePlayerStateChangedNotification() {
        let state = MusicPlayer.shared.state
        if state == .playing {
            infoView.start()
        }
        else if state == .paused {
            infoView.pause()
        }
        else if state == .stopped {
            infoView.stop()
        }
    }
    @objc func handlePlayerMusicChangedNotification() {
        backgroundView.image = MusicPlayer.shared.music?.artwork
        artworkView.image = backgroundView.image
    }

    // MAKR: - Views

    func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(artworkView)
        view.addSubview(infoView)
        view.addSubview(controlView)

        backgroundView.snp.makeConstraints({ (maker) in
            maker.edges.equalTo(view)
        })
        artworkView.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(150)
        }
        controlView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(100)
        }
        infoView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(self.artworkView.snp.bottom).offset(60)
            make.height.equalTo(150)
        }
    }

    lazy var backgroundView: UIImageView = {
        let backgroundView = UIImageView()
        backgroundView.clipsToBounds = true
        backgroundView.contentMode = .scaleAspectFit
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        backgroundView.addSubview(blurEffectView)
        blurEffectView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(backgroundView)
        }
        return backgroundView
    }()

    lazy var artworkView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var controlView: MusicPlayerControlView = {
        return MusicPlayerControlView()
    }()

    lazy var infoView: MusicPlayerInfoView = {
        return MusicPlayerInfoView()
    }()
}
