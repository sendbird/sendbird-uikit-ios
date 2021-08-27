//
//  SBUMessageProfileView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUMessageProfileView: UIView {
    private static let imageSize: CGFloat = 26
    
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = SBUMessageProfileView.imageSize / 2
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 1
        imageView.clipsToBounds = true
        return imageView
    }()
    var urlString: String = ""
     
    public init(urlString: String) {
        self.urlString = urlString
        super.init(frame: .init(x: 0, y: 0, width: 26, height: 26))
        self.setupViews()
        self.setupAutolayout()
        self.configure(urlString: urlString)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
        self.configure(urlString: self.urlString)
    }
    
    @available(*, unavailable, renamed: "MessageProfileView(imageURL:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.addSubview(self.imageView)
    }
     
    func setupAutolayout() {
        self.imageView
            .setConstraint(width: SBUMessageProfileView.imageSize,
                           height: SBUMessageProfileView.imageSize)
            .setConstraint(from: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    func setupStyles() {
        self.theme = SBUTheme.messageCellTheme
        
        self.backgroundColor = .clear
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }
    
    func configure(urlString: String) {
        self.urlString = urlString
        
        self.imageView.loadImage(
            urlString: urlString,
            placeholder: SBUIconSetType.iconUser.image(
                with: self.theme.userPlaceholderTintColor,
                to: SBUIconSetType.Metric.iconUserProfileInChat
            )
        )
        self.imageView.backgroundColor = theme.userPlaceholderBackgroundColor
    }
}
