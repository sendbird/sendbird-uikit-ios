//
//  SBUOpenChannelModule.Input.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/17.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import PhotosUI
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the input component in the open channel.
public protocol SBUOpenChannelModuleInputDelegate: SBUBaseChannelModuleInputDelegate {
    func openChannelModule(
        _ inputComponent: SBUOpenChannelModule.Input,
        didPickFileData fileData: Data?,
        fileName: String,
        mimeType: String
    )
}

/// Methods to get data source for the input component in the open channel.
public protocol SBUOpenChannelModuleInputDataSource: SBUBaseChannelModuleInputDataSource { }

extension SBUOpenChannelModule {
    /// The `SBUOpenChannelModule`'s component class that represents input.
    @objcMembers open class Input: SBUBaseChannelModule.Input {
        
        /// The open channel object casted from `baseChannel`.
        public var channel: OpenChannel? {
            self.baseChannel as? OpenChannel
        }
        
        /// The object that acts as the delegate of the input component. The delegate must adopt the `SBUOpenChannelModuleInputDelegate`.
        public weak var delegate: SBUOpenChannelModuleInputDelegate? {
            get { self.baseDelegate as? SBUOpenChannelModuleInputDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the data source of the input component. The data source must adopt the `SBUOpenChannelModuleInputDataSource`.
        public weak var dataSource: SBUOpenChannelModuleInputDataSource? {
            get { self.baseDataSource as? SBUOpenChannelModuleInputDataSource }
            set { self.baseDataSource = newValue }
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUOpenChannelModuleInputDataSource`
        ///   - theme: `SBUChannelTheme` object
        open func configure(delegate: SBUOpenChannelModuleInputDelegate, dataSource: SBUOpenChannelModuleInputDataSource, theme: SBUChannelTheme) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            setupViews()
            setupLayouts()
            setupStyles()
            
            if let messageInputView = self.messageInputView as? SBUMessageInputView {
                messageInputView.voiceMessageButton?.isHidden = true
                messageInputView.textViewTrailingPaddingView.isHidden = true
                messageInputView.showsVoiceMessageButton = false
            }
        }
        
        /// Updates styles with overlaying state.
        /// - Parameter overlaid: The boolean value whether the input component is overlaid or not. The default value is `false`.
        open func updateStyles(overlaid: Bool = false) {
            if let messageInputView = self.messageInputView as? SBUMessageInputView {
                messageInputView.isOverlay = overlaid
                messageInputView.setupStyles()
                
                if let text = messageInputView.textView?.text {
                    messageInputView.textView?.text = text
                    messageInputView.basedText = text
                }
            }
            
            self.setupStyles(theme: nil)
        }
        
        open override func pickImageFile(info: [UIImagePickerController.InfoKey: Any]) {
            var tempImageURL: URL?
            if let imageURL = info[.imageURL] as? URL {
                // file:///~~~
                tempImageURL = imageURL
            }
            
            guard let imageURL = tempImageURL else {
                let originalImage = info[.originalImage] as? UIImage
                // for Camera capture
                guard let image = originalImage?.fixedOrientation(),
                      let imageData = image.sbu_convertToData() else { return }
                
                self.delegate?.openChannelModule(
                    self,
                    didPickFileData: imageData,
                    fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                    mimeType: "image/jpeg"
                )
                return
            }
            
            let imageName = imageURL.lastPathComponent
            guard let mimeType = SBUUtils.getMimeType(url: imageURL) else {
                SBULog.error("Failed to get mimeType")
                return
            }
            
            switch mimeType {
                case "image/gif":
                    let gifData = try? Data(contentsOf: imageURL)
                    
                    self.delegate?.openChannelModule(
                        self,
                        didPickFileData: gifData,
                        fileName: imageName,
                        mimeType: mimeType
                    )
                    
                default:
                    let originalImage = info[.originalImage] as? UIImage
                    guard let image = originalImage?.fixedOrientation(),
                          let imageData = image.sbu_convertToData() else { return }
                    
                    self.delegate?.openChannelModule(
                        self,
                        didPickFileData: imageData,
                        fileName: imageName,
                        mimeType: mimeType
                    )
            }
        }
        
        open override func pickVideoFile(info: [UIImagePickerController.InfoKey: Any]) {
            do {
                guard let videoURL = info[.mediaURL] as? URL else { return }
                let videoFileData = try Data(contentsOf: videoURL)
                let videoName = videoURL.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: videoURL) else { return }
                
                self.delegate?.openChannelModule(
                    self,
                    didPickFileData: videoFileData,
                    fileName: videoName,
                    mimeType: mimeType
                )
            } catch {
                let sbError = SBError(domain: (error as NSError).domain, code: (error as NSError).code)
                self.delegate?.didReceiveError(sbError, isBlocker: false)
            }
        }
        
        @available(iOS 14.0, *)
        open override func pickImageFile(itemProvider: NSItemProvider) {
            itemProvider.loadItem(forTypeIdentifier: UTType.image.identifier, options: [:]) { [weak self] url, _ in
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { imageItem, _ in
                        guard let self = self else { return }
                        guard let originalImage = imageItem as? UIImage else { return }
                        guard let imageURL = url as? URL else { return }
                        guard let mimeType = SBUUtils.getMimeType(url: imageURL) else { return }
                        
                        guard let imageData = originalImage
                            .fixedOrientation()
                            .sbu_convertToData() else { return }
                        
                        let fileExtension = imageURL.pathExtension
                        let fileName = "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).\(fileExtension)"
                        
                        DispatchQueue.main.async { [self, imageData, mimeType, fileName] in
                            self.delegate?.openChannelModule(
                                self,
                                didPickFileData: imageData,
                                fileName: fileName,
                                mimeType: mimeType
                            )
                        }
                    }
                }
            }
        }
        
        @available(iOS 14.0, *)
        open override func pickGIFFile(itemProvider: NSItemProvider) {
            itemProvider.loadItem(forTypeIdentifier: UTType.gif.identifier, options: [:]) { [weak self] url, _ in
                guard let self = self else { return }
                guard let imageURL = url as? URL else { return }
                guard let mimeType = SBUUtils.getMimeType(url: imageURL) else { return }
                
                let gifData = try? Data(contentsOf: imageURL)
                let fileExtension = imageURL.pathExtension
                let fileName = "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).\(fileExtension)"
                
                DispatchQueue.main.async { [self, gifData, mimeType, fileName] in
                    self.delegate?.openChannelModule(
                        self,
                        didPickFileData: gifData,
                        fileName: fileName,
                        mimeType: mimeType
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
                    
                    DispatchQueue.main.async { [self, videoFileData, videoName, mimeType] in
                        self.delegate?.openChannelModule(
                            self,
                            didPickFileData: videoFileData,
                            fileName: videoName,
                            mimeType: mimeType
                        )
                    }
                } catch {
                    SBULog.error(error.localizedDescription)
                }
            }
        }
        
        open override func pickDocumentFile(documentURLs: [URL]) {
            do {
                guard let documentURL = documentURLs.first else { return }
                let documentData = try Data(contentsOf: documentURL)
                let documentName = documentURL.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: documentURL) else { return }
                
                self.delegate?.openChannelModule(
                    self,
                    didPickFileData: documentData,
                    fileName: documentName,
                    mimeType: mimeType
                )
            } catch {
                SBULog.error(error.localizedDescription)
                let sbError = SBError(domain: (error as NSError).domain, code: (error as NSError).code)
                self.delegate?.didReceiveError(sbError, isBlocker: false)
            }
        }
        
        open override func pickImageData(_ data: Data, fileName: String? = nil, mimeType: String? = nil) {
            let tempFileName = "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg"
            
            self.delegate?.openChannelModule(
                self,
                didPickFileData: data,
                fileName: fileName ?? tempFileName,
                mimeType: mimeType ?? "image/jpeg"
            )
        }
        
        open override func pickVideoURL(_ url: URL) {
            do {
                let videoFileData = try Data(contentsOf: url)
                let videoName = url.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: url) else { return }
                
                self.delegate?.openChannelModule(
                    self,
                    didPickFileData: videoFileData,
                    fileName: videoName,
                    mimeType: mimeType
                )
            } catch {
                SBULog.error(error.localizedDescription)
                let sbError = SBError(domain: (error as NSError).domain, code: (error as NSError).code)
                self.delegate?.didReceiveError(sbError, isBlocker: false)
            }
        }
        
        /// Updates state of `messageInputView`.
        open override func updateMessageInputModeState() {
            if self.channel != nil {
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
            guard let userId = SBUGlobals.currentUser?.userId else { return }
            let isOperator = self.channel?.isOperator(userId: userId) ?? false
            let isFrozen = self.channel?.isFrozen ?? false
            if let messageInputView = self.messageInputView as? SBUMessageInputView {
                messageInputView.setFrozenModeState(!isOperator && isFrozen)
            }
            self.delegate?.baseChannelModule(self, didUpdateFrozenState: isFrozen)
        }
        
        /// Updates the mode of `messageInputView` according to frozen and muted state of the channel.
        open func updateMutedModeState() {
            guard let userId = SBUGlobals.currentUser?.userId else { return }
            let isOperator = self.channel?.isOperator(userId: userId) ?? false
            let isFrozen = self.channel?.isFrozen ?? false
            self.channel?.getMyMutedInfo(completionHandler: {
                [weak self] isMuted, _, _, _, _, _ in
                guard let self = self else { return }
                if !isFrozen || (isFrozen && isOperator) {
                    if let messageInputView = self.messageInputView as? SBUMessageInputView {
                        messageInputView.setMutedModeState(isMuted)
                    }
                }
            })
        }
    }
}
