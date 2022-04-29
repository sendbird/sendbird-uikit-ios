//
//  SBUBaseChannelModule.Input.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/16.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


/// Event methods for the views updates and performing actions from the input component.
public protocol SBUBaseChannelModuleInputDelegate: SBUCommonDelegate {
    /// Called when the message input view started to type.
    /// - Parameter inputComponent: `SBUBaseChannelModule.Input`
    func baseChannelModuleDidStartTyping(_ inputComponent: SBUBaseChannelModule.Input)
    
    /// Called when the message Input view ended typing.
    /// - Parameter inputComponent: `SBUBaseChannelModule.Input`
    func baseChannelModuleDidEndTyping(_ inputComponent: SBUBaseChannelModule.Input)
    
    /// Called when the send button was tapped.
    /// - Parameters:
    ///    - inputComponent: `SBUBaseChannelModule.Input` object.
    ///    - text: The sent text of message.
    ///    - parentMessage: The parent message of the message representing `text`.
    func baseChannelModule(
        _ inputComponent: SBUBaseChannelModule.Input,
        didTapSend text: String,
        parentMessage: SBDBaseMessage?
    )
    
    /// Called when the media resource button was tapped.
    /// - Parameters:
    ///    - inputComponent: `SBUBaseChannelModule.Input` object.
    ///    - type: `MediaResourceType` value.
    func baseChannelModule(
        _ inputComponent: SBUBaseChannelModule.Input,
        didTapResource type: MediaResourceType
    )
    
    /// Called when the edit button was tapped.
    /// - Parameters:
    ///    - inputComponent: `SBUBaseChannelModule.Input` object.
    ///    - text: The text on editing
    func baseChannelModule(
        _ inputComponent: SBUBaseChannelModule.Input,
        didTapEdit text: String
    )
    
    /// Called when the text was changed.
    /// - Parameters:
    ///    - inputComponent: `SBUBaseChannelModule.Input` object.
    ///    - text: The changed text.
    func baseChannelModule(
        _ inputComponent: SBUBaseChannelModule.Input,
        didChangeText text: String
    )
    
    /// Called when the message input mode was changed.
    /// - Parameters:
    ///    - inputComponent: `SBUBaseChannelModule.Input` object.
    ///    - mode: `SBUMessageInputMode` value. It represents the current mode of `messageInputView`.
    ///    - message: `SBDBaseMessage` object. It's `nil` when the `mode` is `none`.
    func baseChannelModule(
        _ inputComponent: SBUBaseChannelModule.Input,
        willChangeMode mode: SBUMessageInputMode,
        message: SBDBaseMessage?
    )
    
    /// Called when the message input mode will be changed via `setMode(_:message:)` method.
    /// - Parameters:
    ///    - inputComponent: `SBUBaseChannelModule.Input` object.
    ///    - mode: `SBUMessageInputMode` value. The `messageInputView` changes its mode to this value.
    ///    - message: `SBDBaseMessage` object. It's `nil` when the `mode` is `none`.
    func baseChannelModule(
        _ inputComponent: SBUBaseChannelModule.Input,
        didChangeMode mode: SBUMessageInputMode,
        message: SBDBaseMessage?
    )
    
    /// Called when the frozen state has been updated.
    /// - Parameters:
    ///    - inputComponent: `SBUBaseChannelModule.Input` object.
    ///    - isFrozen: Whether the channel and `messageInputView` is frozen or not.
    func baseChannelModule(
        _ inputComponent: SBUBaseChannelModule.Input,
        didUpdateFrozenState isFrozen: Bool
    )
}

/// Methods to get data source for the input component.
public protocol SBUBaseChannelModuleInputDataSource: AnyObject {
    /// Ask the data source to return the `SBDBaseChannel` object.
    /// - Parameters:
    ///    - inputComponent: `SBUBaseChannelModule.Input` object.
    ///    - messageInputView: `UIView` object representing `messageInputView` from input component.
    /// - Returns: `SBDBaseChannel` object.
    func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, channelForInputView messageInputView: UIView?) -> SBDBaseChannel?
}

extension SBUBaseChannelModule {
    /// The `SBUBaseChannelModule`'s component class that represents input
    @objcMembers open class Input: UIView, SBUMessageInputViewDelegate {
        
        /// The input view to send/edit a message. The default value is `SBUMessageInputView` object.
        public var messageInputView: UIView?

        /// The object that is used as the theme of the input component. The theme must adopt the `SBUChannelTheme` class.
        public var theme: SBUChannelTheme? = nil
        
        /// The object that acts as the base delegate of the input component. The base delegate must adopt the `SBUBaseChannelModuleInputDelegate`.
        public weak var baseDelegate: SBUBaseChannelModuleInputDelegate?
        
        /// The object that acts as the base data source of the input component. The base data source must adopt the `SBUBaseChannelModuleInputDataSource`.
        public weak var baseDataSource: SBUBaseChannelModuleInputDataSource?
        
        private lazy var defaultMessageInputView: SBUMessageInputView = {
            let messageInputView = SBUMessageInputView()
            messageInputView.delegate = self
            return messageInputView
        }()
        
        // MARK: - Logic properties (Public)
        /// (Read only) The channel object.
        /// - NOTE: See `baseChannelModule(_:channelForInputView:)`, a data source function.
        public var baseChannel: SBDBaseChannel? {
            self.baseDataSource?.baseChannelModule(self, channelForInputView: self.messageInputView)
        }
        
        @available(*, unavailable, renamed: "SBUBaseChannelModule.Input()")
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        @available(*, unavailable, renamed: "SBUBaseChannelModule.Input()")
        public override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        /// Set values of the views in the input component when it needs.
        open func setupViews() {
            if self.messageInputView == nil {
                self.messageInputView = defaultMessageInputView
            }
            if let messageInputView = messageInputView {
                self.addSubview(messageInputView)
            }
        }
        
        /// Sets layouts of the views in the input component.
        open func setupLayouts() {
            self.messageInputView?
                .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        }
        
        /// Sets up style with theme. If set theme parameter is nil value, using the stored theme.
        /// - Parameter theme: `SBUChannelTheme` object
        open func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
        }
        
        /// Updates mode of `messageInputView`.
        /// - Parameters:
        ///   - mode: `SBUMessageInputMode` value.
        ///   - message: `SBDBaseMessage` value for some specific modes such as `.edit` or `.quoteReply`
        open func updateMessageInputMode(_ mode: SBUMessageInputMode, message: SBDBaseMessage? = nil) {
            if let messageInputView = self.messageInputView as? SBUMessageInputView {
                messageInputView.setMode(mode, message: message)
            }
        }
        
        /// Updates state of `messageInputView`.
        /// - IMPORTANT: The implemetation is required. Please refer to same method in  `SBUGroupChannelModule.Input`
        open func updateMessageInputModeState() { }
        
        /// Updates frozen mode of `messageInputView`.
        /// - IMPORTANT: The implemetation is required. Please refer to same method in  `SBUGroupChannelModule.Input`
        open func updateFrozenModeState() { }
        
        // Suggest: Managing class 가 있으면 좋을 듯!
        
        ///  Call this function when an image file has been picked from `UIImagePickerController`. This function will invoke corresponding delegate method such as `SBUGroupChannelModuleInputDelegate groupChannelModule(_:didPickFileData:fileName:mimeType:parentMessage:)`
        /// - Parameter info: Image information selected in `UIImagePickerController`
        open func pickImageFile(info: [UIImagePickerController.InfoKey : Any]) {
            
        }
        
        ///  Call this function when a video file has been picked from `UIImagePickerController`. This function will invoke corresponding delegate method such as `SBUGroupChannelModuleInputDelegate groupChannelModule(_:didPickFileData:fileName:mimeType:parentMessage:)`
        /// - Parameter info: Video information selected in `UIImagePickerController`
        open func pickVideoFile(info: [UIImagePickerController.InfoKey : Any]) {
            
        }
        
        /// Call this function when a picked `itemProvider` of `PHPickerResult` has `UTType.image` identifier.
        /// This function will invoke corresponding delegate method such as `SBUGroupChannelModuleInputDelegate groupChannelModule(_:didPickFileData:fileName:mimeType:parentMessage:)`
        /// - Parameter itemProvider: `NSItemProvider` object from `PHPickerResult`.
        @available(iOS 14.0, *)
        open func pickImageFile(itemProvider: NSItemProvider) {
            
        }
        
        /// Call this function when a picked `itemProvider` of `PHPickerResult` has `UTType.gif` identifier.
        /// This function will invoke corresponding delegate method such as `SBUGroupChannelModuleInputDelegate groupChannelModule(_:didPickFileData:fileName:mimeType:parentMessage:)`
        /// - Parameter itemProvider: `NSItemProvider` object from `PHPickerResult`.
        @available(iOS 14.0, *)
        open func pickGIFFile(itemProvider: NSItemProvider) {
            
        }
        
        /// Call this function when a picked `itemProvider` of `PHPickerResult` has `UTType.video` identifier.
        /// This function will invoke corresponding delegate method such as `SBUGroupChannelModuleInputDelegate groupChannelModule(_:didPickFileData:fileName:mimeType:parentMessage:)`
        /// - Parameter itemProvider: `NSItemProvider` object from `PHPickerResult`.
        @available(iOS 14.0, *)
        open func pickVideoFile(itemProvider: NSItemProvider) {
            
        }
        
        /// Called when the image is picked from `SBUSelectablePhotoViewController`
        /// This function will invoke corresponding delegate method such as `SBUGroupChannelModuleInputDelegate groupChannelModule(_:didPickFileData:fileName:mimeType:parentMessage:)`
        /// - Parameter data: The image data.
        open func pickImageData(_ data: Data) {
            
        }
        
        /// Called when the video is picked from `SBUSelectablePhotoViewController`
        /// This function will invoke corresponding delegate method such as `SBUGroupChannelModuleInputDelegate groupChannelModule(_:didPickFileData:fileName:mimeType:parentMessage:)`
        /// - Parameter url: The URL of the video
        open func pickVideoURL(_ url: URL) {
            
        }
        
        ///  Call this function when a video file has been picked from `UIDocumentPickerViewController`. This function will invoke corresponding delegate method such as `SBUGroupChannelModuleInputDelegate groupChannelModule(_:didPickFileData:fileName:mimeType:parentMessage:)`
        /// - Parameter documentUrls: Document information selected in `UIDocumentPickerViewController`
        open func pickDocumentFile(documentUrls: [URL]) {
            
        }
        
        // MARK: - SBUMessageInputViewDelegate
        public func messageInputViewDidStartTyping() {
            self.baseDelegate?.baseChannelModuleDidStartTyping(self)
        }
        
        public func messageInputViewDidEndTyping() {
            self.baseDelegate?.baseChannelModuleDidEndTyping(self)
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String) {
            guard text.count > 0 else { return }
            
            var parentMessage: SBDBaseMessage?
            switch messageInputView.option {
                case .quoteReply(let message):
                    parentMessage = message
                default:
                    break
            }
            messageInputView.setMode(.none)
            
            self.baseDelegate?.baseChannelModule(self, didTapSend: text, parentMessage: parentMessage)
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, didSelectResource type: MediaResourceType) {
            self.baseDelegate?.baseChannelModule(self, didTapResource: type)
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String) {
            self.baseDelegate?.baseChannelModule(self, didTapEdit: text)
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, didChangeText text: String) {
            self.baseDelegate?.baseChannelModule(self, didChangeText: text)
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, willChangeMode mode: SBUMessageInputMode, message: SBDBaseMessage?) {
            self.baseDelegate?.baseChannelModule(self, willChangeMode: mode, message: message)
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, didChangeMode mode: SBUMessageInputMode, message: SBDBaseMessage?) {
            self.baseDelegate?.baseChannelModule(self, didChangeMode: mode, message: message)
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            // TODO: Mention tap action
            return true
        }
        
        public func messageInputView(_ messageInputView: SBUMessageInputView, didChangeSelection range: NSRange) { }
    }
}
