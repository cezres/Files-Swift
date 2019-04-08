//
//  FileListFlowLayout.swift
//  Files
//
//  Created by 翟泉 on 2019/4/3.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class FileListFlowLayout: UICollectionViewFlowLayout {
    weak var delegate: DocumentBrowserFlowLayoutDelegate?
    var numberOfColumns: Int = 4

    override init() {
        super.init()
        scrollDirection = .vertical
        sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        minimumInteritemSpacing = 10.0
        minimumLineSpacing = 10.0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()
        collectionView?.register(DocumentCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "File")

        let number = CGFloat(numberOfColumns)
        let width = (collectionView!.width-(number+1)*10) / number
        itemSize = DocumentCollectionViewCell.itemSize(for: width)
    }
}

extension FileListFlowLayout: DocumentBrowserFlowLayout {
    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        guard let collectionView = collectionView else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "File", for: indexPath) as! DocumentCollectionViewCell
        cell.file = delegate?.flowLayout(self, fileForItemAt: indexPath)
        return cell
    }

    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let collectionView = collectionView else { return .zero }
        let number = CGFloat(numberOfColumns)
        let width = (collectionView.width-(number+1)*10) / 4
        return DocumentCollectionViewCell.itemSize(for: width)
    }
}
