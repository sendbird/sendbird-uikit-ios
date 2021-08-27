//
//  UserInfoTitleView.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/14.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class UserInfoTitleView: UIView {
    lazy var stackView = UIStackView()
    lazy var coverImage = UIImageView()
    lazy var userNicknameLabel = UILabel()
    lazy var lineView = UIView()
    lazy var userIdTitleLabel = UILabel()
    lazy var userIdLabel = UILabel()
    lazy var bottomLineView = UIView()
    
    var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme
    
    let kCoverImageSize: CGFloat = 80.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "UserInfoView.init(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.coverImage.clipsToBounds = true
        
        self.userNicknameLabel.textAlignment = .center
        self.userNicknameLabel.isUserInteractionEnabled = false
        
        self.stackView.alignment = .center
        self.stackView.axis = .vertical
        self.stackView.spacing = 7
        self.stackView.addArrangedSubview(self.coverImage)
        self.stackView.addArrangedSubview(self.userNicknameLabel)
        self.addSubview(stackView)
        
        self.addSubview(lineView)
        
        self.userIdTitleLabel.textAlignment = .left
        self.userIdTitleLabel.isUserInteractionEnabled = false
        self.userIdLabel.textAlignment = .left
        self.userIdLabel.isUserInteractionEnabled = false
        self.addSubview(self.userIdTitleLabel)
        self.addSubview(self.userIdLabel)
        
        self.addSubview(self.bottomLineView)
    }
    
    func setupAutolayout() {
        self.coverImage.translatesAutoresizingMaskIntoConstraints = false
        self.userNicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.lineView.translatesAutoresizingMaskIntoConstraints = false
        self.userIdTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bottomLineView.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        layoutConstraints.append(self.coverImage.widthAnchor.constraint(
            equalToConstant: kCoverImageSize)
        )
        layoutConstraints.append(self.coverImage.heightAnchor.constraint(
            equalToConstant: kCoverImageSize)
        )
        
        layoutConstraints.append(self.userNicknameLabel.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: 16)
        )
        layoutConstraints.append(self.userNicknameLabel.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: -16)
        )
        
        layoutConstraints.append(self.stackView.leadingAnchor.constraint(
            equalTo: self.leadingAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.stackView.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: 0)
        )
        layoutConstraints.append(self.stackView.topAnchor.constraint(
            equalTo: self.topAnchor,
            constant: 24)
        )

        layoutConstraints.append(self.lineView.heightAnchor.constraint(equalToConstant: 0.5))
        layoutConstraints.append(self.lineView.topAnchor.constraint(
            equalTo: self.stackView.bottomAnchor,
            constant: 23)
        )
        
        if #available(iOS 11.0, *) {
            layoutConstraints.append(self.lineView.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                constant: 16)
            )
            layoutConstraints.append(self.lineView.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                constant: -16)
            )
            layoutConstraints.append(self.userIdTitleLabel.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                constant: 16)
            )
            layoutConstraints.append(self.userIdTitleLabel.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                constant: -16)
            )
            layoutConstraints.append(self.userIdLabel.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                constant: 16)
            )
            layoutConstraints.append(self.userIdLabel.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                constant: -16)
            )
            layoutConstraints.append(self.bottomLineView.leadingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.leadingAnchor,
                constant: 16)
            )
            layoutConstraints.append(self.bottomLineView.trailingAnchor.constraint(
                equalTo: self.safeAreaLayoutGuide.trailingAnchor,
                constant: -16)
            )
        } else {
            layoutConstraints.append(self.lineView.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 16)
            )
            layoutConstraints.append(self.lineView.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -16)
            )
            layoutConstraints.append(self.userIdTitleLabel.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 16)
            )
            layoutConstraints.append(self.userIdTitleLabel.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -16)
            )
            layoutConstraints.append(self.userIdLabel.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 16)
            )
            layoutConstraints.append(self.userIdLabel.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -16)
            )
            layoutConstraints.append(self.bottomLineView.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 16)
            )
            layoutConstraints.append(self.bottomLineView.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -16)
            )
        }
        layoutConstraints.append(self.userIdTitleLabel.topAnchor.constraint(
            equalTo: self.lineView.bottomAnchor,
            constant: 15)
        )
        
        layoutConstraints.append(self.userIdLabel.topAnchor.constraint(
            equalTo: self.userIdTitleLabel.bottomAnchor,
            constant: 2)
        )
        
        layoutConstraints.append(self.bottomLineView.heightAnchor.constraint(equalToConstant: 0.5))
        layoutConstraints.append(self.bottomLineView.topAnchor.constraint(
            equalTo: self.userIdLabel.bottomAnchor,
            constant: 15.5)
        )
        
        layoutConstraints.append(self.bottomLineView.bottomAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: 0)
        )
        
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func setupStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.backgroundColor = .clear
        
        self.lineView.backgroundColor = theme.cellSeparateColor
        
        self.userNicknameLabel.font = SBUFontSet.h3
        self.userNicknameLabel.textColor = theme.userNameTextColor
        
        self.userIdTitleLabel.font = SBUFontSet.body3
        self.userIdTitleLabel.textColor = theme.cellSubTextColor
        
        self.userIdLabel.font = SBUFontSet.body1
        self.userIdLabel.textColor = theme.cellTextColor
        
        self.bottomLineView.backgroundColor = theme.cellSeparateColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImage.layer.cornerRadius = kCoverImageSize / 2
        self.coverImage.layer.borderColor = UIColor.clear.cgColor
        self.coverImage.layer.borderWidth = 1
        
        self.setupStyles()
    }
    
    func configure(user: SBUUser) {
        if let urlString = user.profileUrl, let url = URL(string: urlString) {
            self.downloadImage(from: url)
        }
        self.userNicknameLabel.text = user.nickname ?? user.userId
        
        self.userIdTitleLabel.text = "User ID"
        self.userIdLabel.text = user.userId
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.coverImage.image = UIImage(data: data)
            }
        }.resume()
    }
}

