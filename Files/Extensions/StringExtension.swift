//
//  StringExtension.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation


extension String {
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
}
