//
//  DocumentBrowserToolBar.swift
//  Files
//
//  Created by 翟泉 on 2019/5/10.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

protocol DocumentBrowserToolBarDelegate: class {
    func toolBar(_ toolBar: DocumentBrowserToolBar, didClickItem item: DocumentBrowserToolBar.ItemType)
}

class DocumentBrowserToolBar: UIVisualEffectView {
    enum ItemType: String, CaseIterable {
        case delete = "Delete"
        case move = "Move"
        case copy = "Copy"
        case zip = "Zip"
    }

    weak var delegate: DocumentBrowserToolBarDelegate?

    init() {
        super.init(effect: UIBlurEffect(style: .light))
        setupItems()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func clickItem(button: UIButton) {
        guard let itemType = ItemType(rawValue: button.titleLabel?.text ?? "") else {
            return
        }
        delegate?.toolBar(self, didClickItem: itemType)
    }

    private var itemContentView: UIView!

    override func layoutSubviews() {
        super.layoutSubviews()
        itemContentView.snp.updateConstraints { (maker) in
            maker.bottom.equalTo(-safeAreaInsets.bottom)
        }
    }

    func setupItems() {
        itemContentView = UIView()
        contentView.addSubview(itemContentView)
        itemContentView.snp.makeConstraints { (maker) in
            maker.left.equalTo(15)
            maker.right.equalTo(-15)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
        }
        ItemType.allCases.forEach {
            let button = UIButton(type: .system)
            button.setTitle($0.rawValue, for: .normal)
            button.addTarget(self, action: #selector(clickItem(button:)), for: .touchUpInside)
            itemContentView.addSubview(button)
            button.snp.makeConstraints({ (maker) in
                if itemContentView.subviews.count >= 2 {
                    maker.left.equalTo(itemContentView.subviews[itemContentView.subviews.count - 2].snp.right).offset(10)
                } else {
                    maker.left.equalTo(0)
                }
                maker.top.equalTo(0)
                maker.bottom.equalTo(0)
                maker.width.equalTo(60)
            })
        }
    }
}
