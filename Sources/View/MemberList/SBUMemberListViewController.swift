//
//  SBUMemberListViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


/// This class handling channelMembers,  operators,  mutedMembers,  bannedMembers,  participants,
open class SBUMemberListViewController: SBUBaseViewController, SBUMemberListModuleHeaderDelegate, SBUMemberListModuleListDelegate, SBUMemberListModuleListDataSource, SBUCommonViewModelDelegate, SBUUserProfileViewDelegate, SBUMemberListViewModelDelegate, SBUMemberListViewModelDataSource {
    
    // MARK: - UI properties (Public)
    public var headerComponent: SBUMemberListModule.Header?
    public var listComponent: SBUMemberListModule.List?
    
    //Common
    /// To use the custom user profile view, set this to the custom view created using `SBUUserProfileViewProtocol`.
    /// And, if you do not want to use the user profile feature, please set this value to nil.
    public lazy var userProfileView: UIView? = SBUUserProfileView(delegate: self)
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.userListTheme)
    public var theme: SBUUserListTheme
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var componentTheme: SBUComponentTheme
    
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUMemberListViewModel?
    
    public var channel: SBDBaseChannel? { viewModel?.channel }
    public var channelUrl: String? { viewModel?.channelUrl }
    
    public var memberList: [SBUUser] { viewModel?.memberList ?? [] }
    public var memberListType: ChannelMemberListType { viewModel?.memberListType ?? .none }
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUMemberListViewController(channelUrl:type:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUMemberListViewController.init(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
        fatalError()
    }
    
    /// If you have channel and members objects, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - members: `SBUUser` array object
    ///   - memberListType: Channel member list type (default: `.channelMembers`)
    /// - Since: 1.2.0
    required public init(channel: SBDBaseChannel,
                         members: [SBUUser]? = nil,
                         memberListType: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        var channelType = SBDChannelType.group
        if channel is SBDOpenChannel {
            channelType = .open
        }
        
        self.createViewModel(
            channel: channel,
            channelType:channelType,
            members: members,
            type: memberListType
        )
        
        self.headerComponent = SBUModuleSet.memberListModule.headerComponent
        self.listComponent = SBUModuleSet.memberListModule.listComponent
    }
    
    /// If you have channelUrl and members objects, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - members: `SBUUser` array object
    ///   - memberListType: Channel member list type (default: `.channelMembers`)
    /// - Since: 1.2.0
    required public init(channelUrl: String,
                         channelType: SBDChannelType,
                         members: [SBUUser]? = nil,
                         memberListType: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(
            channelUrl: channelUrl,
            channelType:channelType,
            members: members,
            type: memberListType
        )
        
        self.headerComponent = SBUModuleSet.memberListModule.headerComponent
        self.listComponent = SBUModuleSet.memberListModule.listComponent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let userProfileView = userProfileView as? SBUUserProfileView {
            userProfileView.dismiss()
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.viewModel = nil
        self.headerComponent = nil
        self.listComponent = nil
    }
    
    
    // MARK: - ViewModel
    open func createViewModel(channel: SBDBaseChannel? = nil,
                              channelUrl: String? = nil,
                              channelType: SBDChannelType = .group,
                              members: [SBUUser]? = nil,
                              type: ChannelMemberListType) {
        self.viewModel = SBUMemberListViewModel(
            channel: channel,
            channelUrl: channelUrl,
            channelType: channelType,
            members: members,
            memberListType: type,
            delegate: self
        )
    }
    
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(
            delegate: self,
            memberListType: self.memberListType,
            theme: self.theme,
            componentTheme: self.componentTheme
        )
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.headerComponent?.leftBarButton
        self.navigationItem.rightBarButtonItem = self.headerComponent?.rightBarButton
        
        // List component
        self.listComponent?.configure(
            delegate: self,
            dataSource: self,
            memberListType: self.memberListType,
            theme: self.theme,
            componentTheme: self.componentTheme)
        
        if let listComponent = self.listComponent {
            self.view.addSubview(listComponent)
        }
    }

    open override func setupLayouts() {
        self.listComponent?.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationShadowColor
        )
        
        self.headerComponent?.setupStyles(theme: self.theme, componentTheme: self.componentTheme)
        self.listComponent?.setupStyles(theme: self.theme, componentTheme: self.componentTheme)
        
        self.view.backgroundColor = self.theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        self.listComponent?.reloadTableView()
        
        if let userProfileView = self.userProfileView as? SBUUserProfileView {
            userProfileView.setupStyles()
        }
    }
    
    
    // MARK: - Actions
    
    /// If you want to use a custom inviteChannelViewController, override it and implement it.
    open func showInviteUser() {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        
        let type: ChannelInviteListType = self.memberListType == .operators ? .operators : .users
        switch type {
        case .users:
            let inviteUserVC = SBUViewControllerSet.InviteUserViewContoller.init(channel: channel)
            self.navigationController?.pushViewController(inviteUserVC, animated: true)
        case .operators:
            let promoteMemberVC = SBUViewControllerSet.PromoteMemberViewController.init(channel: channel)
            self.navigationController?.pushViewController(promoteMemberVC, animated: true)
        default:
            break
        }
    }
    
    /// This func tion shows the user profile
    ///
    /// If you do not want to use the user profile function, override this function and leave it empty.
    /// - Parameter user: `SBUUser` object used for user profile configuration
    /// - Since: 3.0.0
    open func showUserProfile(with user: SBUUser) {
        guard let userProfileView = self.userProfileView as? SBUUserProfileView else { return }
        guard let baseView = self.navigationController?.view else { return }
        switch self.channel {
        case is SBDGroupChannel:
            guard SBUGlobals.isUserProfileEnabled else { return }
            userProfileView.show(baseView: baseView, user: user)
            
        case is SBDOpenChannel:
            guard SBUGlobals.isOpenChannelUserProfileEnabled else { return }
            userProfileView.show(baseView: baseView, user: user, isOpenChannel: true)
            
        default: return
        }
    }
    
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBDError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    
    // MARK: - SBUMemberListModuleHeaderDelegate
    open func memberListModule(_ headerComponent: SBUMemberListModule.Header,
                               didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func memberListModule(_ headerComponent: SBUMemberListModule.Header,
                               didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func memberListModule(_ headerComponent: SBUMemberListModule.Header,
                               didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func memberListModule(_ headerComponent: SBUMemberListModule.Header,
                               didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func memberListModule(_ headerComponent: SBUMemberListModule.Header,
                               didTapRightItem rightItem: UIBarButtonItem) {
        self.showInviteUser()
    }
    
    
    // MARK: - SBUMemberListModuleListDelegate
    open func memberListModule(_ listComponent: SBUMemberListModule.List,
                               didSelectRowAt indexPath: IndexPath) { }
    
    open func memberListModule(_ listComponent: SBUMemberListModule.List,
                               didDetectPreloadingPosition indexPath: IndexPath) {
        self.viewModel?.preLoadNextMemberList(indexPath: indexPath)
    }
    
    open func memberListModule(_ listComponent: SBUMemberListModule.List,
                               didTapMoreMenuFor member: SBUUser) {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        
        let userNameItem = SBUActionSheetItem(
            title: member.nickname ?? member.userId,
            color: self.componentTheme.actionSheetSubTextColor,
            textAlignment: .center,
            completionHandler: nil
        )
        
        let operatorItem = SBUActionSheetItem(
            title: member.isOperator || self.memberListType == .operators
            ? SBUStringSet.MemberList_Dismiss_Operator
            : SBUStringSet.MemberList_Promote_Operator,
            color: self.componentTheme.actionSheetTextColor,
            textAlignment: .center
        ) { [weak self] in
            guard let self = self else { return }
            if member.isOperator || self.memberListType == .operators {
                self.viewModel?.dismissOperator(member: member)
            } else {
                self.viewModel?.promoteToOperator(member: member)
            }
        }
        let muteItem = SBUActionSheetItem(
            title: member.isMuted
            ? SBUStringSet.MemberList_Unmute
            : SBUStringSet.MemberList_Mute,
            color: self.componentTheme.actionSheetTextColor,
            textAlignment: .center
        ) { [weak self] in
            guard let self = self else { return }
            if member.isMuted {
                self.viewModel?.unmute(member: member)
            } else {
                self.viewModel?.mute(member: member)
            }
        }
        
        let banItem = SBUActionSheetItem(
            title: self.memberListType == .bannedMembers
            ? SBUStringSet.MemberList_Unban
            : SBUStringSet.MemberList_Ban,
            color: self.memberListType == .bannedMembers
            ? self.componentTheme.actionSheetTextColor
            : self.componentTheme.actionSheetErrorColor,
            textAlignment: .center
        ) { [weak self] in
            guard let self = self else { return }
            if self.memberListType == .bannedMembers {
                self.viewModel?.unban(member: member)
            } else {
                self.viewModel?.ban(member: member)
            }
        }
        
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: self.componentTheme.actionSheetItemColor,
            completionHandler: nil)
        
        var items: [SBUActionSheetItem] = [userNameItem]
        
        switch self.memberListType {
        case .channelMembers:
            let isBroadcast = channel.isBroadcast
            items += isBroadcast ? [operatorItem, banItem] : [operatorItem, muteItem, banItem]
        case .operators:
            items += [operatorItem]
        case .mutedMembers:
            items += [muteItem]
        case .bannedMembers:
            items += [banItem]
        default:
            break
        }
        
        SBUActionSheet.show(items: items, cancelItem: cancelItem)
    }
    
    open func memberListModule(_ listComponent: SBUMemberListModule.List,
                               didTapUserProfileFor member: SBUUser) {
        self.showUserProfile(with: member)
    }
    
    open func memberListModuleDidSelectRetry(_ listComponent: SBUMemberListModule.List) {
        self.viewModel?.loadNextMemberList(reset: true)
    }
    
    // MARK: - SBUMemberListModuleListDataSource
    open func memberListModule(_ listComponent: SBUMemberListModule.List,
                                 membersInTableView tableView: UITableView) -> [SBUUser] {
        return self.viewModel?.memberList ?? []
    }
    open func memberListModule(_ listComponent: SBUMemberListModule.List,
                                 channelForTableView tableView: UITableView) -> SBDBaseChannel? {
        return self.viewModel?.channel
    }
    
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBDError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.description ?? "")
        
        if isBlocker {
            self.listComponent?.updateEmptyView(type: .error)
            self.listComponent?.reloadTableView()
        }
    }
    
    
    // MARK: - SBUUserProfileViewDelegate
    open func didSelectMessage(userId: String?) {
        if let userProfileView = self.userProfileView as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
            if let userId = userId {
                SendbirdUI.createAndMoveToChannel(userIds: [userId])
            }
        }
    }
    
    open func didSelectClose() {
        if let userProfileView = self.userProfileView as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
        }
    }
    
    
    // MARK: - SBUMemberListViewModelDelegate
    open func memberListViewModel(_ viewModel: SBUMemberListViewModel,
                                  didChangeMembers members: [SBUUser],
                                  needsToReload: Bool) {
        self.listComponent?.reloadTableView()
        self.updateStyles()
    }
    
    open func memberListViewModel(_ viewModel: SBUMemberListViewModel,
                                  didChangeChannel channel: SBDBaseChannel?,
                                  withContext context: SBDMessageContext) {
        self.listComponent?.reloadTableView()
    }
    
    
    // MARK: - SBUMemberListViewModelDataSource
    open func memberListViewModel(_ viewModel: SBUMemberListViewModel,
                                  nextMemberListForChannel channel: SBDBaseChannel?) -> [SBUUser]? {
        return nil
    }
}
