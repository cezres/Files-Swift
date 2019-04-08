//
//  DocumentBrowserControlView.swift
//  Files
//
//  Created by 翟泉 on 2019/3/22.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

protocol DocumentBrowserControlViewEvent {
    func newDirectory()
    func fileList()
    func photoList()
}

class DocumentBrowserControlView: UIView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 375, height: 44))

        let newButton = UIButton(type: .system)
        newButton.setTitle("New", for: .normal)
        addSubview(newButton)
        newButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(12)
            maker.bottom.equalTo(-10)
            maker.width.equalTo(50)
            maker.height.equalTo(24)
        }
        newButton.addTarget(self, action: #selector(newDirectory), for: .touchUpInside)

        let photoButton = UIButton(type: .system)
        photoButton.setTitle("Photo", for: .normal)
        photoButton.addTarget(self, action: #selector(photoList(button:)), for: .touchUpInside)
        addSubview(photoButton)
        photoButton.snp.makeConstraints { (maker) in
            maker.right.equalTo(-12)
            maker.width.equalTo(50)
            maker.height.equalTo(24)
            maker.bottom.equalTo(-10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func newDirectory() {
        guard let event: DocumentBrowserControlViewEvent = eventStrategy() else { return }
        event.newDirectory()
    }

    @objc func photoList(button: UIButton) {
        guard let eventStrategy: DocumentBrowserControlViewEvent = eventStrategy() else { return }
        if button.tag == 0 {
            eventStrategy.photoList()
            button.setTitle("File", for: .normal)
            button.tag = 1
        } else {
            eventStrategy.fileList()
            button.setTitle("Photo", for: .normal)
            button.tag = 0
        }
    }
}
