//
//  SBUCreateChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

#if SWIFTUI
protocol CreateGroupChannelViewEventDelegate: AnyObject {
    func createGroupChannelView(didSelectRowAt indexPath: IndexPath)
}
#endif

open class SBUCreateChannelViewController: SBUBaseViewController, SBUCreateChannelModuleHeaderDelegate, SBUCreateChannelModuleHeaderDataSource, SBUCreateChannelModuleListDataSource, SBUCreateChannelModuleListDelegate, SBUCommonViewModelDelegate, SBUCreateChannelViewModelDataSource, SBUCreateChannelViewModelDelegate {
    
    // MARK: - UI properties (Public)
    public var headerComponent: SBUCreateChannelModule.Header?
    public var listComponent: SBUCreateChannelModule.List?
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.userListTheme)
    public var theme: SBUUserListTheme
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUCreateChannelViewModel?

    public var channelType: ChannelCreationType { viewModel?.channelType ?? .group }

    public var userList: [SBUUser] { viewModel?.userList ?? [] }
    public var selectedUserList: Set<SBUUser> { viewModel?.selectedUserList ?? [] }
    
    private var users: [SBUUser]? = nil
    private var type: ChannelCreationType = .group
    
    // MARK: - SwiftUI
    #if SWIFTUI
    weak var swiftUIDelegate: (SBUCreateChannelViewModelDelegate & CreateGroupChannelViewEventDelegate)? {
        didSet {
            self.viewModel?.delegates.addDelegate(self.swiftUIDelegate, type: .swiftui)
        }
    }
    #endif
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUCreateChannelViewController(type:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUCreateChannelViewController(type:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        self.createViewModel(type: .group)
        self.headerComponent = SBUModuleSet.CreateGroupChannelModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.CreateGroupChannelModule.ListComponent.init()
    }
    
    /// If you have user objects, use this initialize function.
    /// - Parameters:
    ///   - users: `SBUUser` array object
    ///   - type: The type of channel to create (default: `.group`)
    required public init(users: [SBUUser]? = nil, type: ChannelCreationType = .group) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.users = users
        self.type = type
        
        self.createViewModel(users: users, type: type)
        self.headerComponent = SBUModuleSet.CreateGroupChannelModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.CreateGroupChannelModule.ListComponent.init()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
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
    /// Creates view model.
    ///
    /// When the creation is completed, the channel load request is automatically executed.
    /// - Parameters:
    ///   - users: (optional) customized users list.
    ///   - type: Invite list type (`.users` | `.operators`)
    open func createViewModel(users: [SBUUser]? = nil,
                              type: ChannelCreationType = .group) {
        self.viewModel = SBUViewModelSet.CreateGroupChannelViewModel.init(
            channelType: type,
            users: users,
            delegate: self,
            dataSource: self
        )
    }

    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.headerComponent?.leftBarButton
        self.navigationItem.rightBarButtonItem = self.headerComponent?.rightBarButton
        self.navigationItem.leftBarButtonItems = self.headerComponent?.leftBarButtons
        self.navigationItem.rightBarButtonItems = self.headerComponent?.rightBarButtons
        
        // List component
        self.listComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        if let listComponent = self.listComponent {
            self.view.addSubview(listComponent)
        }
    }
    
    open override func setupLayouts() {
        self.listComponent?.sbu_constraint(
            equalTo: self.view,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            useSafeArea: true
        )
    }
    
    open override func setupStyles() {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationShadowColor
        )
        
        self.headerComponent?.setupStyles(theme: self.theme)
        self.listComponent?.setupStyles(theme: self.theme)
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        self.listComponent?.reloadTableView()
    }
    
    // MARK: - Actions
    /// This function creates channel using the `selectedUserList`.
    public func createChannelWithSelectedUsers() {
        guard !selectedUserList.isEmpty else { return }
        
        let userIds = Array(self.selectedUserList).sbu_getUserIds()
        self.viewModel?.createChannel(userIds: userIds)
    }
    
    // MARK: - Common
    /// This function dismisses `createViewController` and moves to created channel.
    /// - Parameters:
    ///   - channel: Created channel
    ///   - messageListParams: messageListParams
    /// - Since: 2.2.6
    open func dismissAndMoveToChannel(_ channel: BaseChannel,
                                      messageListParams: MessageListParams?) {
        SendbirdUI.moveToChannel(
            channelURL: channel.channelURL,
            messageListParams: messageListParams
        )
    }
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - SBUCreateChannelModuleHeaderDelegate
    open func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header,
                                  didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header,
                                  didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header,
                                  didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header,
                                  didUpdateLeftItems leftItems: [UIBarButtonItem]?) {
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    open func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header,
                                  didUpdateRightItems rightItems: [UIBarButtonItem]?) {
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    open func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header,
                                  didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header,
                                  didTapRightItem rightItem: UIBarButtonItem) {
        self.createChannelWithSelectedUsers()
    }
    
    // MARK: - SBUCreateChannelModuleHeaderDataSource
    open func selectedUsersForBaseSelectUserModule(_ headerComponent: SBUBaseSelectUserModule.Header) -> Set<SBUUser>? {
        return self.viewModel?.selectedUserList
    }
    
    // MARK: - SBUCreateChannelModuleListDataSource
    open func baseSelectUserModule(_ listComponent: SBUBaseSelectUserModule.List, usersInTableView tableView: UITableView) -> [SBUUser]? {
        return self.viewModel?.userList
    }
    
    open func baseSelectUserModule(_ listComponent: SBUBaseSelectUserModule.List, selectedUsersInTableView tableView: UITableView) -> Set<SBUUser>? {
        return self.viewModel?.selectedUserList
    }
    
    // MARK: - SBUCreateChannelModuleListDelegate
    open func createChannelModule(_ listComponent: SBUCreateChannelModule.List,
                                  didSelectRowAt indexPath: IndexPath) {
        guard let user = self.viewModel?.userList[indexPath.row] else { return }
        self.viewModel?.selectUser(user: user)
        
        #if SWIFTUI
        self.swiftUIDelegate?.createGroupChannelView(didSelectRowAt: indexPath)
        #endif
    }
    
    open func createChannelModule(_ listComponent: SBUCreateChannelModule.List, didDetectPreloadingPosition indexPath: IndexPath) {
        self.viewModel?.preLoadNextUserList(indexPath: indexPath)
    }
    
    open func createChannelModuleDidSelectRetry(_ listComponent: SBUCreateChannelModule.List) {
        
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.localizedDescription)
        
        if isBlocker {
            self.listComponent?.updateEmptyView(type: .error)
            self.listComponent?.reloadTableView()
        }
    }
    
    // MARK: - SBUCreateChannelViewModelDataSource
    open func createChannelViewModel(_ viewModel: SBUCreateChannelViewModel, nextUserListForChannelType channelType: ChannelCreationType) -> [SBUUser]? {
        return nil
    }
    
    // MARK: - SBUCreateChannelViewModelDelegate
    open func createChannelViewModel(
        _ viewModel: SBUCreateChannelViewModel,
        didChangeUsers users: [SBUUser],
        needsToReload: Bool
    ) {
        let emptyType: EmptyViewType = users.count == 0 ? .noMembers : .none
        self.listComponent?.updateEmptyView(type: emptyType)
        
        guard needsToReload else { return }
        self.listComponent?.reloadTableView()
    }
    
    open func didUpdateSelectedUsers(_ selectedUsers: [SBUUser]?) {
        self.headerComponent?.updateRightBarButton()
    }
    
    open func createChannelViewModel(
        _ viewModel: SBUCreateChannelViewModel,
        didCreateChannel channel: BaseChannel?,
        withMessageListParams messageListParams: MessageListParams?
    ) {
        guard let channelURL = channel?.channelURL else {
            SBULog.error("[Failed] Create channel request: There is no channel url.")
            return
        }
        SendbirdUI.moveToChannel(channelURL: channelURL, messageListParams: messageListParams)
    }
    
    open func createChannelViewModel(
        _ viewModel: SBUCreateChannelViewModel,
        didUpdateSelectedUsers selectedUsers: [SBUUser]
    ) {
        var didApplyRightBarButtonViewConverter = false

        #if SWIFTUI
        didApplyRightBarButtonViewConverter = self.headerComponent?.applyViewConverter(.rightView) ?? false
        self.listComponent?.applyViewConverter(.entireContent)
        #endif
        
        if !didApplyRightBarButtonViewConverter {
            self.headerComponent?.updateRightBarButton()
        }
    }
}

#if SWIFTUI
extension SBUCreateChannelViewController {
    public func createChannelModule(
        _ listComponent: SBUCreateChannelModule.List,
        didSelectUser user: SBUUser
    ) {
        self.viewModel?.selectUser(user: user)
    }
}
#endif
