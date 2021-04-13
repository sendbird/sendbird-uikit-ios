//
//  SBUFileMessageCell.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/20.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers @IBDesignable
open class SBUFileMessageCell: SBUContentBaseMessageCell {
    
    // MARK: - Public property
    public var fileMessage: SBDFileMessage? {
        return self.message as? SBDFileMessage
    }
    
    // MARK: - Private property
    private lazy var baseFileContentView: BaseFileContentView = {
        let fileView = BaseFileContentView()
        return fileView
    }()
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()

        self.mainContainerView.addArrangedSubview(self.baseFileContentView)
        self.mainContainerView.addArrangedSubview(self.reactionView)
    }

    open override func setupAutolayout() {
        super.setupAutolayout()
    }
    
    open override func setupActions() {
        super.setupActions()
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.baseFileContentView.setupStyles()
    }
    
    // MARK: - Common
    open func configure(_ message: SBDFileMessage,
                          hideDateView: Bool,
                          groupPosition: MessageGroupPosition,
                          receiptState: SBUMessageReceiptState?) {

        let position = SBUGlobals.CurrentUser?.userId == message.sender?.userId ?
            MessagePosition.right :
            MessagePosition.left
        
        self.configure(
            message,
            hideDateView: hideDateView,
            position: position,
            groupPosition: groupPosition,
            receiptState: receiptState
        )
        
        switch SBUUtils.getFileType(by: message) {
        case .image, .video:
            if !(self.baseFileContentView is ImageContentView){
                self.baseFileContentView.removeFromSuperview()
                self.baseFileContentView = ImageContentView()
                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
            }
            self.baseFileContentView.configure(message: message, position: position)

        case .audio, .pdf, .etc:
            if !(self.baseFileContentView is CommonContentView) {
                self.baseFileContentView.removeFromSuperview()
                self.baseFileContentView = CommonContentView()
                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
            }
            if let commonContentView = self.baseFileContentView as? CommonContentView {
                commonContentView.configure(message: message,
                                            position: position,
                                            highlight: false)
            }
        }
    }
    
    open func configure(highlightInfo: SBUHighlightMessageInfo?) {
        // Only apply highlight for the given message, that's not edited (updatedAt didn't change)
        guard self.message.messageId == highlightInfo?.messageId,
              self.message.updatedAt == highlightInfo?.updatedAt else { return }
        
        guard let commonContentView = self.baseFileContentView as? CommonContentView,
              let fileMessage = self.fileMessage else { return }
        
        commonContentView.configure(message: fileMessage,
                                    position: self.position,
                                    highlight: true)
    }
    
    /// This method has to be called in main thread
    public func setImage(_ image: UIImage?, size: CGSize? = nil) {
        guard let imageContentView = self.baseFileContentView as? ImageContentView else { return }
        imageContentView.setImage(image, size: size)
        imageContentView.setNeedsLayout()
    }

    
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
