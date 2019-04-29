//
//  VideoPlayerViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/4/26.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class MediaPlayerViewController: UIViewController {
    var playerView: MediaPlayerView!
    let url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        playerView = MediaPlayerView()
        view.addSubview(playerView)

        topView.contentView.addSubview(backButton)
        topView.contentView.addSubview(titleLabel)
        view.addSubview(topView)

        backButton.snp.makeConstraints { (maker) in
            maker.width.equalTo(30)
            maker.height.equalTo(30)
            maker.left.equalTo(15)
            maker.centerY.equalTo(topView.contentView)
        }
        titleLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(backButton.snp.right).offset(15)
            maker.right.equalTo(-15)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
        }

        playerView.registerControl(MediaPlayerControlView())
        playerView.registerControl(self)
        playerView.registerControl(MediaPlayerGestureRecognizer())

        playerView.play(url)
        titleLabel.text = url.lastPathComponent
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.size != playerView.size {
            playerView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            topView.frame = CGRect(x: 0, y: 0, width: view.width, height: 44)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerView.shutdown()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    @objc func back() {
        dismiss(animated: true, completion: nil)
    }

    lazy var topView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "icon_media_player_back")!, for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        return label
    }()
}

extension MediaPlayerViewController: MediaPlayerCtrlAble {
    func reset() {
    }

    func cleanup() {
    }

    var isCanHideCtrlView: Bool {
        return true
    }

    func setControlViewHidden(_ hidden: Bool) {
        topView.layer.removeAllAnimations()
        if hidden {
            UIView.animate(withDuration: 0.3) {
                self.topView.transform = .init(translationX: 0, y: -self.topView.height)
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.topView.transform = .identity
            }
        }
    }

    func layoutView(for bounds: CGRect) {
    }

    func playerDidChangeLoadState(_ loadState: MediaPlayerView.LoadState) {
    }

    func playerDidChangePlayBackState(_ backState: MediaPlayerView.PlaybackState) {
    }
}
