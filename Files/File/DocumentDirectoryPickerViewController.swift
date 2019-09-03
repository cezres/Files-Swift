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
    typealias SelectedBlock = (_ directory: URL) -> Void
    typealias CancelBlock = () -> Void

    private var selectedBlock: SelectedBlock?
    private var cancelBlock: CancelBlock?
    private var document: Document!

    init(directory: URL = DocumentDirectory, selected: SelectedBlock? = nil, cancel: CancelBlock? = nil) {
        self.selectedBlock = selected
        self.cancelBlock = cancel
        super.init(nibName: nil, bundle: nil)
        document = Document(directory: directory) { type(of: $0.type) == type(of: DirectoryFileType()) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = document.directory.lastPathComponent
        view.backgroundColor = .white
        setupUI()
        document.delegate = self
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

    func showIn(_ controller: UIViewController) {
        controller.present(UINavigationController(rootViewController: self), animated: true, completion: nil)
    }

    @objc func cancel() {
        cancelBlock?()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func confirm() {
        selectedBlock?(document.directory)
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
        let controller = DocumentDirectoryPickerViewController(directory: document.contents[indexPath.row].url, selected: selectedBlock, cancel: cancelBlock)
        navigationController?.pushViewController(controller, animated: true)
    }
}
