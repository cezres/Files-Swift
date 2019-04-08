//
//  DocumentBrowserFlowLayout.swift
//  Files
//
//  Created by 翟泉 on 2019/4/8.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

protocol DocumentBrowserFlowLayout {
    var delegate: DocumentBrowserFlowLayoutDelegate? { get set }
    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell
}

protocol DocumentBrowserFlowLayoutDelegate: class {
    func flowLayout(_ flowLayout: DocumentBrowserFlowLayout, fileForItemAt indexPath: IndexPath) -> File
}
