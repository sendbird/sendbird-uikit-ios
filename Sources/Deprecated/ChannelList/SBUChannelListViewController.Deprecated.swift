//
//  SBUGroupChannelListViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/18.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@available(*, deprecated, renamed: "SBUGroupChannelListViewController") // 3.0.0
public typealias SBUChannelListViewController = SBUGroupChannelListViewController

extension SBUGroupChannelListModuleListDelegate {
    // MARK: - 3.2.0
    @available(*, unavailable, renamed: "groupChannelListModule(_:didSelectRowAt:)")
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, didSelectRowAt indexPath: IndexPath) {}
    
    @available(*, unavailable, renamed: "groupChannelListModule(_:didDetectPreloadingPosition:)")
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, didDetectPreloadingPosition indexPath: IndexPath) {}
    
    @available(*, unavailable, renamed: "groupChannelListModule(_:didSelectLeave:)")
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, didSelectLeave channel: GroupChannel) {}
    
    @available(*, unavailable, renamed: "groupChannelListModule(_:didChangePushTriggerOption:channel:)")
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, didChangePushTriggerOption option: GroupChannelPushTriggerOption, channel: GroupChannel) {}
    
    @available(*, unavailable, renamed: "groupChannelListModuleDidSelectRetry(_:)")
    func channelListModuleDidSelectRetry(_ listComponent: SBUGroupChannelListModule.List) {}

}

extension SBUGroupChannelListModuleListDataSource {
    // MARK: - 3.2.0
    @available(*, unavailable, renamed: "groupChannelListModule(_:channelsInTableView:)")
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, channelsInTableView tableView: UITableView) -> [GroupChannel]? { return nil }
}

extension SBUGroupChannelListViewController {
    // MARK: - 3.0.0
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListModule.Header`.", renamed: "headerComponent.titleView")
    public var titleView: UIView? {
        get { headerComponent?.titleView }
        set { headerComponent?.titleView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListModule.Header`.", renamed: "headerComponent.leftBarButton")
    public var leftBarButton: UIBarButtonItem? {
        get { headerComponent?.leftBarButton }
        set { headerComponent?.leftBarButton = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListModule.Header`.", renamed: "headerComponent.rightBarButton")
    public var rightBarButton: UIBarButtonItem? {
        get { headerComponent?.rightBarButton }
        set { headerComponent?.rightBarButton = newValue }
    }

    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListModule.List`.", renamed: "listComponent.tableView")
    public var tableView: UITableView? { listComponent?.tableView }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListModule.List`.", renamed: "listComponent.channelCell")
    public var channelCell: SBUBaseChannelCell? { listComponent?.channelCell }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListModule.List`.", renamed: "listComponent.customCell")
    public var customCell: SBUBaseChannelCell? { listComponent?.customCell }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListModule.List`.", renamed: "listComponent.emptyView")
    public var emptyView: UIView? {
        get { listComponent?.emptyView }
        set { listComponent?.emptyView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.channelListQuery")
    public var channelListQuery: GroupChannelListQuery? { viewModel?.channelListQuery }
    
    @available(*, unavailable, message: "Since it automatically manages internally, it is no longer necessary.")
    public var isLoading: Bool { false }
    
    @available(*, unavailable, message: "Since it automatically manages internally, it is no longer necessary.")
    public var lastUpdatedTimestamp: Int64 { 0 }
    
    @available(*, unavailable, message: "Since it automatically manages internally, it is no longer necessary.")
    public var lastUpdatedToken: String? { "" }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListViewModel`.", renamed: "SBUGroupChannelListViewModel.channelLoadLimit")
    public var limit: UInt { SBUGroupChannelListViewModel.channelLoadLimit }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.channelListQuery.includeEmptyChannel")
    public var includeEmptyChannel: Bool { viewModel?.channelListQuery?.includeEmptyChannel ?? false }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.initChannelList()")
    public func initChannelList() { viewModel?.initChannelList() }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.changePushTriggerOption(option:channel:completionHandler:)")
    public func changePushTriggerOption(option: GroupChannelPushTriggerOption,
                                        channel: GroupChannel,
                                        completionHandler: ((Bool) -> Void)? = nil) {
        viewModel?.changePushTriggerOption(option: option, channel: channel)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.leaveChannel(_:completionHandler:)")
    public func leaveChannel(_ channel: GroupChannel, completionHandler: ((Bool) -> Void)? = nil) {
        viewModel?.leaveChannel(channel)
    }

    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.reset()")
    public func resetChannelList() { viewModel?.reset() }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.loadNextChannelList(reset:)")
    public func loadNextChannelList(reset: Bool) { viewModel?.loadNextChannelList(reset: reset) }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.sortChannelList(needReload:)")
    public func sortChannelList(needReload: Bool) { viewModel?.sortChannelList(needReload: needReload) }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.updateChannels(_:needReload:)")
    public func updateChannels(_ channels: [GroupChannel]?, needReload: Bool) {
        viewModel?.updateChannels(channels, needReload: needReload)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.upsertChannels(_:needReload:)")
    public func upsertChannels(_ channels: [GroupChannel]?, needReload: Bool) {
        viewModel?.upsertChannels(channels, needReload: needReload)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListViewModel`.", renamed: "viewModel.deleteChannels(channelURLs:needReload:)")
    public func deleteChannels(channelUrls: [String]?, needReload: Bool) {
        viewModel?.deleteChannels(channelURLs: channelUrls, needReload: needReload)
    }

    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListModule.List`.`", renamed: "listComponent.register(channelCell:nib:)")
    public func register(channelCell: SBUBaseChannelCell, nib: UINib? = nil) {
        self.listComponent?.register(channelCell: channelCell, nib: nil)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListModule.List`.`", renamed: "listComponent.register(customCell:nib:)")
    public func register(customCell: SBUBaseChannelCell?, nib: UINib? = nil) {
        self.listComponent?.register(customCell: customCell, nib: nil)
    }

    @available(*, deprecated, message: "This function has been moved to the `SBUGroupChannelListModule.List`.", renamed: "listComponent.reloadTableView()")
    public func reloadTableView() { listComponent?.reloadTableView() }
    
    @available(*, deprecated, renamed: "showLoading(_:)")
    public func setLoading(_ loadingState: Bool, _ showIndicator: Bool) { showLoading(loadingState) }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldDismissLoadingIndicator() {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUGroupChannelListModule.List`.")
    open func didSelectRetry() {}
    
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    open func channel(_ sender: GroupChannel, userDidJoin user: User) {}
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    open func channel(_ sender: GroupChannel, userDidLeave user: User) {}
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    open func channelWasChanged(_ sender: BaseChannel) {}
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    open func channel(_ sender: BaseChannel, messageWasDeleted messageId: Int64) {}
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    open func channelWasFrozen(_ sender: BaseChannel) {}
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    open func channelWasUnfrozen(_ sender: BaseChannel) {}
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    open func channel(_ sender: BaseChannel, userWasBanned user: User) {}
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    open func didSucceedReconnection() {}

    @available(*, unavailable, message: "Use `SBUGroupChannelListViewModel groupChannelListViewModel(_:didChangeChannelList:needsToReload:)` instead.")
    public func channelListDidChange(_ channels: [GroupChannel]?, needToReload: Bool) { }
    
    @available(*, unavailable, message: "Use `SBUGroupChannelListViewModel groupChannelListViewModel(_:didUpdateChannel:)` instead.")
    public func channelDidUpdate(_ channel: GroupChannel) { }
    
    @available(*, unavailable, message: "Use `SBUGroupChannelListViewModel groupChannelListViewModel(_:didLeaveChannel:)` instead.")
    public func channelDidLeave(_ channel: GroupChannel) { }
    
    // MARK: - ~2.2.0
    @available(*, unavailable, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.")
    public func loadChannelChangeLogs(hasMore: Bool, token: String?) { }
    
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    public func didReceiveError(_ message: String?, _ code: NSInteger?) {
        self.errorHandler(message, code)
    }
}

extension SBUGroupChannelListViewModel {
    // MARK: - 3.2.1
    
    @available(*, deprecated, message: "Since it automatically manages channel list changes internally, it is no longer necessary to use this function.")
    public func updateChannels(_ channels: [GroupChannel]?, needReload: Bool) {
        self.delegate?.groupChannelListViewModel(
            self,
            didChangeChannelList: self.channelCollection?.channelList,
            needsToReload: needReload
        )
    }

    @available(*, deprecated, message: "Since it automatically manages channel list changes internally, it is no longer necessary to use this function.")
    public func upsertChannels(_ channels: [GroupChannel]?, needReload: Bool) {
        self.delegate?.groupChannelListViewModel(
            self,
            didChangeChannelList: self.channelCollection?.channelList,
            needsToReload: needReload
        )
    }

    @available(*, deprecated, message: "Since it automatically manages channel list changes internally, it is no longer necessary to use this function.")
    public func deleteChannels(channelURLs: [String]?, needReload: Bool) {
        self.delegate?.groupChannelListViewModel(
            self,
            didChangeChannelList: self.channelCollection?.channelList,
            needsToReload: needReload
        )
    }

    @available(*, deprecated, message: "Since it automatically manages channel list changes internally, it is no longer necessary to use this function.")
    public func sortChannelList(needReload: Bool) {
        self.delegate?.groupChannelListViewModel(
            self,
            didChangeChannelList: self.channelCollection?.channelList,
            needsToReload: needReload
        )
    }
}
