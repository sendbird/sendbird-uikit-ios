//
//  SBUOpenChannelModule.Input.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/17.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import PhotosUI
import SendBirdSDK


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
        public var channel: SBDOpenChannel? {
            self.baseChannel as? SBDOpenChannel
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
        }
        
        /// Updates styles with overlaying state.
        /// - Parameter overlaid: The boolean value whether the input component is overlaid or not. The default value is `false`.
        open func updateStyles(overlaid: Bool = false) {
            if let messageInputView = self.messageInputView as? SBUMessageInputView {
                messageInputView.isOverlay = overlaid
                messageInputView.setupStyles()
            }
            
            self.setupStyles(theme: nil)
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
                
                self.delegate?.openChannelModule(
                    self,
                    didPickFileData: imageData,
                    fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                    mimeType: "image/jpeg"
                )
                return
            }
            
            let imageName = imageUrl.lastPathComponent
            guard let mimeType = SBUUtils.getMimeType(url: imageUrl) else { return }
            
            switch mimeType {
                case "image/gif":
                    let gifData = try? Data(contentsOf: imageUrl)
                    
                    self.delegate?.openChannelModule(
                        self,
                        didPickFileData: gifData,
                        fileName: imageName,
                        mimeType: mimeType
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
                    
                    self.delegate?.openChannelModule(
                        self,
                        didPickFileData: imageData,
                        fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                        mimeType: "image/jpeg"
                    )
            }
        }
        
        open override func pickVideoFile(info: [UIImagePickerController.InfoKey : Any]) {
            do {
                guard let videoUrl = info[.mediaURL] as? URL else { return }
                let videoFileData = try Data(contentsOf: videoUrl)
                let videoName = videoUrl.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: videoUrl) else { return }
                
                self.delegate?.openChannelModule(
                    self,
                    didPickFileData: videoFileData,
                    fileName: videoName,
                    mimeType: mimeType
                )
            } catch {
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
                        
                        DispatchQueue.main.async { [self, imageData] in
                            self.delegate?.openChannelModule(
                                self,
                                didPickFileData: imageData,
                                fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                                mimeType: "image/jpeg"
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
                
                DispatchQueue.main.async { [self, gifData, imageName] in
                    self.delegate?.openChannelModule(
                        self,
                        didPickFileData: gifData,
                        fileName: imageName,
                        mimeType: "image/gif"
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
        
        open override func pickDocumentFile(documentUrls: [URL]) {
            do {
                guard let documentUrl = documentUrls.first else { return }
                let documentData = try Data(contentsOf: documentUrl)
                let documentName = documentUrl.lastPathComponent
                guard let mimeType = SBUUtils.getMimeType(url: documentUrl) else { return }
                
                self.delegate?.openChannelModule(
                    self,
                    didPickFileData: documentData,
                    fileName: documentName,
                    mimeType: mimeType
                )
            } catch {
                SBULog.error(error.localizedDescription)
                self.delegate?.didReceiveError(SBDError(nsError: error), isBlocker: false)
            }
        }
        
        open override func pickImageData(_ data: Data) {
            self.delegate?.openChannelModule(
                self,
                didPickFileData: data,
                fileName: "\(Date().sbu_toString(dateFormat: SBUDateFormatSet.Message.fileNameFormat, localizedFormat: false)).jpg",
                mimeType: "image/jpeg"
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
                self.delegate?.didReceiveError(SBDError(nsError: error), isBlocker: false)
            }
        }
        
        /// Updates state of `messageInputView`.
        open override func updateMessageInputModeState() {
            if self.channel != nil {
                self.updateFrozenModeState()
            } else {
                if let messageInputView = self.messageInputView as? SBUMessageInputView {
                    messageInputView.setErrorState()
                }
            }
        }
        
        /// This is used to update frozen mode of `messageInputView`. This will call `SBUBaseChannelModuleInputDelegate baseChannelModule(_:didUpdateFrozenState:)`
        open override func updateFrozenModeState() {
            guard let userId = SBUGlobals.currentUser?.userId else { return }
            let isOperator = self.channel?.isOperator(withUserId: userId) ?? false
            let isFrozen = self.channel?.isFrozen ?? false
            if let messageInputView = self.messageInputView as? SBUMessageInputView {
                messageInputView.setFrozenModeState(!isOperator && isFrozen)
            }
            self.delegate?.baseChannelModule(self, didUpdateFrozenState: isFrozen)
        }
    }
}
