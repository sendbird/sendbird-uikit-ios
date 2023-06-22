//
//  SBUUserListViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This class handling members,  operators,  muted/Participants,  banned,  participants,
open class SBUUserListViewController: SBUBaseViewController, SBUUserListModuleHeaderDelegate, SBUUserListModuleListDelegate, SBUUserListModuleListDataSource, SBUCommonViewModelDelegate, SBUUserProfileViewDelegate, SBUUserListViewModelDelegate, SBUUserListViewModelDataSource {
    
    // MARK: - UI properties (Public)
    public var headerComponent: SBUUserListModule.Header?
    public var listComponent: SBUUserListModule.List?
    
    // Common
    /// To use the custom user profile view, set this to the custom view created using `SBUUserProfileViewProtocol`.
    /// And, if you do not want to use the user profile feature, please set this value to nil.
    public lazy var userProfileView: UIView? = SBUUserProfileView(delegate: self)
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.userListTheme)
    public var theme: SBUUserListTheme
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var componentTheme: SBUComponentTheme
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUUserListViewModel?
    
    public var channel: BaseChannel? { viewModel?.channel }
    public var channelURL: String? { viewModel?.channelURL }
    public var channelType: ChannelType { viewModel?.channelType ?? .group }
    
    public var userList: [SBUUser] { viewModel?.userList ?? [] }
    public var userListType: ChannelUserListType { viewModel?.userListType ?? .none }
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUUserListViewController(channelURL:type:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUUserListViewController.init(channelURL:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
        fatalError()
    }
    
    /// If you have channel and users objects, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - users: `SBUUser` array object
    ///   - userListType: Channel user list type (default: `.members`)
    /// - Since: 1.2.0
    required public init(channel: BaseChannel,
                         users: [SBUUser]? = nil,
                         userListType: ChannelUserListType = .members) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        var channelType = ChannelType.group
        if channel is OpenChannel {
            channelType = .open
        }
        
        self.createViewModel(
            channel: channel,
            channelType: channelType,
            users: users,
            type: userListType
        )
        
        if channelType == .group {
            self.headerComponent = SBUModuleSet.groupUserListModule.headerComponent
            self.listComponent = SBUModuleSet.groupUserListModule.listComponent
        } else if channelType == .open {
            self.headerComponent = SBUModuleSet.openUserListModule.headerComponent
            self.listComponent = SBUModuleSet.openUserListModule.listComponent
        }
    }
    
    /// If you have channelURL and users objects, use this initialize function.
    /// - Parameters:
    ///   - channelURL: Channel url string
    ///   - users: `SBUUser` array object
    ///   - userListType: Channel user list type (default: `.members`)
    /// - Since: 1.2.0
    required public init(channelURL: String,
                         channelType: ChannelType,
                         users: [SBUUser]? = nil,
                         userListType: ChannelUserListType = .members) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(
            channelURL: channelURL,
            channelType: channelType,
            users: users,
            type: userListType
        )
        
        if channelType == .group {
            self.headerComponent = SBUModuleSet.groupUserListModule.headerComponent
            self.listComponent = SBUModuleSet.groupUserListModule.listComponent
        } else if channelType == .open {
            self.headerComponent = SBUModuleSet.openUserListModule.headerComponent
            self.listComponent = SBUModuleSet.openUserListModule.listComponent
        }
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
        theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.viewModel = nil
        self.headerComponent = nil
        self.listComponent = nil
    }
    
    // MARK: - ViewModel
    open func createViewModel(channel: BaseChannel? = nil,
                              channelURL: String? = nil,
                              channelType: ChannelType = .group,
                              users: [SBUUser]? = nil,
                              type: ChannelUserListType) {
        self.viewModel = SBUUserListViewModel(
            channel: channel,
            channelURL: channelURL,
            channelType: channelType,
            users: users,
            userListType: type,
            delegate: self
        )
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(
            delegate: self,
            userListType: self.userListType,
            channelType: self.channelType,
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
            userListType: self.userListType,
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
        let type: ChannelInviteListType = self.userListType == .operators ? .operators : .users
        
        if let groupChannel = self.channel as? GroupChannel {
            switch type {
            case .users:
                let inviteUserVC = SBUViewControllerSet.InviteUserViewController.init(channel: groupChannel)
                self.navigationController?.pushViewController(inviteUserVC, animated: true)
            case .operators:
                let registerOperatorVC = SBUViewControllerSet.GroupChannelRegisterOperatorViewController.init(channel: groupChannel)
                self.navigationController?.pushViewController(registerOperatorVC, animated: true)
            default:
                break
            }
        } else if let openChannel = self.channel as? OpenChannel {
            switch type {
            case .operators:
                let registerOperatorVC = SBUViewControllerSet.OpenChannelRegisterOperatorViewController.init(channel: openChannel)
                self.navigationController?.pushViewController(registerOperatorVC, animated: true)
            default:
                break
            }
            
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
        case is GroupChannel:
            guard SendbirdUI.config.common.isUsingDefaultUserProfileEnabled else { return }
            userProfileView.show(baseView: baseView, user: user)
            
        case is OpenChannel:
            guard SendbirdUI.config.common.isUsingDefaultUserProfileEnabled else { return }
            userProfileView.show(baseView: baseView, user: user, isOpenChannel: true)
            
        default: return
        }
    }
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - SBUUserListModuleHeaderDelegate
    open func userListModule(_ headerComponent: SBUUserListModule.Header,
                               didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func userListModule(_ headerComponent: SBUUserListModule.Header,
                               didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func userListModule(_ headerComponent: SBUUserListModule.Header,
                               didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func userListModule(_ headerComponent: SBUUserListModule.Header,
                               didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func userListModule(_ headerComponent: SBUUserListModule.Header,
                               didTapRightItem rightItem: UIBarButtonItem) {
        self.showInviteUser()
    }
    
    // MARK: - SBUUserListModuleListDelegate
    open func userListModule(_ listComponent: SBUUserListModule.List,
                               didSelectRowAt indexPath: IndexPath) { }
    
    open func userListModule(_ listComponent: SBUUserListModule.List,
                               didDetectPreloadingPosition indexPath: IndexPath) {
        self.viewModel?.preLoadNextUserList(indexPath: indexPath)
    }
    
    open func userListModule(_ listComponent: SBUUserListModule.List,
                               didTapMoreMenuFor user: SBUUser) {
        let userNameItem = SBUActionSheetItem(
            title: user.nickname ?? user.userId,
            color: self.componentTheme.actionSheetSubTextColor,
            textAlignment: .center,
            completionHandler: nil
        )
        
        var isOperator = user.isOperator
        if let channel = self.channel as? OpenChannel {
            isOperator = channel.isOperator(userId: user.userId)
        }
        
        let operatorItem = SBUActionSheetItem(
            title: isOperator || self.userListType == .operators
            ? SBUStringSet.UserList_Unregister_Operator
            : SBUStringSet.UserList_Register_Operator,
            color: self.componentTheme.actionSheetTextColor,
            textAlignment: .center
        ) { [weak self] in
            guard let self = self else { return }
            if isOperator || self.userListType == .operators {
                self.viewModel?.unregisterOperator(user: user)
            } else {
                self.viewModel?.registerAsOperator(user: user)
            }
        }
        let muteItem = SBUActionSheetItem(
            title: user.isMuted || self.userListType == .muted
            ? SBUStringSet.UserList_Unmute
            : SBUStringSet.UserList_Mute,
            color: self.componentTheme.actionSheetTextColor,
            textAlignment: .center
        ) { [weak self] in
            guard let self = self else { return }
            if user.isMuted || self.userListType == .muted {
                self.viewModel?.unmute(user: user)
            } else {
                self.viewModel?.mute(user: user)
            }
        }
        
        let banItem = SBUActionSheetItem(
            title: self.userListType == .banned
            ? SBUStringSet.UserList_Unban
            : SBUStringSet.UserList_Ban,
            color: self.userListType == .banned
            ? self.componentTheme.actionSheetTextColor
            : self.componentTheme.actionSheetErrorColor,
            textAlignment: .center
        ) { [weak self] in
            guard let self = self else { return }
            if self.userListType == .banned {
                self.viewModel?.unban(user: user)
            } else {
                self.viewModel?.ban(user: user)
            }
        }
        
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: self.componentTheme.actionSheetItemColor,
            completionHandler: nil)
        
        var items: [SBUActionSheetItem] = [userNameItem]
        
        var isBroadcast = false
        if let channel = self.channel as? GroupChannel {
            isBroadcast = channel.isBroadcast
        }
        
        switch self.userListType {
        case .members:
            items += isBroadcast ? [operatorItem, banItem] : [operatorItem, muteItem, banItem]
        case .participants:
            items += [operatorItem, muteItem, banItem]
        case .operators:
            items += [operatorItem]
        case .muted:
            items += [muteItem]
        case .banned:
            items += [banItem]
        default:
            break
        }
        
        SBUActionSheet.show(items: items, cancelItem: cancelItem, oneTimetheme: componentTheme)
    }
    
    open func userListModule(_ listComponent: SBUUserListModule.List,
                               didTapUserProfileFor user: SBUUser) {
        self.showUserProfile(with: user)
    }
    
    open func userListModuleDidSelectRetry(_ listComponent: SBUUserListModule.List) {
        self.viewModel?.loadNextUserList(reset: true)
    }
    
    // MARK: - SBUUserListModuleListDataSource
    open func userListModule(_ listComponent: SBUUserListModule.List,
                                 usersInTableView tableView: UITableView) -> [SBUUser] {
        return self.viewModel?.userList ?? []
    }
    open func userListModule(_ listComponent: SBUUserListModule.List,
                                 channelForTableView tableView: UITableView) -> BaseChannel? {
        return self.viewModel?.channel
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
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
    
    // MARK: - SBUUserListViewModelDelegate
    open func userListViewModel(_ viewModel: SBUUserListViewModel,
                                didChangeUsers users: [SBUUser],
                                needsToReload: Bool) {
        self.listComponent?.reloadTableView()
        self.updateStyles()
    }
    
    open func userListViewModel(_ viewModel: SBUUserListViewModel,
                                  didChangeChannel channel: BaseChannel?,
                                  withContext context: MessageContext) {
        self.listComponent?.reloadTableView()
    }
    
    open func userListViewModel(_ viewModel: SBUUserListViewModel,
                                shouldDismissForUserList channel: BaseChannel?) {
        if channel != nil {
            guard let channelVC = SendbirdUI.findChannelViewController(
                rootViewController: self.navigationController
            ) else { return }
            
            self.navigationController?.popToViewController(channelVC, animated: false)
        } else {
            guard let channelListVC = SendbirdUI.findChannelListViewController(
                rootViewController: self.navigationController,
                channelType: (self.channel is OpenChannel) ? .open : .group
            ) else { return }
            
            self.navigationController?.popToViewController(channelListVC, animated: false)
        }
    }
    
    // MARK: - SBUUSerListViewModelDataSource
    open func userListViewModel(_ viewModel: SBUUserListViewModel,
                                  nextUserListForChannel channel: BaseChannel?) -> [SBUUser]? {
        return nil
    }
}
