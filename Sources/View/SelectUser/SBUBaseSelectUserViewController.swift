//
//  SBUBaseSelectUserViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/28.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUBaseSelectUserViewController: SBUBaseViewController, SBUBaseSelectUserModuleHeaderDataSource, SBUBaseSelectUserModuleListDataSource, SBUCommonViewModelDelegate, SBUBaseSelectUserViewModelDataSource, SBUBaseSelectUserViewModelDelegate {
    
    // MARK: - UI properties (Public)
    public var baseHeaderComponent: SBUBaseSelectUserModule.Header?
    public var baseListComponent: SBUBaseSelectUserModule.List?
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.userListTheme)
    public var theme: SBUUserListTheme
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var componentTheme: SBUComponentTheme
    
    // MARK: - Logic properties (Public)
    public var baseViewModel: SBUBaseSelectUserViewModel?
    
    public var channel: BaseChannel? { baseViewModel?.channel }
    public var channelURL: String? { baseViewModel?.channelURL }
    public var channelType: ChannelType { baseViewModel?.channelType ?? .group }
    
    public var userList: [SBUUser] { baseViewModel?.userList ?? [] }
    public var selectedUserList: Set<SBUUser> { baseViewModel?.selectedUserList ?? [] }
    
    // MARK: - Lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        self.theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.baseViewModel = nil
        self.baseHeaderComponent = nil
        self.baseListComponent = nil
    }
    
    // MARK: - ViewModel
    /// Creates view model.
    ///
    /// When the creation is completed, the channel load request is automatically executed.
    /// - Parameters:
    ///   - channel: (opt) Channel object
    ///   - channelURL: (opt) ChannelURL object
    ///   - users: (opt) users object.
    ///   - type: Invite list type (`.users` | `.operators`)
    open func createViewModel(channel: BaseChannel? = nil,
                              channelURL: String? = nil,
                              channelType: ChannelType = .group,
                              users: [SBUUser]? = nil) { }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupLayouts() {
        self.baseListComponent?.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationShadowColor
        )
        
        self.baseHeaderComponent?.setupStyles(theme: self.theme, componentTheme: self.componentTheme)
        self.baseListComponent?.setupStyles(theme: self.theme)
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        self.baseListComponent?.reloadTableView()
    }
    
    // MARK: - Actions
    
    /// This function is used to pop to channelViewController.
    open func popToChannel() {
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.count > 1 else {
                  self.dismiss(animated: true, completion: nil)
                  return
              }
        
        for vc in navigationController.viewControllers where vc is SBUBaseChannelViewController {
            navigationController.popToViewController(vc, animated: true)
            return
        }
        
        navigationController.popToRootViewController(animated: true)
    }
    
    /// This function is used to pop to previous viewController.
    public func popToPrevious() {
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.count > 1 else {
                  self.dismiss(animated: true, completion: nil)
                  return
              }
        
        navigationController.popViewController(animated: true)
    }
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - SBUBaseSelectUserModuleHeaderDataSource
    open func selectedUsersForBaseSelectUserModule(_ headerComponent: SBUBaseSelectUserModule.Header) -> Set<SBUUser>? {
        return self.baseViewModel?.selectedUserList
    }
    
    // MARK: - SBUBaseSelectUserModuleListDataSource
    open func baseSelectUserModule(_ listComponent: SBUBaseSelectUserModule.List,
                                   usersInTableView tableView: UITableView) -> [SBUUser]? {
        return self.baseViewModel?.userList
    }
    
    open func baseSelectUserModule(_ listComponent: SBUBaseSelectUserModule.List,
                                   selectedUsersInTableView tableView: UITableView) -> Set<SBUUser>? {
        return self.baseViewModel?.selectedUserList
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.localizedDescription)
        
        if isBlocker {
            self.baseListComponent?.updateEmptyView(type: .error)
            self.baseListComponent?.reloadTableView()
        }
    }
    
    // MARK: - SBUBaseSelectUserViewModelDataSource
    /// When creating and using a user list directly, overriding this function and return the next user list.
    /// Make this function return the next list each time it is called.
    /// - Important: If you want to use this function, please set the `SBUBaseSelectUserViewModelDataSource` in your class.
    ///
    /// - Returns: next user list
    /// - Since: 1.1.1
    open func nextUserList() -> [SBUUser]? {
        return nil
    }
    
    // MARK: - SBUBaseSelectUserViewModelDelegate
    open func baseSelectedUserViewModel(_ viewModel: SBUBaseSelectUserViewModel,
                                        didChangeUserList users: [SBUUser]?,
                                        needsToReload: Bool) {
        if let users = users {
            let emptyType: EmptyViewType = users.count == 0 ? .noMembers : .none
            self.baseListComponent?.updateEmptyView(type: emptyType)
        }
        
        guard needsToReload else { return }
        self.baseListComponent?.reloadTableView()
    }
    
    open func baseSelectedUserViewModel(_ viewModel: SBUBaseSelectUserViewModel,
                                        didUpdateSelectedUsers selectedUsers: [SBUUser]?) {
        self.baseHeaderComponent?.updateRightBarButton()
    }
}
