//
//  DocumentBrowserView.swift
//  Files
//
//  Created by 翟泉 on 2019/3/26.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class DocumentBrowserView: UIView, DocumentBrowserProtocol {
    private var controlView: DocumentBrowserControlView!
    private var controlMaskView: UIView!

    var document: Document! {
        didSet {
            document.registerDelegate(delegate: self)
        }
    }
    private var collectionView: UICollectionView!
    var rightBarButtonItems: [UIBarButtonItem]?

    init() {
        super.init(frame: .zero)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(DocumentCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "file")
        addSubview(collectionView)
        collectionView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self)
        }

        controlView = DocumentBrowserControlView()
        addSubview(controlView)
        controlView.snp.makeConstraints { (maker) in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.bottom.equalTo(collectionView.snp.top).offset(0)
            maker.height.equalTo(controlView.bounds.size.height)
        }

        controlMaskView = UIView()
        controlMaskView.backgroundColor = UIColor.white
        addSubview(controlMaskView)
        controlMaskView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(controlView)
        }

        rightBarButtonItems = [UIBarButtonItem(customView: MusicIndicatorView())]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        controlView.snp.updateConstraints { (maker) in
            maker.bottom.equalTo(collectionView.snp.top).offset(collectionView.safeAreaInsets.top)
        }
    }
}

extension DocumentBrowserView: DocumentDelegate {
    func document(document: Document, contentsDidUpdate update: TableUpdate) {
        collectionView.tableUpdate(update: update)
    }
}

extension DocumentBrowserView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return document.contents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "file", for: indexPath) as! DocumentCollectionViewCell
        cell.file = document.contents[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let number: CGFloat = 4
        let width = (collectionView.width-(number+1)*10) / 4
        return DocumentCollectionViewCell.itemSize(for: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let viewController = viewController as? DocumentBrowserViewController {
            document.contents[indexPath.row].open(document: document, controller: viewController)
        }
    }
}

extension DocumentBrowserView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top - collectionView.contentInset.top
        controlView.transform = CGAffineTransform(translationX: 0, y: -offset)
        controlMaskView.transform = CGAffineTransform(translationX: 0, y: min(-offset, 0))
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y + scrollView.adjustedContentInset.top < -(controlView.height) {
            collectionView.contentInset = UIEdgeInsets(top: controlView.bounds.size.height, left: 0, bottom: 0, right: 0)
        } else {
            collectionView.contentInset = UIEdgeInsets.zero
        }
    }
}
