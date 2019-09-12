//
//  MusicPlayerViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/3/21.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerStateChangedNotification), name: MusicPlayer.Notification.didChangeState, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerMusicChangedNotification), name: MusicPlayer.Notification.didChangeMusic, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivePCMBuffer(node:)), name: MusicPlayer.Notification.didReceivePCMBuffer, object: nil)

        handlePlayerMusicChangedNotification()
        handlePlayerStateChangedNotification()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
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
//        navigationController?.navigationBar.barStyle = .blackOpaque
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.barStyle = .black
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @objc func dismissViewController() {
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
        backgroundView.image = MusicPlayer.shared.music?.metadata.artwork
        artworkView.image = backgroundView.image
    }

    @objc func didReceivePCMBuffer(node: Notification) {
        guard let buffer = node.userInfo?["buffer"] as? AVAudioPCMBuffer else { return }
        DispatchQueue.main.async {
            let spectra = self.analyzer.analyse(with: buffer)
            self.spectrumView.spectra = spectra
        }
    }

    // MAKR: - Views

    func setupUI() {
        let contentView = UIView()
        contentView.addSubview(artworkView)
        contentView.addSubview(spectrumView)
        contentView.addSubview(infoView)

        view.addSubview(backgroundView)
        view.addSubview(contentView)
        view.addSubview(controlView)

        backgroundView.snp.makeConstraints({ (maker) in
            maker.edges.equalTo(view)
        })
        controlView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(100)
        }
        contentView.snp.makeConstraints { (maker) in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.centerY.equalTo(view.snp.centerY).offset(20 / 2 - 100 / 2)
            maker.bottom.equalTo(spectrumView.snp.bottom)
        }

        artworkView.snp.makeConstraints { (make) in
            make.width.equalTo(200)
            make.height.equalTo(200)
            make.centerX.equalTo(contentView.snp.centerX)
            make.top.equalTo(contentView.snp.top)
        }
        spectrumView.snp.makeConstraints { (maker) in
            maker.left.equalTo(20)
            maker.right.equalTo(-20)
            maker.top.equalTo(infoView.snp.bottom)
            maker.height.equalTo(100)
        }
        infoView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(artworkView.snp.bottom).offset(50)
            make.height.equalTo(150)
        }

        let spectrumViewWidth = view.width - 40
        let barSpace = spectrumViewWidth / CGFloat(analyzer.frequencyBands * 3 - 1)
        spectrumView.barWidth = barSpace * 2
        spectrumView.space = barSpace
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

    lazy var spectrumView: SpectrumView = SpectrumView()
    lazy var analyzer = SpectrumAnalysis(fftSize: MusicPlayer.shared.bufferSize)
}
