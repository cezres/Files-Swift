//
//  DocumentBrowserViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import SnapKit
import DifferenceKit
import Toast_Swift

class DocumentBrowserViewController: UIViewController {
    private(set) var document: Document!
    private var selectItems = [IndexPath]()

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
        view.backgroundColor = .white
        setupView()
        document.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        controlView.snp.updateConstraints { (maker) in
            maker.bottom.equalTo(collectionView.snp.top).offset(collectionView.safeAreaInsets.top)
        }
    }

    // MARK: event
    private var toolBar: DocumentBrowserToolBar!

    // MARK: setup views

    private var collectionView: UICollectionView!
    private var controlView: DocumentBrowserControlView!
    private var controlMaskView: UIView!
    private var flowLayout: UICollectionViewFlowLayout & DocumentBrowserFlowLayout = FileListFlowLayout() {
        didSet {
            flowLayout.delegate = self
            collectionView?.reloadData()
            collectionView?.setCollectionViewLayout(flowLayout, animated: true)
        }
    }

    private func setupView() {
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

        controlView = DocumentBrowserControlView()
        view.addSubview(controlView)
        controlView.snp.makeConstraints { (maker) in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.bottom.equalTo(collectionView.snp.top).offset(0)
            maker.height.equalTo(controlView.bounds.size.height)
        }

        controlMaskView = UIView()
        controlMaskView.backgroundColor = UIColor.white
        view.addSubview(controlMaskView)
        controlMaskView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(controlView)
        }

        updateNavigationBar()
    }

    /// navigation bar
    func updateNavigationBar() {
        let musicIndicatorNavigationBar = UIBarButtonItem(customView: MusicIndicatorView())
        if flowLayout.isEditing {
            let doneNavigationBar = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(triggerEdit))
            navigationItem.rightBarButtonItems = [doneNavigationBar, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), musicIndicatorNavigationBar]
        } else {
            let editNavigationBar = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(triggerEdit))
            navigationItem.rightBarButtonItems = [editNavigationBar, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), musicIndicatorNavigationBar]
        }
    }
}

/// Edit
extension DocumentBrowserViewController {
    @objc func triggerEdit() {
        flowLayout.isEditing.toggle()
        if flowLayout.isEditing {
            toolBar = DocumentBrowserToolBar()
            toolBar.delegate = self
            view.addSubview(toolBar)
            toolBar.snp.makeConstraints { (maker) in
                maker.left.equalTo(0)
                maker.right.equalTo(0)
                maker.bottom.equalTo(0)
                maker.height.equalTo(view.safeAreaInsets.bottom + 44)
            }
        } else {
            selectItems.removeAll()
            toolBar.removeFromSuperview()
        }
        updateNavigationBar()
    }
}

/// Control
extension DocumentBrowserViewController: DocumentBrowserControlViewEvent, DocumentBrowserToolBarDelegate {
    func newDirectory() {
    }

    func photoList() {
        flowLayout = PhotoListFlowLayout()
    }

    func fileList() {
        flowLayout = FileListFlowLayout()
    }

    func toolBar(_ toolBar: DocumentBrowserToolBar, didClickItem item: DocumentBrowserToolBar.ItemType) {
        guard selectItems.count > 0 else { return }

        switch item {
        case .delete:
            self.view.makeToastActivity(.center)
            DispatchQueue.global().async {
                do {
                    try self.document.removeItems(self.selectItems.map { $0.row })
                } catch {
                }
                DispatchQueue.main.async {
                    self.triggerEdit()
                    self.view.hideToastActivity()
                }
            }
            break
        default:
            break
        }
    }
}

extension DocumentBrowserViewController: DocumentDelegate {
    func document(document: Document, contentsDidUpdate changeset: StagedChangeset<[File]>) {
        collectionView.reload(using: changeset)
    }
}

extension DocumentBrowserViewController: DocumentBrowserFlowLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.contents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return flowLayout.cellForItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if flowLayout.isEditing {
            if let index = selectItems.lastIndex(where: { $0 == indexPath }) {
                selectItems.remove(at: index)
            } else {
                selectItems.append(indexPath)
            }
            collectionView.reloadItems(at: [indexPath])
        } else {
            document.contents[indexPath.row].open(document: document, controller: self)
        }
    }

    func flowLayout(_ flowLayout: DocumentBrowserFlowLayout, fileForItemAt indexPath: IndexPath) -> File {
        return document.contents[indexPath.row]
    }

    func flowLayout(_ flowLayout: DocumentBrowserFlowLayout, isSelectedAt indexPath: IndexPath) -> Bool {
        return selectItems.lastIndex(where: { $0 == indexPath }) != nil
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top - collectionView.contentInset.top
        controlView.transform = CGAffineTransform(translationX: 0, y: -offset)
        controlMaskView.transform = CGAffineTransform(translationX: 0, y: min(-offset, 0))
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y + scrollView.adjustedContentInset.top < -(controlView.height) {
            collectionView.contentInset = UIEdgeInsets(top: controlView.bounds.size.height, left: 0, bottom: 0, right: 0)
        } else {
            collectionView.contentInset = .zero
        }
    }
}
