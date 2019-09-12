//
//  Utils.swift
//  Files
//
//  Created by 翟泉 on 2019/9/7.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

func makeToastToWindow(code: () throws -> Void) {
    do {
        try code()
    } catch {
        UIApplication.shared.keyWindow?.makeToast(error.localizedDescription)
    }
}
