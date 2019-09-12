//
//  AVAudioExtensions.swift
//  Files
//
//  Created by 翟泉 on 2019/9/12.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioTime {
    var timeInterval: TimeInterval {
        return Double(sampleTime) / sampleRate
    }
}

extension AVAudioPlayerNode {
    var lastPlayTime: AVAudioTime? {
        guard let nodeTime = lastRenderTime else { return nil }
        return playerTime(forNodeTime: nodeTime)
    }
}

extension AVAudioFile {
    var duration: TimeInterval {
        return TimeInterval(length) / fileFormat.sampleRate
    }
}
