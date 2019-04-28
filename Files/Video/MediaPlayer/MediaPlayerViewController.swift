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

        // Do any additional setup after loading the view.
        view.addSubview(playerView)
        topContentView.addSubview(backButton)
        view.addSubview(topContentView)

        playerView.play(url)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.size != playerView.size {
            playerView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            topContentView.frame = CGRect(x: 0, y: 0, width: view.width, height: 44)
            backButton.frame = CGRect(x: 15, y: (topContentView.height - 30) / 2, width: 30, height: 30)
        }
    }

    @objc func back() {

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    lazy var topContentView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "icon_media_player_back")!, for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        return button
    }()

}
