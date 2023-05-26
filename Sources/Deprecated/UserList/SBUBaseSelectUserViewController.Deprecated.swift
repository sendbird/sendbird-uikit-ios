//
//  SBUBaseSelectUserViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/18.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUBaseSelectUserViewController {
    // MARK: - 3.0.0
    @available(*, deprecated, renamed: "channelURL")
    public var channelUrl: String? { self.channelURL }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserModule.Header`.", renamed: "headerComponent.titleView")
    public var titleView: UIView? {
        get { baseHeaderComponent?.titleView }
        set { baseHeaderComponent?.titleView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserModule.Header`.", renamed: "headerComponent.leftBarButton")
    public var leftBarButton: UIBarButtonItem? {
        get { baseHeaderComponent?.leftBarButton }
        set { baseHeaderComponent?.leftBarButton = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserModule.Header`.", renamed: "headerComponent.rightBarButton")
    public var rightBarButton: UIBarButtonItem? {
        get { baseHeaderComponent?.rightBarButton }
        set { baseHeaderComponent?.rightBarButton = newValue }
    }

    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserModule.List`.", renamed: "listComponent.tableView")
    public var tableView: UITableView? { baseListComponent?.tableView }

    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserModule.List`.", renamed: "listComponent.userCell")
    public var userCell: UITableViewCell? { baseListComponent?.userCell }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserModule.List`.", renamed: "listComponent.emptyView")
    public var emptyView: UIView? {
        get { baseListComponent?.emptyView }
        set { baseListComponent?.emptyView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserViewModel`.", renamed: "viewModel.joinedUserIds")
    public var joinedUserIds: Set<String> { baseViewModel?.joinedUserIds ?? [] }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserViewModel`.", renamed: "viewModel.userListQuery")
    public var userListQuery: ApplicationUserListQuery? { baseViewModel?.userListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserViewModel`.", renamed: "viewModel.memberListQuery")
    public var memberListQuery: MemberListQuery? { baseViewModel?.memberListQuery }

    @available(*, deprecated, message: "This property has been moved to the `SBUBaseSelectUserViewModel`.", renamed: "viewModel.inviteListType")
    public var inviteListType: ChannelInviteListType { baseViewModel?.inviteListType ?? .users }
    
    @available(*, unavailable, message: "If you want to invite a user, use `init(channel:)` on `SBUInviteUserViewController` class, \nor if you want to register as operator a member, use `init(channel:)` on `SBURegisterOperatorViewController` class.")
    public convenience init(channel: GroupChannel, type: ChannelInviteListType) {
        self.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "If you want to invite a user, use `init(channelURL:)` on `SBUInviteUserViewController` class,\nor if you want to register as operator a member, use `init(channelURL:)` on `SBURegisterOperatorViewController` class.")
    public convenience init(channelUrl: String, type: ChannelInviteListType) {
        self.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "If you want to invite a user, use `init(channel:users:)` on `SBUInviteUserViewController` class,\nor if you want to register as operator a member, use `init(channel:users:)` on `SBURegisterOperatorViewController` class.")
    public convenience init(channel: GroupChannel, users: [SBUUser], type: ChannelInviteListType) {
        self.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable, message: "If you want to invite a user, use `init(channelURL:users:)` on `SBUInviteUserViewController` class,\nor if you want to register as operator a member, use `init(channelURL:users:)` on `SBURegisterOperatorViewController` class.")
    public convenience init(channelUrl: String, users: [SBUUser], type: ChannelInviteListType) {
        self.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "If you want to invite a user, use `inviteSelectedUsers()` on `SBUInviteUserViewController` class,\nor if you want to register as operator a member, use `registerSelectedUsers()` on `SBURegisterOperatorViewController` class.")
    public func onClickInviteOrPromote() { }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUBaseSelectUserViewModel`.", renamed: "viewModel.resetUserList()")
    public func resetUserList() {
        self.baseViewModel?.resetUserList()
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUBaseSelectUserViewModel`.", renamed: "viewModel.loadChannel(channelURL:type:)")
    public func loadChannel(channelUrl: String?) {
        guard let channelURL = channelUrl else { return }
        self.baseViewModel?.loadChannel(channelURL: channelURL, type: .group)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUBaseSelectUserViewModel`.", renamed: "viewModel.loadNextUserList(reset:users:)")
    public func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        self.baseViewModel?.loadNextUserList(reset: reset, users: users)
    }
    
    @available(*, unavailable, message: "This function set and renamed on `SBUInviteUserViewController` class.", renamed: "inviteSelectedUsers()")
    public func inviteUsers() { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUInviteUserViewModel` class.", renamed: "viewModel.invite(userIds:)")
    public func inviteUsers(userIds: [String]) { }
    
    @available(*, unavailable, message: "This function set and renamed on `SBURegisterOperatorViewController` class.", renamed: "registerSelectedUsers()")
    public func promoteToOperators() { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBURegisterOperatorViewModel` class.", renamed: "viewModel.registerAsOperators(userIds:)")
    public func promoteToOperators(memberIds: [String]) { }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUBaseSelectUserViewModel`.", renamed: "viewModel.selectUser(user:)")
    public func selectUser(user: SBUUser) {
        self.baseViewModel?.selectUser(user: user)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUBaseSelectUserModule.List`.`", renamed: "listComponent.register(userCell:nib:)")
    public func register(userCell: UITableViewCell, nib: UINib? = nil) {
        self.baseListComponent?.register(userCell: userCell, nib: nib)
    }

    @available(*, deprecated, message: "This function has been moved to the `SBUBaseSelectUserModule.List`.", renamed: "listComponent.reloadTableView()")
    public func reloadData() {
        self.baseListComponent?.reloadTableView()
    }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldDismissLoadingIndicator() {}
    
    // MARK: - ~2.2.0
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    public func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}
