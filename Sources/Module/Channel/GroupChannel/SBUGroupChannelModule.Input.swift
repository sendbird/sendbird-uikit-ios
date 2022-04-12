//
//  SBUGroupChannelModule.Input.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/16.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import PhotosUI
import SendBirdSDK


/// Event methods for the views updates and performing actions from the input component in the group channel.
public protocol SBUGroupChannelModuleInputDelegate: SBUBaseChannelModuleInputDelegate {
    func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        didPickFileData fileData: Data?,
        fileName: String,
        mimeType: String,
        parentMessage: SBDBaseMessage?
    )
}

/// Methods to get data source for the input component in the group channel.
public protocol SBUGroupChannelModuleInputDataSource: SBUBaseChannelModuleInputDataSource {
    
}

extension SBUGroupChannelModule {
    /// The `SBUGroupChannelModule`'s component class that represents input
    @objcMembers open class Input: SBUBaseChannelModule.Input {
        /// A current quoted message in message input view. This value is only available when the `messageInputView` is type of `SBUMessageInputView` that supports the message replying feature.
        public var currentQuotedMessage: SBDBaseMessage? {
            guard let messageInputView = messageInputView as? SBUMessageInputView else { return nil }
            var parentMessage: SBDBaseMessage? = nil
            switch messageInputView.option {
                case .quoteReply(let message):
                    parentMessage = message
                default: break
            }
            messageInputView.setMode(.none)
            return parentMessage
        }
        
        /// The group channel object casted from `baseChannel`.
        public var channel: SBDGroupChannel? {
            self.baseChannel as? SBDGroupChannel
        }
        
        /// The object that acts as the delegate of the input component. The delegate must adopt the `SBUGroupChannelModuleInputDelegate`.
        public weak var delegate: SBUGroupChannelModuleInputDelegate? {
            get { self.baseDelegate as? SBUGroupChannelModuleInputDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the data source of the input component. The data source must adopt the `SBUGroupChannelModuleInputDataSource`.
        public weak var dataSource: SBUGroupChannelModuleInputDataSource? {
            get { self.baseDataSource as? SBUGroupChannelModuleInputDataSource }
            set { self.baseDataSource = newValue }
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUGroupChannelModuleInputDataSource`
        ///   - theme: `SBUChannelTheme` object
        open func configure(
            delegate: SBUGroupChannelModuleInputDelegate,
            dataSource: SBUGroupChannelModuleInputDataSource,
            theme: SBUChannelTheme
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        open override func setupViews() {
            super.setupViews()
        }
        
        open override func setupLayouts() {
            super.setupLayouts()
            
            self.messageInputView?
                .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        }
        
        open override func pickImageFile(info: [UIImagePickerController.InfoKey : Any]) {
            var tempImageUrl: URL? = nil
            if let imageUrl = info[.imageURL] as? URL {
                // file:///~~~
                tempImageUrl = imageUrl
            }
            
            guard let imageUrl = tempImageUrl else {
                let originalImage = info[.originalImage] as? UIImage
                // for Camera capture
                guard let image = originalImage?
                        .fixedOrientation()
                        .resize(with: SBUGlobals.imageResizingSize) else { return }
                
                let imageData = image.jpegData(
                    compressionQuality: SBUGlobals.isImageCompressionEnabled ?
                    SBUGlobals.imageCompressionRate : 1.0
                )
                
                let parentMessage = self.currentQuotedMessage
                
                self.delegate?.groupChannelModule(
                    self,
                    didPickFileData: imageData,
                    fileName: "\(Date().sbu_toString(format: .yyyyMMddhhmmss, localizedFormat: false)).jpg",
                    mimeType: "image/jpeg",
                    parentMessage: parentMessage
                )
                return
            }
            
            let imageName = imageUrl.lastPathComponent
            guard let mimeType = SBUUtils.getMimeType(url: imageUrl) else {
                SBULog.error("Failed to get mimeType from `SBUUtils.getMimeType(url:)`")
                return
            }
            
            switch mimeType {
                case "image/gif":
                    let gifData = try? Data(contentsOf: imageUrl)
                    
                    let parentMessage = self.currentQuotedMessage
                    
                    self.delegate?.groupChannelModule(
                        self,
                        didPickFileData: gifData,
                        fileName: imageName,
                        mimeType: mimeType,
                        parentMessage: parentMessage
                    )
                default:
                    let originalImage = info[.originalImage] as? UIImage
                    guard let image = originalImage?
                            .fixedOrientation()
                            .resize(with: SBUGlobals.imageResizingSize) else { return }
                    
                    let imageData = image.jpegData(
                        compressionQuality: SBUGlobals.isImageCompressionEnabled ?
                        SBUGlobals.imageCompressionRate : 1.0
                    )
                    
                    let parentMessage = self.currentQuotedMessage
                    self.delegate?.groupChannelModule(
                        self,
                        didPickFileData: imageData,
                        fileName: "\(Date().sbu_toString(format: .yyyyMMddhhmmss, localizedFormat: false)).jpg",
                        mimeType: "image/jpeg",
                        parentMessage: parentMessage
                    )
            }
        }
        
        open override func pickVideoFile(info: [UIImagePickerController.InfoKey : Any]) {
            do {
                guard let videoUrl = info[.mediaURL] as? URL else { return }
                let videoFileData = try Data(contentsOf: videoUrl)
                let videoName = videoUrl.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: videoUrl) else { return }
                
                let parentMessage = self.currentQuotedMessage
                
                self.delegate?.groupChannelModule(
                    self,
                    didPickFileData: videoFileData,
                    fileName: videoName,
                    mimeType: mimeType,
                    parentMessage: parentMessage
                )
            } catch {
                SBULog.error(error.localizedDescription)
                self.delegate?.didReceiveError(SBDError(nsError: error), isBlocker: false)
            }
        }
        
        @available(iOS 14.0, *)
        open override func pickImageFile(itemProvider: NSItemProvider) {
            itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: [:]) { url, error in
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { [weak self] imageItem, error in
                        guard let self = self else { return }
                        guard let originalImage = imageItem as? UIImage else { return }
                        let image = originalImage
                            .fixedOrientation()
                            .resize(with: SBUGlobals.imageResizingSize)
                        let imageData = image.jpegData(
                            compressionQuality: SBUGlobals.isImageCompressionEnabled
                            ? SBUGlobals.imageCompressionRate
                            : 1.0
                        )
                        
                        let parentMessage = self.currentQuotedMessage
                        
                        DispatchQueue.main.async { [self, imageData, parentMessage] in
                            self.delegate?.groupChannelModule(
                                self,
                                didPickFileData: imageData,
                                fileName: "\(Date().sbu_toString(format: .yyyyMMddhhmmss, localizedFormat: false)).jpg",
                                mimeType: "image/jpeg",
                                parentMessage: parentMessage
                            )
                        }
                    }
                }
            }
        }
        
        @available(iOS 14.0, *)
        open override func pickGIFFile(itemProvider: NSItemProvider) {
            itemProvider.loadItem(forTypeIdentifier: UTType.gif.identifier, options: [:]) { [weak self] url, error in
                guard let imageURL = url as? URL else { return }
                guard let self = self else { return }
                let imageName = imageURL.lastPathComponent
                let gifData = try? Data(contentsOf: imageURL)
                
                let parentMessage = self.currentQuotedMessage
                
                DispatchQueue.main.async { [self, gifData, parentMessage] in
                    self.delegate?.groupChannelModule(
                        self,
                        didPickFileData: gifData,
                        fileName: imageName,
                        mimeType: "image/gif",
                        parentMessage: parentMessage
                    )
                }
            }
        }
        
        @available(iOS 14.0, *)
        open override func pickVideoFile(itemProvider: NSItemProvider) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
                guard let videoURL = url else { return }
                guard let self = self else { return }
                do {
                    let videoFileData = try Data(contentsOf: videoURL)
                    let videoName = videoURL.lastPathComponent
                    guard let mimeType = SBUUtils.getMimeType(url: videoURL) else { return }
                    
                    let parentMessage = self.currentQuotedMessage
                    
                    DispatchQueue.main.async { [self, videoFileData, videoName, mimeType, parentMessage] in
                        self.delegate?.groupChannelModule(
                            self,
                            didPickFileData: videoFileData,
                            fileName: videoName,
                            mimeType: mimeType,
                            parentMessage: parentMessage
                        )
                    }
                } catch {
                    SBULog.error(error.localizedDescription)
                }
            }
        }
        
        open override func pickDocumentFile(documentUrls: [URL]) {
            do {
                guard let documentUrl = documentUrls.first else { return }
                let documentData = try Data(contentsOf: documentUrl)
                let documentName = documentUrl.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: documentUrl) else { return }
                
                let parentMessage = self.currentQuotedMessage
                
                self.delegate?.groupChannelModule(
                    self,
                    didPickFileData: documentData,
                    fileName: documentName,
                    mimeType: mimeType,
                    parentMessage: parentMessage
                )
            } catch {
                SBULog.error(error.localizedDescription)
                self.delegate?.didReceiveError(SBDError(nsError: error), isBlocker: false)
            }
        }
        
        open override func pickImageData(_ data: Data) {
            let parentMessage = self.currentQuotedMessage
            
            self.delegate?.groupChannelModule(
                self,
                didPickFileData: data,
                fileName: "\(Date().sbu_toString(format: .yyyyMMddhhmmss, localizedFormat: false)).jpg",
                mimeType: "image/jpeg",
                parentMessage: parentMessage
            )
        }
        
        open override func pickVideoURL(_ url: URL) {
            do {
                let videoFileData = try Data(contentsOf: url)
                let videoName = url.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: url) else { return }
                
                let parentMessage = self.currentQuotedMessage
                
                self.delegate?.groupChannelModule(
                    self,
                    didPickFileData: videoFileData,
                    fileName: videoName,
                    mimeType: mimeType,
                    parentMessage: parentMessage
                )
            } catch {
                SBULog.error(error.localizedDescription)
                self.delegate?.didReceiveError(SBDError(nsError: error), isBlocker: false)
            }
        }
        
        /// Updates state of `messageInputView`.
        open override func updateMessageInputModeState() {
            if channel != nil {
                self.updateBroadcastModeState()
                self.updateFrozenModeState()
                self.updateMutedModeState()
            } else {
                if let messageInputView = self.messageInputView as? SBUMessageInputView {
                    messageInputView.setErrorState()
                }
            }
        }
        
        /// This is used to update frozen mode of `messageInputView`. This will call `SBUBaseChannelModuleInputDelegate baseChannelModule(_:didUpdateFrozenState:)`
        open override func updateFrozenModeState() {
            let isOperator = self.channel?.myRole == .operator
            let isBroadcast = self.channel?.isBroadcast ?? false
            let isFrozen = self.channel?.isFrozen ?? false
            if !isBroadcast {
                if let messageInputView = self.messageInputView as? SBUMessageInputView {
                    messageInputView.setFrozenModeState(!isOperator && isFrozen)
                }
            }
            self.delegate?.baseChannelModule(self, didUpdateFrozenState: isFrozen)
        }
        
        /// Updates the mode of `messageInputView` according to broadcast state of the channel.
        open func updateBroadcastModeState() {
            let isOperator = self.channel?.myRole == .operator
            let isBroadcast = self.channel?.isBroadcast ?? false
            self.messageInputView?.isHidden = !isOperator && isBroadcast
        }
        
        /// Updates the mode of `messageInputView` according to frozen and muted state of the channel.
        open func updateMutedModeState() {
            let isOperator = self.channel?.myRole == .operator
            let isFrozen = self.channel?.isFrozen ?? false
            let isMuted = self.channel?.myMutedState == .muted
            if !isFrozen || (isFrozen && isOperator) {
                if let messageInputView = self.messageInputView as? SBUMessageInputView {
                    messageInputView.setMutedModeState(isMuted)
                }
            }
        }
    }
}
