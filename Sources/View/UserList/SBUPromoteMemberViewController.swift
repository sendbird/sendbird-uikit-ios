//
//  SBUPromoteMemberViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/28.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

open class SBUPromoteMemberViewController: SBUBaseSelectUserViewController, SBUPromoteMemberViewModelDataSource, SBUPromoteMemberModuleListDataSource, SBUPromoteMemberModuleHeaderDataSource, SBUPromoteMemberModuleHeaderDelegate, SBUPromoteMemberModuleListDelegate, SBUPromoteMemberViewModelDelegate {

    // MARK: - UI Properties (Public)
    public var headerComponent: SBUPromoteMemberModule.Header? {
        get { self.baseHeaderComponent as? SBUPromoteMemberModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUPromoteMemberModule.List? {
        get { self.baseListComponent as? SBUPromoteMemberModule.List }
        set { self.baseListComponent = newValue }
    }

    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUPromoteMemberViewModel? {
        get { self.baseViewModel as? SBUPromoteMemberViewModel }
        set { self.baseViewModel = newValue }
    }
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUPromoteMemberViewController(channel:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUPromoteMemberViewController(channel:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// If you have channel and users objects, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - users: `SBUUser` object
    required public init(channel: SBDGroupChannel, users: [SBUUser]? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        self.createViewModel(channel: channel, users: users)
        self.headerComponent = SBUModuleSet.promoteMemberModule.headerComponent
        self.listComponent = SBUModuleSet.promoteMemberModule.listComponent
    }

    /// If you have channelUrl and users objects, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - users: `SBUUser` object
    required public init(channelUrl: String, users: [SBUUser]? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        self.createViewModel(channelUrl: channelUrl, users: users)
        self.headerComponent = SBUModuleSet.promoteMemberModule.headerComponent
        self.listComponent = SBUModuleSet.promoteMemberModule.listComponent
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
    open override func createViewModel(channel: SBDBaseChannel? = nil,
                                       channelUrl: String? = nil,
                                       channelType: SBDChannelType = .group,
                                       users: [SBUUser]? = nil) {
        guard channel != nil || channelUrl != nil else {
            SBULog.error("Either the channel or the channelUrl parameter must be set.")
            return
        }
        
        self.baseViewModel = SBUPromoteMemberViewModel (
            channel: channel,
            channelUrl: channelUrl,
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
    
    /// This function calls `promoteToOperators` function.
    public func promoteSelectedMembers() {
        guard !self.selectedUserList.isEmpty else { return }
        
        let selectedIds = Array(self.selectedUserList).sbu_getUserIds()
        self.viewModel?.promoteToOperators(memberIds: selectedIds)
    }
    
    
    // MARK: - SBUPromoteMemberModuleHeaderDelegate
    open func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header,
                                  didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header,
                                  didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header,
                                  didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header,
                                  didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header,
                                  didTapRightItem rightItem: UIBarButtonItem) {
        self.promoteSelectedMembers()
    }
    
    
    // MARK: - SBUPromoteMemberModuleHeaderDelegate
    open func promoteMemberModule(_ listComponent: SBUPromoteMemberModule.List,
                                  didSelectRowAt indexPath: IndexPath) {
        guard let user = self.viewModel?.userList[indexPath.row] else { return }
        self.viewModel?.selectUser(user: user)
    }
    
    open func promoteMemberModule(_ listComponent: SBUPromoteMemberModule.List,
                                  didDetectPreloadingPosition indexPath: IndexPath) {
        self.viewModel?.preLoadNextUserList(indexPath: indexPath)
    }
    
    open func promoteMemberModuleDidSelectRetry(_ listComponent: SBUPromoteMemberModule.List) {
        
    }
    
    
    // MARK: - SBUPromoteMemberViewModelDelegate
    open func promoteMemberViewModel(_ viewModel: SBUPromoteMemberViewModel,
                                     didPromoteMemberIds memberIds: [String]) {
        self.popToChannel()
    }
    
    open override func baseSelectedUserViewModel(_ viewModel: SBUBaseSelectUserViewModel,
                                                 didUpdateSelectedUsers selectedUsers: [SBUUser]?) {
        self.headerComponent?.updateRightBarButton()
    }
}
