//
//  SBUGroupChannelSettingsViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
#if SWIFTUI
import SwiftUI
#endif

#if SWIFTUI
protocol GroupChannelSettingsViewEventDelegate: AnyObject {
    
}
#endif

open class SBUGroupChannelSettingsViewController: SBUBaseChannelSettingsViewController, SBUGroupChannelSettingsModuleHeaderDelegate, SBUGroupChannelSettingsModuleHeaderDataSource, SBUGroupChannelSettingsModuleListDelegate, SBUGroupChannelSettingsModuleListDataSource, SBUGroupChannelSettingsViewModelDelegate {
    
    // MARK: - UI Properties (Public)
    public var headerComponent: SBUGroupChannelSettingsModule.Header? {
        get { self.baseHeaderComponent as? SBUGroupChannelSettingsModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUGroupChannelSettingsModule.List? {
        get { self.baseListComponent as? SBUGroupChannelSettingsModule.List }
        set { self.baseListComponent = newValue }
    }
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUGroupChannelSettingsViewModel? {
        get { self.baseViewModel as? SBUGroupChannelSettingsViewModel }
        set { self.baseViewModel = newValue }
    }
    
    public override var channel: GroupChannel? { self.viewModel?.channel as? GroupChannel }
    
    // MARK: - SwiftUI
    #if SWIFTUI
    var memberListViewBuilder: GroupMemberListViewBuilder?
    var moderationsViewBuilder: GroupModerationsViewBuilder?
    var pushSettingsViewBuilder: GroupChannelPushSettingsViewBuilder?
    var messageSearchViewBuilder: MessageSearchViewBuilder?
    
    weak var swiftUIDelegate: (SBUGroupChannelSettingsViewModelDelegate & GroupChannelSettingsViewEventDelegate)? {
        didSet {
            self.viewModel?.delegates.addDelegate(self.swiftUIDelegate, type: .swiftui)
        }
    }
    #endif
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUGroupChannelSettingsViewController(channelURL:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUGroupChannelSettingsViewController(channelURL:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    required public init(channel: GroupChannel) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channel: channel)
        self.headerComponent = SBUModuleSet.GroupChannelSettingsModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.GroupChannelSettingsModule.ListComponent.init()
    }
    
    /// If you don't have channel object and have channelURL, use this initialize function.
    /// - Parameter channelURL: Channel url string
    required public init(channelURL: String) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channelURL: channelURL)
        self.headerComponent = SBUModuleSet.GroupChannelSettingsModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.GroupChannelSettingsModule.ListComponent.init()
    }
    
    // MARK: - ViewModel
    open override func createViewModel(channel: BaseChannel? = nil, channelURL: String? = nil) {
        self.baseViewModel = SBUViewModelSet.GroupChannelSettingsViewModel.init(
            channel: channel,
            channelURL: channelURL,
            delegate: self
        )
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.headerComponent?.leftBarButton
        self.navigationItem.leftBarButtonItems = self.headerComponent?.leftBarButtons
        self.updateRightBarButton()
        
        // List component
        self.listComponent?.configure(
            delegate: self,
            dataSource: self,
            theme: self.theme
        )
        
        if let listComponent = self.listComponent {
            self.view.addSubview(listComponent)
        }
    }
    
    #if SWIFTUI
    // To update table header view dynamically
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let tableView = self.listComponent?.tableView else { return }

        if let headerView = tableView.tableHeaderView {

            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    #endif
    
    // MARK: - Actions
    /// If you want to use a custom userListViewController, override it and implement it.
    open func showMemberList() {
        guard let channel = self.channel else { return }
        
        #if SWIFTUI
        if let memberListViewBuilder = self.memberListViewBuilder {
            let view = memberListViewBuilder(channel.channelURL)
            let memberListVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(memberListVC, animated: true)
            return
        }
        #endif
        let memberListVC = SBUViewControllerSet.GroupUserListViewController.init(
            channel: channel,
            userListType: .members
        )
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    open override func showSearch() {
        guard let channel = self.channel else { return }
        
        #if SWIFTUI
        if let messageSearchViewBuilder = self.messageSearchViewBuilder {
            let view = messageSearchViewBuilder(channel.channelURL)
            let searchView = UIHostingController(rootView: view)
            let nav = UINavigationController(rootViewController: searchView)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true) {
                self.needRollbackNavigationBarSetting = true
            }
            return
        }
        #endif
        
        self.needRollbackNavigationBarSetting = false
        let searchVC = SBUViewControllerSet.MessageSearchViewController.init(channel: channel)
        let nav = UINavigationController(rootViewController: searchVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true) {
            self.needRollbackNavigationBarSetting = true
        }
    }
    
    /// If you want to use a custom moderationsViewController, override it and implement it.
    /// - Since: 1.2.0
    open override func showModerationList() {
        guard let channel = self.channel else { return }
        
        #if SWIFTUI
        if let moderationsViewBuilder = self.moderationsViewBuilder {
            let view = moderationsViewBuilder(channel.channelURL)
            let moderationsVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(moderationsVC, animated: true)
            return
        }
        #endif
        let moderationsVC = SBUViewControllerSet.GroupModerationsViewController.init(channel: channel)
        self.navigationController?.pushViewController(moderationsVC, animated: true)
    }
    
    open override func showNotifications() {
        guard let channel = self.channel else { return }

        #if SWIFTUI
        if let pushSettingsViewBuilder = self.pushSettingsViewBuilder {
            let view = pushSettingsViewBuilder(channel.channelURL)
            let pushSettingsVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(pushSettingsVC, animated: true)
            return
        }
        #endif
        let pushSettingsVC = SBUViewControllerSet.GroupChannelPushSettingsViewController.init(channel: channel)
        self.navigationController?.pushViewController(pushSettingsVC, animated: true)
    }
    
    // MARK: - SBUGroupChannelSettingsModuleHeaderDelegate
    open func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header,
                                         didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header,
                                         didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header,
                                         didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) {
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    open func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) {
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    open func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header,
                                         didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header,
                                         didTapRightItem rightItem: UIBarButtonItem) {
        self.showChannelEditActionSheet()
    }
    
    // MARK: - SBUGroupChannelSettingsModuleHeaderDataSource
    open func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header,
                                         channelNameForTitleView titleView: UIView?) -> String? {
        return self.channelName
    }
    
    // MARK: - SBUGroupChannelSettingsModuleListDelegate
    open func groupChannelSettingsModule(_ listComponent: SBUGroupChannelSettingsModule.List,
                                         didSelectRowAt indexPath: IndexPath) {
    }
    
    open func groupChannelSettingsModuleDidSelectModerations(_ listComponent: SBUGroupChannelSettingsModule.List) {
        self.showModerationList()
    }
    
    open func groupChannelSettingsModuleDidSelectNotifications(_ listComponent: SBUGroupChannelSettingsModule.List) {
        self.showNotifications()
    }
    
    open func groupChannelSettingsModuleDidSelectMembers(_ listComponent: SBUGroupChannelSettingsModule.List) {
        self.showMemberList()
    }
    
    open func groupChannelSettingsModuleDidSelectSearch(_ listComponent: SBUGroupChannelSettingsModule.List) {
        self.showSearch()
    }
    
    open func groupChannelSettingsModuleDidSelectLeave(_ listComponent: SBUGroupChannelSettingsModule.List) {
        self.viewModel?.leaveChannel()
    }
    
    // MARK: - SBUGroupChannelSettingsModuleListDataSource
    open func baseChannelSettingsModule(_ listComponent: SBUBaseChannelSettingsModule.List,
                                        channelForTableView tableView: UITableView) -> BaseChannel? {
        return self.channel
    }
    
    open func baseChannelSettingsModuleIsOperator(_ listComponent: SBUBaseChannelSettingsModule.List) -> Bool {
        return self.viewModel?.isOperator ?? false
    }
    
    // MARK: - SBUGroupChannelSettingsViewModelDelegate
    open override func baseChannelSettingsViewModel(
        _ viewModel: SBUBaseChannelSettingsViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    ) {
        super.baseChannelSettingsViewModel(viewModel, didChangeChannel: channel, withContext: context)
        
        self.listComponent?.reloadChannelInfoView()
        self.listComponent?.reloadTableView()
    }
    
    open func groupChannelSettingsViewModel(_ viewModel: SBUGroupChannelSettingsViewModel,
                                            didLeaveChannel channel: GroupChannel) {
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.count > 1 else {
            if let dismissAction = self.dismissAction {
                dismissAction()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        
              return
        }
        
        for viewController in navigationController.viewControllers where viewController is SBUBaseChannelListViewController {
            navigationController.popToViewController(viewController, animated: true)
            return
        }
        
        navigationController.popToRootViewController(animated: true)
    }
}
