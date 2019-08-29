//
//  DocumentDirectoryPickerViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/5/13.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import DifferenceKit

class DocumentDirectoryPickerViewController: UIViewController {
    enum Result {
        case selected(directory: URL)
        case cancel
    }
    typealias ResultBlock = (Result) -> Void

    private var completeBlock: ResultBlock
    var document: Document!

    @discardableResult static func picker(with directory: URL = DocumentDirectory, showIn controller: UIViewController, completeBlock: @escaping ResultBlock) -> DocumentDirectoryPickerViewController {
        let picker = DocumentDirectoryPickerViewController(directory: directory, completeBlock: completeBlock)
        controller.present(UINavigationController(rootViewController: picker), animated: true, completion: nil)
        return picker
    }

    init(directory: URL, completeBlock: @escaping ResultBlock) {
        self.completeBlock = completeBlock
        super.init(nibName: nil, bundle: nil)
        document = Document(directory: directory)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = document.directory.lastPathComponent
        view.backgroundColor = .white
        setupUI()

        document.delegate = self
        document.filters.append { (file) -> Bool in
            return type(of: file.type) == type(of: DirectoryFileType())
        }
        document.loadContents()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.snp.updateConstraints { (maker) in
            maker.bottom.equalTo(-view.safeAreaInsets.bottom)
        }
        confirmButton.snp.updateConstraints { (maker) in
            maker.bottom.equalTo(-view.safeAreaInsets.bottom - 15)
        }
    }

    @objc func cancel() {
        completeBlock(.cancel)
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func confirm() {
        completeBlock(.selected(directory: document.directory))
        navigationController?.dismiss(animated: true, completion: nil)
    }

    private var flowLayout: FileListFlowLayout!
    private var collectionView: UICollectionView!
    private var confirmButton: UIButton!

    func setupUI() {
        let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItems = [cancelBarButtonItem]

        flowLayout = FileListFlowLayout()
        flowLayout.delegate = self

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(view)
        }

        confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = ColorRGB(54, 132, 203)
        confirmButton.layer.cornerRadius = 6
        confirmButton.addTarget(self, action: #selector(confirm), for: .touchUpInside)
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(30)
            maker.right.equalTo(-30)
            maker.bottom.equalTo(-30)
            maker.height.equalTo(44)
        }
    }
}

extension DocumentDirectoryPickerViewController: DocumentDelegate {
    func document(document: Document, contentsDidUpdate changeset: StagedChangeset<[File]>) {
        collectionView.reload(using: changeset)
    }
}

extension DocumentDirectoryPickerViewController: DocumentBrowserFlowLayoutDelegate {
    func flowLayout(_ flowLayout: DocumentBrowserFlowLayout, fileForItemAt indexPath: IndexPath) -> File {
        return document.contents[indexPath.row]
    }

    func flowLayout(_ flowLayout: DocumentBrowserFlowLayout, isSelectedAt indexPath: IndexPath) -> Bool {
        return false
    }
}


extension DocumentDirectoryPickerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.contents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return flowLayout.cellForItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = DocumentDirectoryPickerViewController(directory: document.contents[indexPath.row].url, completeBlock: completeBlock)
        navigationController?.pushViewController(controller, animated: true)
    }
}
