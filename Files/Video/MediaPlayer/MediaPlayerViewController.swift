//
//  VideoPlayerViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/4/26.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class MediaPlayerViewController: UIViewController {
    lazy var playerView = MediaPlayerView()
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
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
        view.addSubview(playerView)
        topView.contentView.addSubview(backButton)
        view.addSubview(topView)

        playerView.registerControl(MediaPlayerControlView())
        playerView.play(url)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.size != playerView.size {
            playerView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            topView.frame = CGRect(x: 0, y: 0, width: view.width, height: 44)
            backButton.frame = CGRect(x: 15, y: (topView.height - 30) / 2, width: 30, height: 30)
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
}
