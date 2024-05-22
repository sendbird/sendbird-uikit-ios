//
//  SBUMessageProfileView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

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
    
    /// Label used to show the number of remaining typers when there are more than 3 concurrent typers.
    /// This view is used in``SBUTypingIndicatorMessageCell``.
    /// - Since: 3.12.0
    public lazy var numberLabel: UILabel = {
       let label = UILabel()
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = theme.leftBackgroundColor
        label.textColor = theme.userNameTextColor
        label.isHidden = true
        return label
    }()
     
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
        self.addSubview(self.numberLabel)
    }
     
    open override func setupLayouts() {
        self.imageView
            .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        self.numberLabel
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
            option: .imageToThumbnail,
            subPath: SBUCacheManager.PathType.userProfile
        )
        self.imageView.backgroundColor = theme.userPlaceholderBackgroundColor
    }
    
    /// Configures the `imageView` of the profile view when it is used to indicate a currently typing user.
    /// This method is specifically called to display the typers in a ``SBUTypingIndicatorMessageCell``.
    /// - Since: 3.12.0
    public func configureTyperProfileImageView() {
        imageView.layer.borderColor = theme.typingMessageProfileBorderColor.cgColor
        imageView.layer.borderWidth = 2
    }
    
    /// Configures the `numberLabel` of the profile view when it is used to indicate a currently typing user.
    /// This method is specifically called to display the typers in a ``SBUTypingIndicatorMessageCell``.
    /// - Parameters:
    ///    - numberOfTypers: The number to appear on the number label.
    /// - Since: 3.12.0
    public func configureNumberLabel(_ numberOfTypers: Int) {
        self.numberLabel.isHidden = false
        self.numberLabel.sbu_constraint(width: self.imageSize, height: self.imageSize)
        self.numberLabel.layer.cornerRadius = self.imageSize / 2
        self.numberLabel.layer.borderWidth = 2
        self.numberLabel.layer.borderColor = theme.typingMessageProfileBorderColor.cgColor
        
        self.numberLabel.text = SBUStringSet.Message_Typers_Count(numberOfTypers)
    }
}
