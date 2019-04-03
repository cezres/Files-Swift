//
//  DocumentBrowserProtocol.swift
//  Files
//
//  Created by 翟泉 on 2019/4/3.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

protocol DocumentBrowserProtocol {
    var document: Document! { get set }
    var rightBarButtonItems: [UIBarButtonItem]? { get }
}
