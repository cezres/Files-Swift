//
//  PhotoListViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/3/26.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

class PhotoListViewController: UIViewController {
    private var collectionView: UICollectionView!
    private var photos: [File]!
    private var prefetchManager: PhotoPrefetchManager!

    init(photos: [File], prefetchManager: PhotoPrefetchManager = PhotoPrefetchManager()) {
        super.init(nibName: nil, bundle: nil)
        self.photos = photos
        self.prefetchManager = prefetchManager
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupUI()
    }
    
    func setupUI() {
        let layout = PhotoListFlowLayout()
        layout.numberOfColumns = 3
        layout.interItemSpacing = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        layout._sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.columnSpacing = 2
        layout.headerHeight = 0
        layout.delegate = self

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(PhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Photo")
        collectionView.prefetchDataSource = self
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.top.equalTo(64)
            make.bottom.equalTo(0)
        }
    }

}

extension PhotoListViewController: PhotoListFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, layout: PhotoListFlowLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize {
        print(#function + "  \(originalItemSizeAtIndexPath.row)")
        if let image = UIImage(contentsOfFile: photos[originalItemSizeAtIndexPath.row].url.path) {
            return image.size
        }
        return .zero
    }
}

extension PhotoListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo", for: indexPath) as! PhotoCollectionViewCell
        cell.backgroundColor = ColorRGB(CGFloat(arc4random_uniform(255)), CGFloat(arc4random_uniform(255)), CGFloat(arc4random_uniform(255)))
        cell.imageView.image = nil
        prefetchManager.requestImage(url: photos[indexPath.row].url, targetSize: .thumbnail) { (image) in
            cell.imageView.image = image
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(#function + "  \(indexPath.row)")
        let layout = collectionView.collectionViewLayout as! PhotoListFlowLayout
        let itemSize = layout._itemSizeAtIndexPath(indexPath: indexPath)
        return itemSize
    }
}

extension PhotoListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach({ self.prefetchManager.prefetch(url: self.photos[$0.row].url, targetSize: .thumbnail, completion: nil)})
    }
}


private class PhotoCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
}
