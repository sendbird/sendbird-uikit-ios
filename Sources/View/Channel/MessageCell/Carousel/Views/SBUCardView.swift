//
//  SBUCardView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/13.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUCardView: SBUView {
    public struct Metric {
        public static var maxWidth = 258.0
        public static var textMinWidth = 10.0
        public static var imageSize = 40.0
    }
    
    // MARK: - Properties
    /// The theme for ``SBUCardView`` that is type of  ``SBUMessageCellTheme``
    /// - Since: 3.7.0
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// The URL of the image on the card. It's returned by ``SBUCardViewParams``
    /// - Since: 3.7.0
    public var imageURL: String? { self.params?.imageURL }
    /// The title of the card. It's returned by ``SBUCardViewParams``
    /// - Since: 3.7.0
    public var title: String? { self.params?.title }
    /// The subtitle of the card. It's returned by ``SBUCardViewParams``
    /// - Since: 3.7.0
    public var subtitle: String? { self.params?.subtitle }
    /// The description of the card. It's returned by ``SBUCardViewParams``
    /// - Since: 3.7.0
    public var text: String? { self.params?.description }
    /// The link of the card. It's returned by ``SBUCardViewParams``
    /// - Since: 3.7.0
    public var link: String? { self.params?.link }
    
    /// The data structure for ``SBUCardViewParams`` that is used for UI. Please use ``configure(with:)`` to update ``params``
    /// - Since: 3.7.0
    public private(set) var params: SBUCardViewParams?
    
    /// ``SBUStackView`` instance. The default value is a vertical stack view that contains ``mainInfoStackView`` and ``descriptionTextView``
    /// - Since: 3.7.0
    public var contentStackView = SBUStackView(
        axis: .vertical,
        alignment: .leading,
        spacing: 0
    )
    /// ``SBUStackView`` instance. The default value is a horizontal stack view that contains ``imageView`` and ``titleStackView``
    /// - Since: 3.7.0
    public var mainInfoStackView = SBUStackView(
        axis: .horizontal,
        alignment: .top,
        spacing: 12
    )
    
    /// ``SBUStackView`` instance. The default value is a vertical stack view that contains ``titleLabel`` and ``subtitleLabel``
    /// - Since: 3.7.0
    public var titleStackView = SBUStackView(
        axis: .vertical,
        alignment: .leading,
        spacing: 4
    )
    
    /// The label that represents ``titleLabel``
    /// - Since: 3.7.0
    public var titleLabel = UILabel()
    
    /// The label that represents ``subtitle``
    /// - Since: 3.7.0
    public var subtitleLabel = UILabel()
    
    /// The image view that loads image with ``imageURL``
    /// - Since: 3.7.0
    public lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// The text view that represents ``text``
    /// - Since: 3.7.0
    public var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .init(top: 12, left: 12, bottom: 12, right: 12)
        
        return textView
    }()
    
    public var textLeftConstraint: NSLayoutConstraint?
    public var textRightConstraint: NSLayoutConstraint?
    
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }
    
    public override func setupViews() {
        super.setupViews()
        
        self.imageView.isHidden = true
        self.titleLabel.isHidden = self.title == nil
        self.subtitleLabel.isHidden = self.subtitle == nil
        self.descriptionTextView.isHidden = self.text == nil
        
        self.titleLabel.numberOfLines = 0
        self.subtitleLabel.numberOfLines = 0
        
        self.contentStackView.setVStack([
            self.mainInfoStackView.setHStack([
                self.imageView,
                self.titleStackView.setVStack([
                    self.titleLabel,
                    self.subtitleLabel
                ])
            ]),
            self.descriptionTextView
        ])
        
        self.addSubview(contentStackView)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.contentStackView
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.mainInfoStackView.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        self.mainInfoStackView.isLayoutMarginsRelativeArrangement = true
        
        let textHeightConstraint = self.descriptionTextView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 16
        )
        NSLayoutConstraint.activate([
            textHeightConstraint
        ])
        self.descriptionTextView
            .sbu_constraint(equalTo: self.contentStackView, left: 0, right: 0)
        
        self.imageView
            .sbu_constraint(width: Metric.imageSize, height: Metric.imageSize)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = self.theme.backgroundColor
        self.layer.borderColor = self.theme.leftBackgroundColor.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        self.imageView.layer.cornerRadius = Metric.imageSize / 2
        
        self.titleLabel.textColor = self.params?.hasLink == true
        ? self.theme.linkColor
        : self.theme.userMessageLeftTextColor
        self.titleLabel.font = self.theme.selectableTitleFont
        
        self.subtitleLabel.textColor = self.theme.userMessageLeftTextColor
        self.subtitleLabel.font = self.theme.userMessageFont
        
        self.descriptionTextView.backgroundColor = self.theme.leftBackgroundColor
        self.descriptionTextView.textColor = self.theme.userMessageLeftTextColor
        self.descriptionTextView.font = self.theme.userMessageFont
    }
    
    public override func setupActions() {
        super.setupActions()
        
        if self.params?.hasLink == true {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openURL))
            self.titleLabel.isUserInteractionEnabled = true
            self.titleLabel.addGestureRecognizer(tapGesture)
        }
    }
    
    /// Updates UI with ``SBUCardViewParams`` object and loads image if ``imageURL`` has a value.
    /// - Note: It updates ``params`` and calls ``setupViews()``, ``setupLayouts()``, ``setupStyles()`` and ``setupActions()``.
    /// - Since: 3.7.0
    public func configure(with configuration: SBUCardViewParams) {
        self.params = configuration
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
        self.setupActions()
        
        self.layoutIfNeeded()
        
        if let imageURL = self.imageURL {
            self.loadImageSession = self.imageView.loadImage(urlString: imageURL) { onSucceed in
                self.imageView.isHidden = !onSucceed
            }
        }
        
        self.titleLabel.text = self.title
        self.subtitleLabel.text = self.subtitle
        self.descriptionTextView.text = self.text
    }
    
    /// Opens URL with (``SBUCardViewParams/link``)
    /// - Since: 3.7.0
    @objc
    public func openURL() {
        guard let urlString = self.params?.link else { return }
        guard let url = URL(string: urlString) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        url.open()
    }
}
