//
//  PhotoBrowserViewController.swift
//  Files
//
//  Created by 翟泉 on 2019/3/19.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import SnapKit

class PhotoBrowserViewController: UIViewController {
    var files: [File]
    private(set) var index: Int = 0 {
        didSet {
             title = "\(index+1)/\(files.count)"
        }
    }
    private var prefetchManager = PhotoPrefetchManager()

    init(files: [File]) {
        self.files = files
        super.init(nibName: nil, bundle: nil)
        title = "\(index+1)/\(files.count)"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
    }

    // MARK: - Views

    var collectionView: UICollectionView!

    func setupUI() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = .zero
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.itemSize = .zero
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.register(PhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Photo")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.isPagingEnabled = true
        collectionView.isPrefetchingEnabled = true
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
    }
}


extension PhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photo", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = nil
        prefetchManager.loadPhoto(url: files[indexPath.row].url) { (result) in
            cell.imageView.image = result
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension PhotoBrowserViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("\(#function): \(indexPaths.map({ $0.row }).ns.componentsJoined(by: " "))")
        prefetchManager.prefetch(urls: indexPaths.map({ files[$0.row].url }))
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("\(#function): \(indexPaths.map({ $0.row }).ns.componentsJoined(by: " "))")
        prefetchManager.cancelPrefetching(urls: indexPaths.map({ files[$0.row].url }))
    }
}

extension PhotoBrowserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > CGFloat(index+1) * scrollView.frame.width {
            index += 1
        }
        else if scrollView.contentOffset.x < CGFloat(index-1) * scrollView.frame.width {
            index -= 1
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard index != Int(scrollView.contentOffset.x / scrollView.frame.size.width) else {
            return
        }
        index = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
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
