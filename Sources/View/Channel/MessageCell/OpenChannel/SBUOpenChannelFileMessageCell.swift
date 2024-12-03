//
//  SBUOpenChannelFileMessageCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@IBDesignable
open class SBUOpenChannelFileMessageCell: SBUOpenChannelContentBaseMessageCell {
    
    // MARK: - Public property
    public var fileMessage: FileMessage? {
        self.message as? FileMessage
    }
    
    public lazy var baseFileContentView: SBUBaseFileContentView = {
        let fileView = SBUBaseFileContentView()
        return fileView
    }()
    
    var ratioConstraint: NSLayoutConstraint?
    
    var fileType: SBUMessageFileType = .etc
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()

        if let mainContainerView = self.mainContainerView as? SBUSelectableStackView {
            mainContainerView.addArrangedSubview(self.baseFileContentView)
        }
    }

    open override func setupLayouts() {
        self.mainContainerView.sbu_constraint_lessThan(
            width: SBUGlobals.messageCellConfiguration.openChannel.thumbnailSize.width
        )
        
        var heightConstraintSettingClosure = {
            self.ratioConstraint?.isActive = false
            self.ratioConstraint = self.mainContainerView.heightAnchor.constraint(
                equalTo: self.mainContainerView.widthAnchor,
                multiplier: 0.65
            )
            self.ratioConstraint?.isActive = true
        }

        #if SWIFTUI
        // Disable fixed height when using view converter
        if self.viewConverter.fileMessage.entireContent == nil {
            heightConstraintSettingClosure()
        }
        #else
        heightConstraintSettingClosure()
        #endif
        
        super.setupLayouts()
    }
    
    open override func setupActions() {
        super.setupActions()
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.baseFileContentView.setupStyles()
        
        #if SWIFTUI
        if self.viewConverter.fileMessage.entireContent != nil,
           let mainContainerView = self.mainContainerView as? SBUSelectableStackView {
            mainContainerView.layer.cornerRadius = 0
            mainContainerView.setTransparentBackgroundColor()
        }
        #endif
    }
    
    // MARK: - Common
    open func configure(
        _ message: FileMessage,
        hideDateView: Bool,
        groupPosition: MessageGroupPosition,
        fileType: SBUMessageFileType,
        isOverlay: Bool = false
    ) {
        self.configure(
            message,
            hideDateView: hideDateView,
            groupPosition: groupPosition,
            isOverlay: isOverlay
        )

        self.isFileType = true
        self.fileType = fileType
        
        var didApplyFileMessageViewConverter = false
        #if SWIFTUI
        // FileMessage
        didApplyFileMessageViewConverter = self.applyViewConverter(.fileMessage)
        #endif
        
        if !didApplyFileMessageViewConverter {
            switch fileType {
            case .image, .video:
                self.ratioConstraint?.isActive = false
                if !(self.baseFileContentView is SBUOpenChannelImageContentView) {
                    self.baseFileContentView.removeFromSuperview()
                    self.baseFileContentView = SBUOpenChannelImageContentView()
                    self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                    self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                    if let mainContainerView = self.mainContainerView as? SBUSelectableStackView {
                        mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
                    }
                }
                self.ratioConstraint?.isActive = true
                self.baseFileContentView.configure(message: message, position: .left)
                
            case .audio, .pdf, .etc:
                if !(self.baseFileContentView is SBUOpenChannelCommonContentView) {
                    self.baseFileContentView.removeFromSuperview()
                    self.baseFileContentView = SBUCommonContentView()
                    self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                    self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                    if let mainContainerView = self.mainContainerView as? SBUSelectableStackView {
                        mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
                    }
                }
                self.ratioConstraint?.isActive = false
                if let commonContentView = self.baseFileContentView as? SBUCommonContentView {
                    commonContentView.configure(
                        message: message,
                        position: .left,
                        highlightKeyword: nil
                    )
                }
                
            case .voice:
                // new message info view (OpenChannel)
                break
            }
        }

        // Remove ArrangedSubviews
        self.contentsStackView.arrangedSubviews.forEach(
            self.contentsStackView.removeArrangedSubview(_:)
        )
        
        self.baseStackView.alignment = .top
        self.profileView.isHidden = false
        
        self.contentsStackView.addArrangedSubview(self.infoStackView)
        self.contentsStackView.addArrangedSubview(self.mainContainerView)
        self.contentsStackView.addArrangedSubview(self.stateImageView)
    }
    
    public func setImage(_ image: UIImage?, size: CGSize? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let imageContentView = self.baseFileContentView as? SBUImageContentView else { return }
            imageContentView.setImage(image, size: size)
            imageContentView.setNeedsLayout()
        }
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
