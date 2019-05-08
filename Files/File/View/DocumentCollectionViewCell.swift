//
//  DocumentCollectionViewCell.swift
//  Files
//
//  Created by 翟泉 on 2019/3/18.
//  Copyright © 2019 cezres. All rights reserved.
//

import UIKit
import SnapKit

class DocumentCollectionViewCell: UICollectionViewCell {
    var file: File! {
        didSet {
            iconImageView.image = nil
            nameLabel.text = file.name
            file.thumbnail { [weak self](file, result) in
                guard let self = self else { return }
                guard self.file == file else { return }
                self.iconImageView.image = result
            }
        }
    }

    var isEditing = false {
        didSet {
            chooseView.isHidden = !isEditing
        }
    }

    var isSelecting = false {
        didSet {
            if isSelecting {
                chooseView.image = UIImage(named: "icon_choose_y")
            } else {
                chooseView.image = UIImage(named: "icon_choose_n")
            }
        }
    }

    static func itemSize(for width: CGFloat) -> CGSize {
        return CGSize(width: width, height: width + UIFont.systemFont(ofSize: 12).lineHeight * 2)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundView = UIView()
        backgroundView?.backgroundColor = UIColor.white
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = ColorWhite(220)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View
    func setupUI() {
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(nameLabel.font.lineHeight*2)
        }

        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(self.snp.width).offset(-20)
            make.top.equalTo(10)
        }

        contentView.addSubview(chooseView)
        chooseView.snp.makeConstraints({ (make) in
            make.size.equalTo(CGSize(width: 32, height: 32))
            make.top.equalTo(0)
            make.right.equalTo(0)
        })
    }

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isOpaque = true
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.isOpaque = true
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    private lazy var chooseView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_choose_n")
        imageView.isHidden = true
        return imageView
    }()
}
