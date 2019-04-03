//
//  DocumentBrowserViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import SnapKit

class DocumentBrowserViewController: UIViewController {
    var document: Document!
    typealias BrowserView = DocumentBrowserProtocol & UIView
    var contentView: BrowserView!

    init(directory: URL = DocumentDirectory) {
        super.init(nibName: nil, bundle: nil)
        title = directory.lastPathComponent
        document = Document(directory: directory)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupContentView(contentView: DocumentBrowserView())
        document.loadContents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func setupContentView(contentView: BrowserView) {
        self.contentView = contentView
        self.contentView.document = document
        navigationItem.setRightBarButtonItems(self.contentView.rightBarButtonItems, animated: true)
        view.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(view)
        }
    }
}
