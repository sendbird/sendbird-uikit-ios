//
//  SBUFileMessageCell.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@IBDesignable
open class SBUFileMessageCell: SBUContentBaseMessageCell {
    
    // MARK: - Public property
    public var fileMessage: FileMessage? {
        self.message as? FileMessage
    }
    
    public lazy var baseFileContentView: SBUBaseFileContentView = {
        let fileView = SBUBaseFileContentView()
        return fileView
    }()
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()

        // + ------------------- +
        // | baseFileContentView |
        // + ------------------- +
        // | reactionView        |
        // + ------------------- +
        
        self.mainContainerView.setStack([
            self.baseFileContentView,
            self.reactionView
        ])
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.mainContainerView
            .sbu_constraint_lessThan(width: SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize.width)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.baseFileContentView.setupStyles()
    }
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let configuration = configuration as? SBUFileMessageCellParams else { return }
        guard let message = configuration.fileMessage else { return }
        // Set using reaction
        self.useReaction = configuration.useReaction
        
        self.useQuotedMessage = configuration.useQuotedMessage
        
        self.useThreadInfo = configuration.useThreadInfo
        
        // Configure Content base message cell
        super.configure(with: configuration)
        
        // Set up base file content view
        switch SBUUtils.getFileType(by: message) {
            case .image, .video:
            if !(self.baseFileContentView is SBUImageContentView) {
                self.baseFileContentView.removeFromSuperview()
                self.baseFileContentView = SBUImageContentView()
                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
            }
            self.baseFileContentView.configure(
                message: message,
                position: configuration.messagePosition
            )
                
            case .audio, .pdf, .etc:
            if !(self.baseFileContentView is SBUCommonContentView) {
                self.baseFileContentView.removeFromSuperview()
                self.baseFileContentView = SBUCommonContentView()
                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
            }
            if let commonContentView = self.baseFileContentView as? SBUCommonContentView {
                commonContentView.configure(
                    message: message,
                    position: configuration.messagePosition,
                    highlightKeyword: nil
                )
            }
            
        case .voice:
            if !(self.baseFileContentView is SBUVoiceContentView) {
                self.baseFileContentView.removeFromSuperview()
                self.baseFileContentView = SBUVoiceContentView()
                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
            }
            if let voiceContentView = self.baseFileContentView as? SBUVoiceContentView {
                voiceContentView.configure(
                    message: message,
                    position: configuration.messagePosition,
                    voiceFileInfo: configuration.voiceFileInfo
                )
            }

            break
        }
    }
    
    open override func configure(highlightInfo: SBUHighlightMessageInfo?) {
        // Only apply highlight for the given message, that's not edited (updatedAt didn't change)
        guard let message = self.message,
              message.messageId == highlightInfo?.messageId,
              message.updatedAt == highlightInfo?.updatedAt else { return }
        
        guard let commonContentView = self.baseFileContentView as? SBUCommonContentView,
              let fileMessage = self.fileMessage else { return }
        
        commonContentView.configure(
            message: fileMessage,
            position: self.position,
            highlightKeyword: highlightInfo?.keyword
        )
    }
    
    /// This method has to be called in main thread
    public func setImage(_ image: UIImage?, size: CGSize? = nil) {
        guard let imageContentView = self.baseFileContentView as? SBUImageContentView else { return }
        imageContentView.setImage(image, size: size)
        imageContentView.setNeedsLayout()
    }
    
    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
    open func configure(_ message: FileMessage,
                        hideDateView: Bool,
                        groupPosition: MessageGroupPosition,
                        receiptState: SBUMessageReceiptState?,
                        useReaction: Bool) {
        let configuration = SBUFileMessageCellParams(
            message: message,
            hideDateView: hideDateView,
            useMessagePosition: true,
            groupPosition: groupPosition,
            receiptState: receiptState ?? .none,
            useReaction: useReaction
        )
        self.configure(with: configuration)
    }
    
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
