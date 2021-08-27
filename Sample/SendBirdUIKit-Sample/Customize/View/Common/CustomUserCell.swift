//
//  CustomUserCell.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/07.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class CustomUserCell: UITableViewCell {

    // MARK: - Properties
    @SBUAutoLayout var userImage = UIImageView()
    @SBUAutoLayout var titleLabel = UILabel()
    
    let kUserImageSize: CGFloat = 40
    
    // MARK: - View Lifecycle
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
        self.setupAutolayout()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupAutolayout()
    }
    
    // MARK: -
    func setupViews() {
        self.userImage.clipsToBounds = true
        self.userImage.frame = CGRect(x: 0, y: 0, width: kUserImageSize, height: kUserImageSize)
        self.contentView.addSubview(self.userImage)
        
        let width = self.contentView.frame.width - kUserImageSize
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: width, height: kUserImageSize)
        self.contentView.addSubview(self.titleLabel)
    }
    
    func setupAutolayout() {
        NSLayoutConstraint.activate([
            self.userImage.topAnchor.constraint(
                equalTo: self.contentView.topAnchor,
                constant: 10
            ),
            self.userImage.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor,
                constant: -10
            ),
            self.userImage.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor,
                constant: 16
            ),
            self.userImage.widthAnchor.constraint(equalToConstant: kUserImageSize),
            self.userImage.heightAnchor.constraint(equalToConstant: kUserImageSize),
        ])
        
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(
                equalTo: self.userImage.trailingAnchor,
                constant: 20
            ),
            self.titleLabel.topAnchor.constraint(
                equalTo: self.contentView.topAnchor,
                constant: 10
            ),
            self.titleLabel.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor,
                constant: 16
            ),
            self.titleLabel.heightAnchor.constraint(equalToConstant: kUserImageSize),
        ])
    }

    func setupStyles() {
        self.titleLabel.font = SBUTheme.channelCellTheme.titleFont
        self.titleLabel.textColor = SBUTheme.channelCellTheme.titleTextColor
    }

    func selectCheck() {
        self.backgroundColor = self.isSelected ? SBUColorSet.secondary100 : .clear
    }
    
    func configure(title: String, selected: Bool = false) {
        self.titleLabel.text = title
        self.userImage.image = UIImage(named: "img_default_profile_image_\(Int.random(in: 1...4))")
        self.backgroundColor = selected ? SBUColorSet.secondary100 : .clear
    }
}
