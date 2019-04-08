//
//  PhotoListFlowLayout.swift
//  Files
//
//  Created by 翟泉 on 2019/4/4.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit

protocol PhotoListFlowLayoutDelegate: NSObjectProtocol {
    func collectionView(_ collectionView: UICollectionView, layout: PhotoListFlowLayout, originalItemSizeAtIndexPath: IndexPath) -> CGSize
}

class PhotoListFlowLayout: UICollectionViewFlowLayout, DocumentBrowserFlowLayout {
    var numberOfColumns: Int = 0
    var columnSpacing: CGFloat = 0
    var interItemSpacing: UIEdgeInsets = .zero
    var headerHeight: CGFloat = 0
    var columnHeights = [[CGFloat]]()
    var itemAttributes = [[UICollectionViewLayoutAttributes]]()
    var headerAttributes = [UICollectionViewLayoutAttributes]()
    var allAttributes = [UICollectionViewLayoutAttributes]()

    private var prefetchManager = PhotoPrefetchManager()

    var delegate: DocumentBrowserFlowLayoutDelegate?

    func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell {
        if let file = delegate?.flowLayout(self, fileForItemAt: indexPath) {
            if file.type is PhotoFileType {
                let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: "Photo", for: indexPath) as! PhotoCollectionViewCell
                cell.backgroundColor = ColorRGB(CGFloat(arc4random_uniform(255)), CGFloat(arc4random_uniform(255)), CGFloat(arc4random_uniform(255)))
                cell.imageView.image = nil
                prefetchManager.requestImage(url: file.url, targetSize: .thumbnail) { (image) in
                    cell.backgroundColor = nil
                    cell.imageView.image = image
                }
                return cell
            } else if file.type is DirectoryFileType {
                let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: "Directory", for: indexPath) as! DirectoryCollectionViewCell
                cell.titleLabel.text = file.name
                return cell
            }
        }
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "Unknown", for: indexPath)
    }

    required override init() {
        super.init()
        sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        scrollDirection = .vertical
        numberOfColumns = 3
        interItemSpacing = .zero
        sectionInset = .zero
        columnSpacing = 0
        headerHeight = 0
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        super.prepare()
        collectionView!.register(PhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Photo")
        collectionView!.register(DirectoryCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Directory")
        collectionView!.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Unknown")

        itemAttributes = []
        allAttributes = []
        headerAttributes = []
        columnHeights = []

        var top: CGFloat = 0

        let numberOfSections: NSInteger = collectionView!.numberOfSections

        for section in 0 ..< numberOfSections {
            let numberOfItems = collectionView!.numberOfItems(inSection: section)
            top += sectionInset.top

            if (headerHeight > 0) {
                let headerSize: CGSize = headerSizeForSection(section: section)
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: NSIndexPath(row: 0, section: section) as IndexPath)

                attributes.frame = CGRect(x: sectionInset.left, y: top, width: headerSize.width, height: headerSize.height)
                headerAttributes.append(attributes)
                allAttributes.append(attributes)
                top = attributes.frame.maxY
            }

            columnHeights.append([]) //Adding new Section
            for _ in 0 ..< self.numberOfColumns {
                columnHeights[section].append(top)
            }

            let columnWidth = columnWidthForSection(section: section)
            itemAttributes.append([])
            for idx in 0 ..< numberOfItems {
                let columnIndex: Int = shortestColumnIndexInSection(section: section)
                let indexPath = IndexPath(item: idx, section: section)

                let itemSize = itemSizeAtIndexPath(indexPath: indexPath);
                let xOffset = sectionInset.left + (columnWidth + columnSpacing) * CGFloat(columnIndex)
                let yOffset = columnHeights[section][columnIndex]

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: yOffset, width: itemSize.width, height: itemSize.height)

                columnHeights[section][columnIndex] = attributes.frame.maxY + interItemSpacing.bottom

                itemAttributes[section].append(attributes)
                allAttributes.append(attributes)
            }

            let columnIndex: Int = tallestColumnIndexInSection(section: section)
            top = columnHeights[section][columnIndex] - interItemSpacing.bottom + sectionInset.bottom

            for idx in 0 ..< columnHeights[section].count {
                columnHeights[section][idx] = top
            }
        }
        print(#function)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var includedAttributes: [UICollectionViewLayoutAttributes] = []
        // Slow search for small batches
        for attribute in allAttributes {
            if (attribute.frame.intersects(rect)) {
                includedAttributes.append(attribute)
            }
        }
        return includedAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < itemAttributes.count,
            indexPath.item < itemAttributes[indexPath.section].count
            else {
                return nil
        }
        return itemAttributes[indexPath.section][indexPath.item]
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if (elementKind == UICollectionView.elementKindSectionHeader) {
            return headerAttributes[indexPath.section]
        }
        return nil
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return collectionView!.bounds.size.width != newBounds.size.width
    }

    override var collectionViewContentSize: CGSize {
        var height: CGFloat = 0
        if columnHeights.count > 0 {
            if columnHeights[columnHeights.count-1].count > 0 {
                height = columnHeights[columnHeights.count - 1][0]
            }
        }
        return CGSize(width: collectionView!.bounds.size.width, height: height)
    }
}

// MARK: - Utils
extension PhotoListFlowLayout {
    func widthForSection (section: Int) -> CGFloat {
        return collectionView!.bounds.size.width - sectionInset.left - sectionInset.right;
    }

    func headerSizeForSection(section: Int) -> CGSize {
        return CGSize(width: widthForSection(section: section), height: headerHeight)
    }

    func columnWidthForSection(section: Int) -> CGFloat {
        return (widthForSection(section: section) - ((CGFloat(numberOfColumns - 1)) * columnSpacing)) / CGFloat(numberOfColumns)
    }

    func itemSizeAtIndexPath(indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: columnWidthForSection(section: indexPath.section), height: 0)
        guard let file = delegate?.flowLayout(self, fileForItemAt: indexPath) else { return size }
        if file.type is PhotoFileType {
            if let originalSize = UIImage(contentsOfFile: file.url.path)?.size {
                if (originalSize.height > 0 && originalSize.width > 0) {
                    size.height = originalSize.height / originalSize.width * size.width
                }
            }
        } else if file.type is DirectoryFileType {
            size.height = size.width * 0.8
        }
        return size
    }

    func shortestColumnIndexInSection(section: Int) -> Int {
        var index = 0
        var shortestHeight = CGFloat.greatestFiniteMagnitude
        columnHeights[section].enumerated().forEach { (offset: Int, element: CGFloat) in
            if element < shortestHeight {
                index = offset
                shortestHeight = element
            }
        }
        return index
    }

    func tallestColumnIndexInSection(section: Int) -> Int {
        var index = 0
        var tallestHeight: CGFloat = 0
        columnHeights[section].enumerated().forEach { (offset: Int, element: CGFloat) in
            if element > tallestHeight {
                index = offset
                tallestHeight = element
            }
        }
        return index
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

private class DirectoryCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorRGB(CGFloat(arc4random_uniform(180)), CGFloat(arc4random_uniform(180)), CGFloat(arc4random_uniform(180)))
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (maker) in
            maker.edges.equalTo(UIEdgeInsets.zero)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = Font(18)
        titleLabel.textColor = .white
        return titleLabel
    }()
}
