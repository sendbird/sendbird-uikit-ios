//
//  SBUModerationsViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/19.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUModerationsViewController {
    // MARK: - 3.1.0
    @available(*, unavailable, message: "This function has been removed. Use `init(channelURL:channelType:)` instead.")
    public convenience init(channelURL: String) {
        self.init(channelURL: channelURL, channelType: .group)
    }
    
    @available(*, unavailable, message: "This function has been seperated. If you have channel object, use `createViewModel(channel:)` instead. or if you have channelUrl, use `createViewModel(channelURL:channelType:) instead.")
    open func createViewModel(channel: GroupChannel? = nil,
                              channelURL: String? = nil) {
    }
    
    // MARK: - 3.0.0
    @available(*, deprecated, renamed: "channelURL")
    public var channelUrl: String? { self.channelURL }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUModerationsModule.Header`.", renamed: "headerComponent.titleView")
    public var titleView: UIView? {
        get { headerComponent?.titleView }
        set { headerComponent?.titleView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUModerationsModule.Header`.", renamed: "headerComponent.leftBarButton")
    public var leftBarButton: UIBarButtonItem? {
        get { headerComponent?.leftBarButton }
        set { headerComponent?.leftBarButton = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUModerationsModule.Header`.", renamed: "headerComponent.rightBarButton")
    public var rightBarButton: UIBarButtonItem? {
        get { headerComponent?.rightBarButton }
        set { headerComponent?.rightBarButton = newValue }
    }

    @available(*, deprecated, message: "This property has been moved to the SBUModerationsModule.List.", renamed: "listComponent.tableView")
    public var tableView: UITableView? { listComponent?.tableView }

    @available(*, deprecated, message: "This function has been moved to the `SBUModerationsViewModel`.", renamed: "viewModel.loadChannel(channelURL:)")
    public func loadChannel(channelUrl: String?) {
        guard let channelURL = channelUrl else { return }
        self.viewModel?.loadChannel(channelURL: channelURL)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUModerationsViewModel`.", renamed: "viewModel.freezeChannel(_:)")
    public func freezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        self.viewModel?.freezeChannel(completionHandler)
    }

    @available(*, deprecated, message: "This function has been moved to the `SBUModerationsViewModel`.", renamed: "viewModel.unfreezeChannel(_:)")
    public func unfreezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        self.viewModel?.unfreezeChannel(completionHandler)
    }

    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldDismissLoadingIndicator() {}
    
    @available(*, deprecated, message: "This function has been moved to the SBUModerationsModule.List.`", renamed: "listComponent.register(moderationCell:nib:)")
    public func register(moderationCell: UITableViewCell, nib: UINib? = nil) {
        self.listComponent?.register(moderationCell: moderationCell, nib: nib)
    }
    
    // MARK: - ~2.2.0
    @available(*, deprecated, renamed: "showMutedMemberList()")
    open func showMutedMeberList() { self.showMutedMemberList() }
    
    @available(*, deprecated, renamed: "showBannedUserList()")
    open func showBannedMeberList() { self.showBannedUserList() }
    
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    public func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}
