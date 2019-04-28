//
//  MediaPlayerProgressHUD.swift
//  Files
//
//  Created by 翟泉 on 2019/4/28.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class MediaPlayerProgressHUD: UIVisualEffectView {
    private static let viewTag = 98127387129

    static func show(with currentTime: TimeInterval, duration: TimeInterval) {
        guard let window = UIApplication.shared.keyWindow else { return }

        var progressHUD = window.viewWithTag(viewTag) as? MediaPlayerProgressHUD
        if progressHUD == nil {
            progressHUD = MediaPlayerProgressHUD()
            progressHUD?.tag = viewTag
            window.addSubview(progressHUD!)
            progressHUD?.snp.makeConstraints({ (maker) in
                maker.width.equalTo(100)
                maker.height.equalTo(50)
                maker.center.equalTo(0)
            })
        }
        progressHUD?.progressView.progress = Float(currentTime / duration)
        progressHUD?.timeLabel.text = "\(currentTime.formatterToTime()) / \(duration.formatterToTime())"

//        let currentTime = Int(currentTime), duration = Int(duration)
//        progressHUD?.timeLabel.text = String(format: "%02d:%02d / %02d:%02d", currentTime / 60, currentTime % 60, duration / 60, duration % 60)
    }

    static func hide() {
        guard let progressHUD = UIApplication.shared.keyWindow?.viewWithTag(viewTag) as? MediaPlayerProgressHUD else { return }
        UIView.animate(withDuration: 0.3, animations: {
            progressHUD.alpha = 0
        }) { (_) in
            progressHUD.removeFromSuperview()
        }
    }

    init() {
        super.init(effect: UIBlurEffect(style: .dark))
        layer.cornerRadius = 6
        layer.masksToBounds = true

        contentView.addSubview(timeLabel)
        contentView.addSubview(progressView)

        timeLabel.snp.makeConstraints { (maker) in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.height.equalTo(16)
            maker.centerY.equalTo(0)
        }
        progressView.snp.makeConstraints { (maker) in
            maker.left.equalTo(10)
            maker.right.equalTo(-10)
            maker.top.equalTo(timeLabel.snp.bottom).offset(5)
            maker.height.equalTo(2)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()

    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressTintColor = ColorRGB(219, 92, 92)
        progressView.trackTintColor = ColorWhite(86)
        return progressView
    }()

}
