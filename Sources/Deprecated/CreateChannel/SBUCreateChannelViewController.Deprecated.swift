//
//  SBUCreateChannelViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/19.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUCreateChannelViewController {
    // MARK: - 3.0.0
    @available(*, deprecated, message: "This property has been moved to the SBUCreateChannelModule.Header.", renamed: "headerComponent.titleView")
    public var titleView: UIView? {
        get { headerComponent?.titleView }
        set { headerComponent?.titleView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the SBUCreateChannelModule.Header.", renamed: "headerComponent.leftBarButton")
    public var leftBarButton: UIBarButtonItem? {
        get { headerComponent?.leftBarButton }
        set { headerComponent?.leftBarButton = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the SBUCreateChannelModule.Header.", renamed: "headerComponent.rightBarButton")
    public var rightBarButton: UIBarButtonItem? {
        get { headerComponent?.rightBarButton }
        set { headerComponent?.rightBarButton = newValue }
    }

    @available(*, deprecated, message: "This property has been moved to the SBUCreateChannelModule.List.", renamed: "listComponent.tableView")
    public var tableView: UITableView? { listComponent?.tableView }
    
    @available(*, deprecated, message: "This property has been moved to the SBUCreateChannelModule.List.", renamed: "listComponent.userCell")
    public var userCell: UITableViewCell? { listComponent?.userCell }
    
    @available(*, deprecated, message: "This property has been moved to the SBUCreateChannelModule.List.", renamed: "listComponent.emptyView")
    public var emptyView: UIView? {
        get { listComponent?.emptyView }
        set { listComponent?.emptyView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUCreateChannelViewModel`.", renamed: "viewModel.userListQuery")
    public var userListQuery: ApplicationUserListQuery? { viewModel?.userListQuery }

    @available(*, deprecated, message: "This function has been moved to the SBUCreateChannelModule.List.", renamed: "listComponent.reloadTableView()")
    public func reloadData() {
        listComponent?.reloadTableView()
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUCreateChannelViewModel`.", renamed: "viewModel.loadNextUserList(reset:users:)")
    public func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        viewModel?.loadNextUserList(reset: reset, users: users)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUCreateChannelViewModel`.", renamed: "viewModel.selectUser(user:)")
    public func selectUser(user: SBUUser) {
        viewModel?.selectUser(user: user)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUCreateChannelViewModel`.", renamed: "viewModel.createChannel(userIds:)")
    public func createChannel(userIds: [String]) {
        viewModel?.createChannel(userIds: userIds)
    }

    @available(*, deprecated, message: "This function has been moved to the `SBUCreateChannelViewModel`.", renamed: "viewModel.createChannel(params:messageListParams:)")
    public func createChannel(params: GroupChannelCreateParams,
                              messageListParams: MessageListParams? = nil) {
        viewModel?.createChannel(params: params, messageListParams: messageListParams)
    }
    
    @available(*, deprecated, renamed: "createChannelWithSelectedUsers()")
    public func onClickCreate() {
        createChannelWithSelectedUsers()
    }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUCreateChannelViewModelDataSource`.", renamed: "createChannelViewModel(_:nextUserListForChannelType:)")
    open func nextUserList() -> [SBUUser]? { return nil }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldDismissLoadingIndicator() {}
    
    @available(*, unavailable, message: "This function has been moved to the SBUCreateChannelModule.List.")
    open func didSelectRetry() {}
    
    @available(*, deprecated, renamed: "showLoading(_:)")
    public func showLoading(state: Bool) {
        showLoading(state)
    }
    
    @available(*, deprecated, message: "This function has been moved to the SBUCreateChannelModule.List.`", renamed: "listComponent.register(userCell:nib:)")
    public func register(userCell: UITableViewCell, nib: UINib? = nil) {
        self.listComponent?.register(userCell: userCell, nib: nib)
    }
    
    // MARK: - ~2.2.0
    @available(*, deprecated, message: "This function has been moved to the `SBUCreateChannelViewModel`.", renamed: "listComponent.reloadTableView()")
    public func reloadUserList() {
        listComponent?.reloadTableView()
    }
    
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    public func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        errorHandler(message, code)
    }
}
