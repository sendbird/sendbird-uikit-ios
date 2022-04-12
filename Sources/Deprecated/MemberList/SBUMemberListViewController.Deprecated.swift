//
//  SBUMemberListViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/18.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

extension SBUMemberListViewController {
    // MARK: - 3.0.0
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListModule.Header`.", renamed: "headerComponent.titleView")
    public var titleView: UIView? {
        get { headerComponent?.titleView }
        set { headerComponent?.titleView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListModule.Header`.", renamed: "headerComponent.leftBarButton")
    public var leftBarButton: UIBarButtonItem? {
        get { headerComponent?.leftBarButton }
        set { headerComponent?.leftBarButton = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListModule.Header`.", renamed: "headerComponent.rightBarButton")
    public var rightBarButton: UIBarButtonItem? {
        get { headerComponent?.rightBarButton }
        set { headerComponent?.rightBarButton = newValue }
    }

    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListModule.List`.", renamed: "listComponent.tableView")
    public var tableView: UITableView? { listComponent?.tableView}
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListModule.List`.", renamed: "listComponent.memberCell")
    public var userCell: UITableViewCell? { listComponent?.memberCell }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListModule.List`.", renamed: "listComponent.emptyView")
    public var emptyView: UIView? {
        get { listComponent?.emptyView }
        set { listComponent?.emptyView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.memberListQuery")
    public var memberListQuery: SBDGroupChannelMemberListQuery? { viewModel?.memberListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.operatorListQuery")
    public var operatorListQuery: SBDOperatorListQuery? { viewModel?.operatorListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.mutedMemberListQuery")
    public var mutedMemberListQuery: SBDGroupChannelMemberListQuery? { viewModel?.mutedMemberListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.bannedMemberListQuery")
    public var bannedMemberListQuery: SBDBannedUserListQuery? { viewModel?.bannedMemberListQuery }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.participantListQuery")
    public var participantListQuery: SBDParticipantListQuery? { viewModel?.participantListQuery }
    
    @available(*, deprecated, renamed: "init(channel:memberListType:)")
    public convenience init(channel: SBDBaseChannel, type: ChannelMemberListType) {
        self.init(channel: channel, memberListType: type)
    }

    @available(*, deprecated, renamed: "init(channel:members:memberListType:)")
    public convenience init(channel: SBDBaseChannel,
                            members: [SBUUser],
                            type: ChannelMemberListType) {
        self.init(channel: channel, members: members, memberListType: type)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.loadChannel(channelUrl:type:)")
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        viewModel?.loadChannel(channelUrl: channelUrl, type: .group)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.loadNextMemberList(reset:members:)")
    public func loadNextMemberList(reset: Bool, members: [SBUUser]? = nil) {
        viewModel?.loadNextMemberList(reset: reset, members: members)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.loadNextMemberList(reset:)")
    public func loadMembers() {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        if let members = channel.members as? [SBDMember] {
            viewModel?.loadNextMemberList(reset: true, members: members.sbu_convertUserList())
        }
    }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListViewModelDataSource`.", renamed: "memberListViewModel(_:nextMemberListForChannel:)")
    open func nextMemberList() -> [SBUUser]? {
        return nil
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.promoteToOperator(member:)")
    public func promoteToOperator(member: SBUUser) {
        viewModel?.promoteToOperator(member: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.dismissOperator(member:)")
    public func dismissOperator(member: SBUUser) {
        viewModel?.dismissOperator(member: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.mute(member:)")
    public func mute(member: SBUUser) {
        viewModel?.mute(member: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.unmute(member:)")
    public func unmute(member: SBUUser) {
        viewModel?.unmute(member: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.ban(member:)")
    public func ban(member: SBUUser) {
        viewModel?.ban(member: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.unban(member:)")
    public func unban(member: SBUUser) {
        viewModel?.unban(member: member)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListViewModel`.", renamed: "viewModel.resetMemberList()")
    public func resetMemberList() { viewModel?.resetMemberList() }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListModule.List`.`", renamed: "listComponent.register(memberCell:nib:)")
    public func register(userCell: UITableViewCell, nib: UINib? = nil) {
        self.listComponent?.register(memberCell: userCell, nib: nil)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMemberListModule.List`.", renamed: "listComponent.reloadTableView()")
    public func reloadData() { listComponent?.reloadTableView() }
    
    @available(*, unavailable, renamed: "showInviteUser()")
    @objc open func onClickInviteUser() { showInviteUser() }

    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldDismissLoadingIndicator() {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListModule.List` and replaced to `setMoreMenuTapAction(_:)`")
    open func setMoreMenuActionHandler(_ member: SBUUser) {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListModule.List`. and replaced to `setUserProfileTapAction(_:)`")
    open func setUserProfileTapGestureHandler(_ user: SBUUser) {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListModule.List`.")
    open func didSelectRetry() {}
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListViewModel`.")
    open func channelDidUpdateOperators(_ sender: SBDBaseChannel) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListViewModel`.")
    open func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListViewModel`.")
    open func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListViewModel`.")
    open func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) { }
    
    @available(*, unavailable, message: "This function has been moved to the `SBUMemberListViewModel`.")
    open func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) { }
    
    
    
    
    /** ~ v.2.2.2 */
    @available(*, deprecated, renamed: "init(channelUrl:channelType:memberListType:)")
    public convenience init(channelUrl: String, type: ChannelMemberListType = .channelMembers) {
        self.init(channelUrl:channelUrl, channelType: .group, memberListType: type)
    }
    
    @available(*, deprecated, renamed: "init(channelUrl:channelType:members:memberListType:)")
    public convenience init(channelUrl: String,
                            members: [SBUUser],
                            type: ChannelMemberListType = .channelMembers) {
        self.init(channelUrl: channelUrl, channelType: .group, members: members, memberListType: type)
    }
    
    @available(*, deprecated, renamed: "resetMemberList()")
    public func reloadMemberList() { viewModel?.resetMemberList() }
    
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    open func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}
