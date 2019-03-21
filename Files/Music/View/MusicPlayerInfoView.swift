//
//  MusicPlayerInfoView.swift
//  Files
//
//  Created by 翟泉 on 2019/3/21.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class MusicPlayerInfoView: UIView, UIGestureRecognizerDelegate {
    var displayLink: CADisplayLink?
    var timer: Timer?

    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 0

    var phase: CGFloat = 0
    var diameter: CGFloat = 26
    var diameterOffset: CGFloat = 0.2

    var elapsedTimeLabel = UILabel()
    var remainedTimeLabel = UILabel()

    var songLabel = UILabel()
    var singerLabel = UILabel()

    init() {
        super.init(frame: CGRect())
        backgroundColor = UIColor.clear

        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(MusicPlayerInfoView.handlePan(panGesture:)))
        addGestureRecognizer(panGesture)

        initSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        setup()
        handleTimer()

        if displayLink == nil {
            displayLink = CADisplayLink(target: self, selector: #selector(MusicPlayerInfoView.handleDisplayLink))
            displayLink?.preferredFramesPerSecond = 30
            displayLink?.add(to: .current, forMode: .default)
        }
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MusicPlayerInfoView.handleTimer), userInfo: nil, repeats: true)
        }
        
        handleDisplayLink()
    }

    func pause() {
        displayLink?.invalidate()
        displayLink = nil
        timer?.invalidate()
        timer = nil
        setNeedsDisplay()
        setup()
        handleTimer()
    }

    func stop() {
        if displayLink != nil {
            displayLink!.invalidate()
            displayLink = nil
        }
        if timer != nil {
            timer?.invalidate()
            timer = nil
            elapsedTimeLabel.text = "--:--"
            remainedTimeLabel.text = "--:--"
        }
        currentTime = 0
        duration = 0
        diameter = 26
        setNeedsDisplay()
    }

    func setup() {
        songLabel.text = MusicPlayer.shared.music?.song
        singerLabel.text = MusicPlayer.shared.music?.singer
        currentTime = MusicPlayer.shared.currentTime
        duration = MusicPlayer.shared.duration
    }

    // MARK: - Handle

    @objc func handlePan(panGesture: UIPanGestureRecognizer) {
        let location = panGesture.location(in: self)
        let time = duration * TimeInterval((location.x-10) / (bounds.width-20))

        currentTime = time < 0 ? 0 : time > duration ? duration : time

        switch panGesture.state {
        case .began:
            displayLink?.isPaused = true
        case .ended, .cancelled:
            MusicPlayer.shared.currentTime = currentTime
            displayLink?.isPaused = false
            break
        default:
            break
        }
        handleTimer()
        setNeedsDisplay()
    }

    @objc func handleDisplayLink() {
        phase -= 0.4
        if phase == 0 {
            phase = CGFloat(Double.pi * 12)
        }

        if diameter <= 24 {
            diameterOffset = 0.2
        }
        else if diameter >= 30 {
            diameterOffset = -0.2
        }
        diameter += diameterOffset
        currentTime = MusicPlayer.shared.currentTime
        setNeedsDisplay()
    }

    @objc func handleTimer() {
        elapsedTimeLabel.text = timeToString(time: currentTime)
        remainedTimeLabel.text = timeToString(time: duration - currentTime)
    }

    // MARK: - UIGestureRecognizerDelegate

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard displayLink != nil else {
            return false
        }
        let location = gestureRecognizer.location(in: self)
        guard location.y >= bounds.height/2-30 && location.y <= bounds.height/2+30 else {
            return false
        }
        let centerX: CGFloat = 15 + (bounds.width - 30) * CGFloat(currentTime / duration)

        return !(location.x > centerX + 30 || location.x < centerX - 30)
    }

    // MARK: - Draw

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        draw(size: rect.size, context: context)
    }


    func draw(size: CGSize, context: CGContext) {
        context.setStrokeColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        context.setLineWidth(1)

        let strokeSegments = [CGPoint(x: 15, y: size.height/2),
                              CGPoint(x: size.width-15, y: size.height/2)]
        context.strokeLineSegments(between: strokeSegments)
        context.strokePath()

        let centerX: CGFloat = 15 + (size.width - 30) * CGFloat(currentTime / duration)

        context.addEllipse(in: CGRect(x: centerX-diameter/2, y: (size.height-diameter)/2, width: diameter, height: diameter))
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        context.fillPath()

        context.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.setLineWidth(1)
        context.addEllipse(in: CGRect(x: centerX-diameter/2, y: (size.height-diameter)/2, width: diameter, height: diameter))
        context.strokePath()

        context.setLineDash(phase: phase, lengths: [14,5])
        context.addEllipse(in: CGRect(x: centerX-6, y: (size.height-12)/2, width: 12, height: 12))
        context.setLineWidth(2)
        context.setStrokeColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.strokePath()

        context.addEllipse(in: CGRect(x: centerX-4, y: (size.height-8)/2, width: 8, height: 8))
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        context.fillPath()
    }

    func initSubviews() {
        elapsedTimeLabel.font = UIFont.systemFont(ofSize: 20)
        elapsedTimeLabel.textColor = UIColor.white
        elapsedTimeLabel.textAlignment = NSTextAlignment.right
        elapsedTimeLabel.text = "00:00"
        addSubview(elapsedTimeLabel)

        remainedTimeLabel.font = UIFont.systemFont(ofSize: 20)
        remainedTimeLabel.textColor = UIColor.white
        remainedTimeLabel.textAlignment = NSTextAlignment.left
        remainedTimeLabel.text = "00:00"
        addSubview(remainedTimeLabel)

        let elapsedLabel = UILabel()
        elapsedLabel.text = "ELAPSED"
        elapsedLabel.textColor = UIColor.white
        elapsedLabel.textAlignment = NSTextAlignment.right
        elapsedLabel.font = UIFont.systemFont(ofSize: 12)
        addSubview(elapsedLabel)

        let remainedLabel = UILabel()
        remainedLabel.text = "REMAINED"
        remainedLabel.textColor = UIColor.white
        remainedLabel.textAlignment = NSTextAlignment.left
        remainedLabel.font = UIFont.systemFont(ofSize: 12)
        addSubview(remainedLabel)

        elapsedTimeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.centerX).offset(-8)
            make.width.equalTo(60)
            make.centerY.equalTo(self).offset(30)
            make.height.equalTo(20)
        }
        remainedTimeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX).offset(8)
            make.width.equalTo(60)
            make.centerY.equalTo(self).offset(30)
            make.height.equalTo(20)
        }
        elapsedLabel.snp.makeConstraints { (make) in
            make.right.equalTo(elapsedTimeLabel.snp.left).offset(-2)
            make.centerY.equalTo(elapsedTimeLabel)
            make.width.equalTo(70)
            make.height.equalTo(16)
        }
        remainedLabel.snp.makeConstraints { (make) in
            make.left.equalTo(remainedTimeLabel.snp.right).offset(2)
            make.centerY.equalTo(remainedTimeLabel)
            make.width.equalTo(70)
            make.height.equalTo(16)
        }

        songLabel.font = UIFont.systemFont(ofSize: 26)
        songLabel.textAlignment = NSTextAlignment.center
        songLabel.textColor = UIColor.white
        addSubview(songLabel)

        singerLabel.font = UIFont.systemFont(ofSize: 14)
        singerLabel.textAlignment = NSTextAlignment.center
        singerLabel.textColor = UIColor.white
        addSubview(singerLabel)

        songLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(singerLabel.snp.top).offset(-10)
            make.height.equalTo(30)
        }

        singerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(self.snp.centerY).offset(-30)
            make.height.equalTo(16)
        }
    }
}


func timeToString(time: TimeInterval) -> String {
    guard time >= 0 else {
        return "--:--"
    }
    let iTime = Int(time)
    let minute = iTime / 60
    return String(format: "%02d:%02d", minute, iTime - minute*60)
}

