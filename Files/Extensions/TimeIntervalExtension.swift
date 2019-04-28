//
//  TimeInterval.swift
//  Files
//
//  Created by 翟泉 on 2019/4/28.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

extension TimeInterval {
    func formatterToTime() -> String {
        let time = lround(self)
        let hour = time / 3600
        let minute = (time - hour * 3600) / 60
        let second = time - hour * 3600 - minute * 60
        if hour > 0 {
            return String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            return String(format: "%02d:%02d", minute, second)
        }
    }
}
