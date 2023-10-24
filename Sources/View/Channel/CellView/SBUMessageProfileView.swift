//
//  SBUMessageProfileView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUMessageProfileView: SBUView {
    public static let imageSize: CGFloat = 26
    
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        return imageView
    }()
    public var urlString: String
     
    public init(urlString: String = "") {
        self.urlString = urlString

        super.init(frame: .zero)
    }
    
    public var imageDownloadTask: URLSessionTask?
    
    var imageSize: CGFloat = SBUMessageProfileView.imageSize
    
    public override init() {
        self.urlString = ""

        super.init()
    }
    
    override public init(frame: CGRect) {
        self.urlString = ""

        super.init(frame: frame)
    }

    open override func setupViews() {
        self.addSubview(self.imageView)
    }
     
    open override func setupLayouts() {
        self.imageView
            .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        self.backgroundColor = .clear
    }
    
    open func configure(urlString: String,
                        imageSize: CGFloat? = SBUMessageProfileView.imageSize) {
        self.urlString = urlString
        if let imageSize = imageSize {
            self.imageSize = imageSize
        }
        
        self.imageView.sbu_constraint(width: self.imageSize, height: self.imageSize)
        imageView.layer.cornerRadius = self.imageSize / 2
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 1
        
        imageView.contentMode = urlString.count > 0 ? .scaleAspectFill : .center
        
        self.imageDownloadTask = self.imageView.loadImage(
            urlString: urlString,
            placeholder: SBUIconSetType.iconUser.image(
                with: self.theme.userPlaceholderTintColor,
                to: SBUIconSetType.Metric.iconUserProfileInChat
            ),
            subPath: SBUCacheManager.PathType.userProfile
        )
        self.imageView.backgroundColor = theme.userPlaceholderBackgroundColor
    }
}
