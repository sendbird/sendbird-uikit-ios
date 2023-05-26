//
//  SBUGroupChannelViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/17.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@available(*, deprecated, renamed: "SBUGroupChannelViewController") // 3.0.0
public typealias SBUChannelViewController = SBUGroupChannelViewController

@available(*, deprecated, renamed: "SBUGroupChannelViewModelDataSource") // 3.0.0
public typealias SBUChannelViewModelDataSource = SBUGroupChannelViewModelDataSource

@available(*, deprecated, renamed: "SBUGroupChannelViewModelDelegate") // 3.0.0
public typealias SBUChannelViewModelDelegate = SBUGroupChannelViewModelDelegate

@available(*, deprecated, renamed: "SBUGroupChannelViewModel") // 3.0.0
public typealias SBUChannelViewModel = SBUGroupChannelViewModel

extension SBUGroupChannelViewController {
    @available(*, deprecated, message: "This property has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.adminMessageCell")
    public var adminMessageCell: SBUBaseMessageCell? {
        self.listComponent?.adminMessageCell
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.userMessageCell")
    public var userMessageCell: SBUBaseMessageCell? {
        self.listComponent?.userMessageCell
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.fileMessageCell")
    public var fileMessageCell: SBUBaseMessageCell? {
        self.listComponent?.fileMessageCell
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.customMessageCell")
    public var customMessageCell: SBUBaseMessageCell? {
        self.listComponent?.customMessageCell
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.unknownMessageCell")
    public var unknownMessageCell: SBUBaseMessageCell? {
        self.listComponent?.unknownMessageCell
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.register(adminMessageCell:nib:)")
    public func register(adminMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.listComponent?.register(adminMessageCell: adminMessageCell, nib: nib)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.register(userMessageCell:nib:)")
    public func register(userMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.listComponent?.register(userMessageCell: userMessageCell, nib: nib)
    }
    
    @available(*, deprecated, message: "Use `This function has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.register(fileMessageCell:nib:)")
    public func register(fileMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.listComponent?.register(fileMessageCell: fileMessageCell, nib: nib)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModule.List`", renamed: "listComponent.register(customMessageCell:nib:)")
    public func register(customMessageCell: SBUBaseMessageCell?, nib: UINib? = nil) {
        guard let customMessageCell = customMessageCell else { return }
        self.listComponent?.register(customMessageCell: customMessageCell, nib: nib)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModule.List`.", renamed: "listComponent.generateCellIdentifier(by:)")
    open func generateCellIdentifier(by message: BaseMessage) -> String {
        self.listComponent?.generateCellIdentifier(by: message) ?? "\(type(of: message))Cell"
        
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModuleListDelegate`. Use `channelModule(_:didTapEmoji:messageCell:)` of `SBUGroupChannelModuleListDelegate`  instead.")
    open func setEmojiTapGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        guard let listComponent = self.listComponent else { return }
        self.groupChannelModule(listComponent, didTapEmoji: emojiKey, messageCell: cell)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModuleListDelegate`. Use `channelModule(_:didLongTapEmoji:messageCell:)` of `SBUGroupChannelModuleListDelegate`  instead.")
    open func setEmojiLongTapGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        guard let listComponent = listComponent else { return }
        self.groupChannelModule(listComponent, didLongTapEmoji: emojiKey, messageCell: cell)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModule.List` and replaced to `setMessageCellGestures(_:message:indexPath:)`.", renamed: "listComponent.setMessageCellGestures(_:message:indexPath:)")
    open func setUserMessageCellGestures(_ cell: SBUUserMessageCell,
                                         userMessage: UserMessage,
                                         indexPath: IndexPath) {
        self.listComponent?.setMessageCellGestures(cell, message: userMessage, indexPath: indexPath)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModule.List` and replaced to `setMessageCellGestures(_:message:indexPath:)`.", renamed: "listComponent.setMessageCellGestures(_:message:indexPath:)")
    open func setFileMessageCellGestures(_ cell: SBUFileMessageCell,
                                         fileMessage: FileMessage,
                                         indexPath: IndexPath) {
        self.listComponent?.setMessageCellGestures(cell, message: fileMessage, indexPath: indexPath)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUGroupChannelModule.List` and replaced to `setMessageCellGestures(_:message:indexPath:)`.", renamed: "listComponent.setMessageCellGestures(_:message:indexPath:)")
    open func setUnkownMessageCellGestures(_ cell: SBUUnknownMessageCell,
                                           unknownMessage: BaseMessage,
                                           indexPath: IndexPath) {
        self.listComponent?.setMessageCellGestures(cell, message: unknownMessage, indexPath: indexPath)
    }
}
