//
//  SBURegisterOperatorViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/28.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

#if SWIFTUI
protocol RegisterOperatorViewEventDelegate: AnyObject {
    func registerOperatorView(didSelectRowAt indexPath: IndexPath)
}
#endif

open class SBURegisterOperatorViewController: SBUBaseSelectUserViewController, SBURegisterOperatorViewModelDataSource, SBURegisterOperatorModuleListDataSource, SBURegisterOperatorModuleHeaderDataSource, SBURegisterOperatorModuleHeaderDelegate, SBURegisterOperatorModuleListDelegate, SBURegisterOperatorViewModelDelegate {

    // MARK: - UI Properties (Public)
    public var headerComponent: SBURegisterOperatorModule.Header? {
        get { self.baseHeaderComponent as? SBURegisterOperatorModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBURegisterOperatorModule.List? {
        get { self.baseListComponent as? SBURegisterOperatorModule.List }
        set { self.baseListComponent = newValue }
    }
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBURegisterOperatorViewModel? {
        get { self.baseViewModel as? SBURegisterOperatorViewModel }
        set { self.baseViewModel = newValue }
    }
    
    // MARK: - SwiftUI
    #if SWIFTUI
    weak var swiftUIDelegate: (SBURegisterOperatorViewModelDelegate & RegisterOperatorViewEventDelegate)? {
        didSet {
            self.viewModel?.baseDelegates.addDelegate(swiftUIDelegate, type: .swiftui)
        }
    }
    #endif
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBURegisterOperatorViewController(channel:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBURegisterOperatorViewController(channel:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// If you have channel and users objects, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - users: `SBUUser` object
    required public init(channel: BaseChannel, users: [SBUUser]? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channel: channel, channelType: channelType, users: users)
        
        self.setupComponents(channelType: channel.channelType)
    }

    /// If you have channelURL and users objects, use this initialize function.
    /// - Parameters:
    ///   - channelURL: Channel url string
    ///   - channelType: Channel type
    ///   - users: `SBUUser` object
    required public init(channelURL: String, channelType: ChannelType = .group, users: [SBUUser]? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        self.createViewModel(channelURL: channelURL, channelType: channelType, users: users)
        
        self.setupComponents(channelType: channelType)
    }
    
    open func setupComponents(channelType: ChannelType) {
        if channelType == .group {
            self.headerComponent = SBUModuleSet.GroupRegisterOperatorModule.HeaderComponent.init()
            self.listComponent = SBUModuleSet.GroupRegisterOperatorModule.ListComponent.init()
        } else if channelType == .open {
            self.headerComponent = SBUModuleSet.OpenRegisterOperatorModule.HeaderComponent.init()
            self.listComponent = SBUModuleSet.OpenRegisterOperatorModule.ListComponent.init()
        }
        self.headerComponent?.channelType = channelType
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
    open override func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        channelType: ChannelType = .group,
        users: [SBUUser]? = nil
    ) {
        guard channel != nil || channelURL != nil else {
            SBULog.error("Either the channel or the channelURL parameter must be set.")
            return
        }
        
        var channelType = channelType
        if let channel = channel {
            channelType = (channel is GroupChannel) ? .group : .open
        }
        
        let viewModelType = (channelType == .group)
        ? SBUViewModelSet.GroupChannelRegisterOperatorViewModel
        : SBUViewModelSet.OpenChannelRegisterOperatorViewModel
        
        self.baseViewModel = viewModelType.init(
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
        self.navigationItem.leftBarButtonItems = self.headerComponent?.leftBarButtons
        self.navigationItem.rightBarButtonItems = self.headerComponent?.rightBarButtons
        
        // List component
        self.listComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        if let listComponent = self.listComponent {
            self.view.addSubview(listComponent)
        }
    }
    
    // MARK: - Actions
    
    /// This function calls `registerAsOperators` function.
    public func registerSelectedUsers() {
        guard !self.selectedUserList.isEmpty else { return }
        
        let selectedIds = Array(self.selectedUserList).sbu_getUserIds()
        self.viewModel?.registerAsOperators(userIds: selectedIds)
    }
    
    // MARK: - SBURegisterOperatorModuleHeaderDelegate
    open func registerOperatorModule(
        _ headerComponent: SBURegisterOperatorModule.Header,
        didUpdateTitleView titleView: UIView?
    ) {
        self.navigationItem.titleView = titleView
    }
    
    open func registerOperatorModule(
        _ headerComponent: SBURegisterOperatorModule.Header,
        didUpdateLeftItem leftItem: UIBarButtonItem?
    ) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func registerOperatorModule(
        _ headerComponent: SBURegisterOperatorModule.Header,
        didUpdateRightItem rightItem: UIBarButtonItem?
    ) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func registerOperatorModule(
        _ headerComponent: SBURegisterOperatorModule.Header,
        didUpdateLeftItems leftItems: [UIBarButtonItem]?
    ) {
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    open func registerOperatorModule(
        _ headerComponent: SBURegisterOperatorModule.Header,
        didUpdateRightItems rightItems: [UIBarButtonItem]?
    ) {
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    open func registerOperatorModule(
        _ headerComponent: SBURegisterOperatorModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    ) {
        self.onClickBack()
    }
    
    open func registerOperatorModule(
        _ headerComponent: SBURegisterOperatorModule.Header,
        didTapRightItem rightItem: UIBarButtonItem
    ) {
        self.registerSelectedUsers()
    }
    
    // MARK: - SBURegisterOperatorModuleHeaderDelegate
    open func registerOperatorModule(
        _ listComponent: SBURegisterOperatorModule.List,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let user = self.viewModel?.userList[indexPath.row] else { return }
        self.viewModel?.selectUser(user: user)
        
        #if SWIFTUI
        self.swiftUIDelegate?.registerOperatorView(didSelectRowAt: indexPath)
        #endif
    }
    
    open func registerOperatorModule(
        _ listComponent: SBURegisterOperatorModule.List,
        didDetectPreloadingPosition indexPath: IndexPath
    ) {
        self.viewModel?.preLoadNextUserList(indexPath: indexPath)
    }
    
    open func registerOperatorModuleDidSelectRetry(_ listComponent: SBURegisterOperatorModule.List) {
        
    }
    
    // MARK: - SBURegisterOperatorViewModelDelegate
    open func registerOperatorViewModel(
        _ viewModel: SBURegisterOperatorViewModel,
        didRegisterOperatorIds operatorIds: [String]
    ) {
        self.popToChannel()
    }
    
    open override func baseSelectedUserViewModel(
        _ viewModel: SBUBaseSelectUserViewModel,
        didUpdateSelectedUsers selectedUsers: [SBUUser]?
    ) {
        self.headerComponent?.updateRightBarButton()
    }
}
