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

    init(directory: URL = DocumentDirectory) {
        super.init(nibName: nil, bundle: nil)
        title = directory.lastPathComponent
        document = Document(directory: directory)
        document.registerDelegate(delegate: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        document.loadContents()
    }

    // MARK: - View

    var collectionView: UICollectionView!

    func setupUI() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0

        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(DocumentCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "file")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (maker) in
            maker.left.equalTo(0)
            maker.right.equalTo(0)
            maker.top.equalTo(0)
            maker.bottom.equalTo(0)
        }
    }

}

extension DocumentBrowserViewController: DocumentDelegate {
    func document(document: Document, contentsDidUpdate update: ListUpdate) {
        collectionView.reloadData()
    }
}

extension DocumentBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return document.contents.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "file", for: indexPath) as! DocumentCollectionViewCell
        cell.file = document.contents[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let number: CGFloat = 4
        let width = (collectionView.bounds.size.width-(number+1)*10) / 4
        return DocumentCollectionViewCell.itemSize(for: width)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let file = document.contents[indexPath.row]
        file.open(document: document, controller: self)
    }
}
