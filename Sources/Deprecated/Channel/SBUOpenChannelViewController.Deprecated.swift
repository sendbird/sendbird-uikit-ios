//
//  SBUOpenChannelViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/18.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUOpenChannelViewController {
    // MARK: 3.0.0
    @available(*, deprecated, message: "This property has been moved to `SBUOpenChannelModule.Header`.", renamed: "headerComponent.channelInfoView")
    public var channelInfoView: SBUChannelInfoHeaderView {
        get { self.headerComponent?.channelInfoView as? SBUChannelInfoHeaderView ?? SBUChannelInfoHeaderView(delegate: nil) }
        set { self.headerComponent?.channelInfoView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.adminMessageCell")
    public var adminMessageCell: SBUOpenChannelBaseMessageCell? {
        self.listComponent?.adminMessageCell
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.userMessageCell")
    public var userMessageCell: SBUOpenChannelBaseMessageCell? {
        self.listComponent?.userMessageCell
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.fileMessageCell")
    public var fileMessageCell: SBUOpenChannelBaseMessageCell? {
        self.listComponent?.fileMessageCell
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.customMessageCell")
    public var customMessageCell: SBUOpenChannelBaseMessageCell? {
        self.listComponent?.customMessageCell
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.unknownMessageCell")
    public var unknownMessageCell: SBUOpenChannelBaseMessageCell? {
        self.listComponent?.unknownMessageCell
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.register(adminMessageCell:nib:)")
    public func register(adminMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
        self.listComponent?.register(adminMessageCell: adminMessageCell, nib: nib)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.register(userMessageCell:nib:)")
    public func register(userMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
        self.listComponent?.register(userMessageCell: userMessageCell, nib: nib)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.register(fileMessageCell:nib:)")
    public func register(fileMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
        self.listComponent?.register(fileMessageCell: fileMessageCell, nib: nib)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.register(customMessageCell:nib:)")
    public func register(customMessageCell: SBUOpenChannelBaseMessageCell?, nib: UINib? = nil) {
        guard let customMessageCell = customMessageCell else { return }
        self.listComponent?.register(customMessageCell: customMessageCell, nib: nib)
    }

    @available(*, deprecated, message: "This function has been moved to `SBUOpenChannelModule.List`.", renamed: "listComponent.generateCellIdentifier(by:)")
    open func generateCellIdentifier(by message: BaseMessage) -> String {
        self.listComponent?.generateCellIdentifier(by: message) ?? "\(type(of: message))Cell"
        
    }
    
    // MARK: - Message: Gestures
    
    // MARK: - Media
    
    /// The internal view provided for media such as photo or video. If you want to use `mediaView`, please call `enableMediaView(_:)` to enable and set its ratio through `updateMessageListRatio(to ratio:)`. If you want to overlay, use `overlayMediaView(_:messageListRatio:)` method.
    @available(*, deprecated, message: "This property has been moved to `SBUOpenChannelModule.Media`.", renamed: "mediaComponent.mediaView")
    public var mediaView: UIView {
        get { self.mediaComponent?.mediaView ?? UIView() }
        set { self.mediaComponent?.mediaView = newValue }
    }
}
