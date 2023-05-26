//
//  SBUUserListViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/18.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@available(*, deprecated, renamed: "SBUUserListViewController") // 3.0.0
public typealias SBUMemberListViewController = SBUUserListViewController

extension SBUUserListViewController {
    // MARK: - 3.0.0
    @available(*, deprecated, renamed: "channelURL")
    public var channelUrl: String? { self.channelURL }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListModule.Header`.", renamed: "headerComponent.titleView")
    public var titleView: UIView? {
        get { headerComponent?.titleView }
        set { headerComponent?.titleView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListModule.Header`.", renamed: "headerComponent.leftBarButton")
    public var leftBarButton: UIBarButtonItem? {
        get { headerComponent?.leftBarButton }
        set { headerComponent?.leftBarButton = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListModule.Header`.", renamed: "headerComponent.rightBarButton")
    public var rightBarButton: UIBarButtonItem? {
        get { headerComponent?.rightBarButton }
        set { headerComponent?.rightBarButton = newValue }
    }

    @available(*, deprecated, message: "This property has been moved to the `SBUUserListModule.List`.", renamed: "listComponent.tableView")
    public var tableView: UITableView? { listComponent?.tableView }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListModule.List`.", renamed: "listComponent.userCell")
    public var userCell: UITableViewCell? { listComponent?.userCell }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListModule.List`.", renamed: "listComponent.emptyView")
    public var emptyView: UIView? {
        get { listComponent?.emptyView }
        set { listComponent?.emptyView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.memberListQuery")
    public var memberListQuery: MemberListQuery? { viewModel?.memberListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.operatorListQuery")
    public var operatorListQuery: OperatorListQuery? { viewModel?.operatorListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.mutedMemberListQuery")
    public var mutedMemberListQuery: MemberListQuery? { viewModel?.mutedMemberListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.bannedUserListQuery")
    public var bannedMemberListQuery: BannedUserListQuery? { viewModel?.bannedUserListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.participantListQuery")
    public var participantListQuery: ParticipantListQuery? { viewModel?.participantListQuery }
    
    @available(*, deprecated, renamed: "userList")
    public var memberList: [SBUUser] { self.userList }
    
    @available(*, deprecated, renamed: "userListType")
    public var memberListType: ChannelUserListType { self.userListType }
    
    @available(*, deprecated, renamed: "init(channel:userListType:)")
    public convenience init(channel: BaseChannel, type: ChannelMemberListType) {
        let type = ChannelUserListType(rawValue: type.rawValue) ?? .none
        self.init(channel: channel, userListType: type)
    }

    @available(*, deprecated, renamed: "init(channel:users:userListType:)")
    public convenience init(channel: BaseChannel,
                            members: [SBUUser],
                            type: ChannelMemberListType) {
        let type = ChannelUserListType(rawValue: type.rawValue) ?? .none
        self.init(channel: channel, users: members, userListType: type)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.loadChannel(channelURL:type:)")
    public func loadChannel(channelUrl: String?) {
        guard let channelURL = channelUrl else { return }
        viewModel?.loadChannel(channelURL: channelURL, type: .group)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.loadNextUserList(reset:users:)")
    public func loadNextMemberList(reset: Bool, members: [SBUUser]? = nil) {
        viewModel?.loadNextUserList(reset: reset, users: members)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.loadNextUserList(reset:)")
    public func loadMembers() {
        guard let channel = self.channel as? GroupChannel else { return }
        viewModel?.loadNextUserList(reset: true, users: channel.members.sbu_convertUserList())
    }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListViewModelDataSource`.", renamed: "userListViewModel(_:nextUserListForChannel:)")
    open func nextMemberList() -> [SBUUser]? {
        return nil
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.registerAsOperator(user:)")
    public func promoteToOperator(member: SBUUser) {
        viewModel?.registerAsOperator(user: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.unregisterOperator(user:)")
    public func dismissOperator(member: SBUUser) {
        viewModel?.unregisterOperator(user: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.mute(user:)")
    public func mute(member: SBUUser) {
        viewModel?.mute(user: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.unmute(user:)")
    public func unmute(member: SBUUser) {
        viewModel?.unmute(user: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.ban(user:)")
    public func ban(member: SBUUser) {
        viewModel?.ban(user: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.unban(user:)")
    public func unban(member: SBUUser) {
        viewModel?.unban(user: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListViewModel`.", renamed: "viewModel.resetUserList()")
    public func resetMemberList() { viewModel?.resetUserList() }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListModule.List`.`", renamed: "listComponent.register(userCell:nib:)")
    public func register(userCell: UITableViewCell, nib: UINib? = nil) {
        self.listComponent?.register(userCell: userCell, nib: nil)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUUserListModule.List`.", renamed: "listComponent.reloadTableView()")
    public func reloadData() { listComponent?.reloadTableView() }
    
    @available(*, unavailable, renamed: "showInviteUser()")
    @objc open func onClickInviteUser() { showInviteUser() }

    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldDismissLoadingIndicator() {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListModule.List` and replaced to `setMoreMenuTapAction(_:)`")
    open func setMoreMenuActionHandler(_ member: SBUUser) {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListModule.List`. and replaced to `setUserProfileTapAction(_:)`")
    open func setUserProfileTapGestureHandler(_ user: SBUUser) {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListModule.List`.")
    open func didSelectRetry() {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListViewModel`.")
    open func channelDidUpdateOperators(_ sender: BaseChannel) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListViewModel`.")
    open func channel(_ sender: GroupChannel, userDidJoin user: User) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListViewModel`.")
    open func channel(_ sender: GroupChannel, userDidLeave user: User) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListViewModel`.")
    open func channel(_ sender: OpenChannel, userDidExit user: User) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUUserListViewModel`.")
    open func channel(_ sender: OpenChannel, userDidEnter user: User) { }
    
    /** ~ v.2.2.2 */
    @available(*, deprecated, renamed: "init(channelURL:channelType:userListType:)")
    public convenience init(channelUrl: String, type: ChannelMemberListType = .members) {
        let type = ChannelUserListType(rawValue: type.rawValue) ?? .members
        self.init(channelURL: channelUrl, channelType: .group, userListType: type)
    }
    
    @available(*, deprecated, renamed: "init(channelURL:channelType:users:userListType:)")
    public convenience init(channelUrl: String,
                            members: [SBUUser],
                            type: ChannelMemberListType = .members) {
        let type = ChannelUserListType(rawValue: type.rawValue) ?? .members
        self.init(channelURL: channelUrl, channelType: .group, users: members, userListType: type)
    }
    
    @available(*, deprecated, renamed: "resetUserList()")
    public func reloadMemberList() { viewModel?.resetUserList() }
    
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    public func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}
