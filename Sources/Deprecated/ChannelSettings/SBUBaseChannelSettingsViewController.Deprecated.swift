//
//  SBUBaseChannelSettingsViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/19.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@available(*, deprecated, renamed: "SBUBaseChannelSettingsViewController") // 3.0.0
public typealias SBUBaseChannelSettingViewController = SBUBaseChannelSettingsViewController

// MARK: - BaseChannelSettings
extension SBUBaseChannelSettingsViewController {
    // MARK: - 3.0.0
    @available(*, deprecated, renamed: "channelURL")
    public var channelUrl: String? { self.channelURL }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseChannelSettingsModule.Header`.", renamed: "headerComponent.titleView")
    public var titleView: UIView? {
        get { baseHeaderComponent?.titleView }
        set { baseHeaderComponent?.titleView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseChannelSettingsModule.Header`.", renamed: "headerComponent.leftBarButton")
    public var leftBarButton: UIBarButtonItem? {
        get { baseHeaderComponent?.leftBarButton }
        set { baseHeaderComponent?.leftBarButton = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseChannelSettingsModule.Header`.", renamed: "headerComponent.rightBarButton")
    public var rightBarButton: UIBarButtonItem? {
        get { baseHeaderComponent?.rightBarButton }
        set { baseHeaderComponent?.rightBarButton = newValue }
    }

    @available(*, deprecated, message: "This property has been moved to the `SBUBaseChannelSettingsModule.List`.", renamed: "listComponent.tableView")
    public var tableView: UITableView? { baseListComponent?.tableView }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseChannelSettingsModule.List`. And renamed to `channelInfoView`.", renamed: "listComponent.channelInfoView")
    public var userInfoView: UIView? {
        get { baseListComponent?.channelInfoView }
        set { baseListComponent?.channelInfoView = newValue }
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUBaseChannelSettingsViewModel`.", renamed: "viewModel.loadChannel(channelURL:)")
    public func loadChannel(channelUrl: String?) {
        guard let channelURL = channelUrl else { return }
        self.baseViewModel?.loadChannel(channelURL: channelURL)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUBaseChannelSettingsViewModel`.", renamed: "viewModel.updateChannel(channelName:coverImage:)")
    public func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) {
        self.baseViewModel?.updateChannel(channelName: channelName, coverImage: coverImage)
    }
    
    @available(*, deprecated, renamed: "showChannelEditActionSheet()")
    public func onClickEdit() {
        self.showChannelEditActionSheet()
    }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldDismissLoadingIndicator() {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUBaseChannelSettingsViewModel`.")
    open func channel(_ sender: GroupChannel, userDidJoin user: User) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUBaseChannelSettingsViewModel`.")
    open func channel(_ sender: GroupChannel, userDidLeave user: User) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUBaseChannelSettingsViewModel`.")
    open func channel(_ sender: OpenChannel, userDidExit user: User) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUBaseChannelSettingsViewModel`.")
    open func channel(_ sender: OpenChannel, userDidEnter user: User) { }
    
    // MARK: - ~2.2.0
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    public func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}

// MARK: - GroupChannelSettings

@available(*, deprecated, renamed: "SBUGroupChannelSettingsViewController") // 3.0.0
public typealias SBUChannelSettingsViewController = SBUGroupChannelSettingsViewController

extension SBUGroupChannelSettingsViewController {
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelSettingsViewModel`.", renamed: "viewModel.updateChannel(params:)")
    public func updateChannel(params: GroupChannelUpdateParams) {
        self.viewModel?.updateChannel(params: params)
    }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUGroupChannelPushSettingsViewModel`. and a SBUGroupChannelPushSettingsViewController has been created for channel's push settings.") // 3.0.0
    public func changeNotification(isOn: Bool) {}
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelSettingsViewModel`.", renamed: "viewModel.leaveChannel()")
    public func leaveChannel() {
        self.viewModel?.leaveChannel()
    }
    
    // MARK: - ~2.2.0
    @available(*, deprecated, renamed: "updateChannel(channelName:coverImage:)")
    public func updateChannelInfo(channelName: String? = nil) {
        self.updateChannel(channelName: channelName)
    }
}

// MARK: - OpenChannelSettings
extension SBUOpenChannelSettingsViewController {
    @available(*, deprecated, message: "This function has been moved to the `SBUOpenChannelSettingsViewModel`.", renamed: "viewModel.updateChannel(params:)")
    public func updateChannel(params: OpenChannelUpdateParams) {
        self.viewModel?.updateChannel(params: params)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUOpenChannelSettingsViewModel`.", renamed: "viewModel.deleteChannel()")
    public func deleteChannel() {
        self.viewModel?.deleteChannel()
    }
}
