//
//  SBUInviteUserViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUInviteUserViewController: SBUBaseSelectUserViewController, SBUInviteUserViewModelDataSource, SBUInviteUserModuleListDataSource, SBUInviteUserModuleHeaderDataSource, SBUInviteUserModuleHeaderDelegate, SBUInviteUserModuleListDelegate, SBUInviteUserViewModelDelegate {
    
    // MARK: - UI Properties (Public)
    public var headerComponent: SBUInviteUserModule.Header? {
        get { self.baseHeaderComponent as? SBUInviteUserModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUInviteUserModule.List? {
        get { self.baseListComponent as? SBUInviteUserModule.List }
        set { self.baseListComponent = newValue }
    }
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUInviteUserViewModel? {
        get { self.baseViewModel as? SBUInviteUserViewModel }
        set { self.baseViewModel = newValue }
    }
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUInviteUserViewController(channel:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUInviteUserViewController(channel:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// If you have channel and users objects, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - users: `SBUUser` object
    required public init(channel: GroupChannel, users: [SBUUser]? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        self.createViewModel(channel: channel, users: users)
        self.headerComponent = SBUModuleSet.inviteUserModule.headerComponent
        self.listComponent = SBUModuleSet.inviteUserModule.listComponent
    }
    
    /// If you have channelURL and users objects, use this initialize function.
    /// - Parameters:
    ///   - channelURL: Channel url string
    ///   - users: `SBUUser` object
    required public init(channelURL: String, users: [SBUUser]? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        self.createViewModel(channelURL: channelURL, users: users)
        self.headerComponent = SBUModuleSet.inviteUserModule.headerComponent
        self.listComponent = SBUModuleSet.inviteUserModule.listComponent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    deinit {
        SBULog.info("")
    }
    
    // MARK: - ViewModel
    open override func createViewModel(channel: BaseChannel? = nil,
                                       channelURL: String? = nil,
                                       channelType: ChannelType = .group,
                                       users: [SBUUser]? = nil) {
        guard channel != nil || channelURL != nil else {
            SBULog.error("Either the channel or the channelURL parameter must be set.")
            return
        }
        
        self.baseViewModel = SBUInviteUserViewModel(
            channel: channel,
            channelURL: channelURL,
            channelType: channelType,
            users: users,
            delegate: self,
            dataSource: self
        )
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        super.setupViews()
        
        // Header component
        self.headerComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.headerComponent?.leftBarButton
        self.navigationItem.rightBarButtonItem = self.headerComponent?.rightBarButton
        
        // List component
        self.listComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        if let listComponent = self.listComponent {
            self.view.addSubview(listComponent)
        }
    }
    
    // MARK: - Actions
    
    /// This function invites selected users.
    /// - Since: 3.0.0
    public func inviteSelectedUsers() {
        guard !self.selectedUserList.isEmpty else { return }
        
        let selectedIds = Array(self.selectedUserList).sbu_getUserIds()
        self.viewModel?.invite(userIds: selectedIds)
    }
    
    // MARK: - SBUInviteUserModuleHeaderDelegate
    open func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header,
                               didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header,
                               didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header,
                               didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header,
                               didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header,
                               didTapRightItem rightItem: UIBarButtonItem) {
        self.inviteSelectedUsers()
    }
    
    // MARK: - SBUInviteUserModuleListDelegate
    open func inviteUserModule(_ listComponent: SBUInviteUserModule.List,
                               didSelectRowAt indexPath: IndexPath) {
        guard let user = self.viewModel?.userList[indexPath.row] else { return }
        self.viewModel?.selectUser(user: user)
    }
    
    open func inviteUserModule(_ listComponent: SBUInviteUserModule.List,
                               didDetectPreloadingPosition indexPath: IndexPath) {
        self.viewModel?.preLoadNextUserList(indexPath: indexPath)
    }
    
    open func inviteUserModuleDidSelectRetry(_ listComponent: SBUInviteUserModule.List) {
        
    }
    
    // MARK: - SBUInviteUserViewModelDelegate
    open func inviteUserViewModel(_ viewModel: SBUInviteUserViewModel,
                                  didInviteUserIds userIds: [String]) {
        self.popToChannel()
    }
    
    open override func baseSelectedUserViewModel(_ viewModel: SBUBaseSelectUserViewModel,
                                                 didUpdateSelectedUsers selectedUsers: [SBUUser]?) {
        self.headerComponent?.updateRightBarButton()
    }
}
