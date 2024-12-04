//
//  SBUGroupChannelPushSettingsViewController.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

#if SWIFTUI
protocol GroupChannelPushSettingsViewEventDelegate: AnyObject {
    
}
#endif

// swiftlint:disable type_name
open class SBUGroupChannelPushSettingsViewController: SBUBaseViewController, SBUGroupChannelPushSettingsViewModelDelegate, SBUGroupChannelPushSettingsModuleHeaderDelegate, SBUGroupChannelPushSettingsModuleListDelegate, SBUGroupChannelPushSettingsModuleListDataSource {
    // swiftlint:enable type_name

    // MARK: - UI properties (Public)
    public var headerComponent: SBUGroupChannelPushSettingsModule.Header?
    public var listComponent: SBUGroupChannelPushSettingsModule.List?
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.channelSettingsTheme)
    public var theme: SBUChannelSettingsTheme
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var componentTheme: SBUComponentTheme
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUGroupChannelPushSettingsViewModel?
    
    public var channel: BaseChannel? { viewModel?.channel }
    public var channelURL: String? { viewModel?.channelURL }
    
    // MARK: - SwiftUI
    #if SWIFTUI
    weak var swiftUIDelegate: (SBUGroupChannelPushSettingsViewModelDelegate & GroupChannelPushSettingsViewEventDelegate)? {
        didSet {
            self.viewModel?.baseDelegates.addDelegate(self.swiftUIDelegate, type: .swiftui)
        }
    }
    #endif
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUGroupChannelPushSettingsViewController(channelURL:type:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUGroupChannelPushSettingsViewController.init(channelURL:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
        fatalError()
    }
    
    required public init(channel: BaseChannel) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channel: channel)
        
        self.headerComponent = SBUModuleSet.GroupChannelPushSettingsModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.GroupChannelPushSettingsModule.ListComponent.init()
    }
    
    required public init(channelURL: String) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channelURL: channelURL)
        
        self.headerComponent = SBUModuleSet.GroupChannelPushSettingsModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.GroupChannelPushSettingsModule.ListComponent.init()
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
    }
    
    // MARK: - ViewModel
    open func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil
    ) {
        self.viewModel = .init(
            channel: channel,
            channelURL: channelURL,
            delegate: self
        )
    }
    
    // MARK: Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(
            delegate: self,
            theme: self.theme,
            componentTheme: self.componentTheme
        )
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.headerComponent?.leftBarButton
        self.navigationItem.rightBarButtonItem = self.headerComponent?.rightBarButton
        self.navigationItem.leftBarButtonItems = self.headerComponent?.leftBarButtons
        self.navigationItem.rightBarButtonItems = self.headerComponent?.rightBarButtons
        
        // List component
        self.listComponent?.configure(
            delegate: self,
            dataSource: self,
            theme: self.theme
        )
        
        if let listComponent = listComponent {
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
        
        self.headerComponent?.setupStyles(
            theme: self.theme,
            componentTheme: self.componentTheme
        )
        self.listComponent?.setupStyles(theme: self.theme)
        
        self.view.backgroundColor = self.theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        self.listComponent?.reloadTableView()
    }
    
    // MARK: - ViewModel Delegate
    open func groupChannelPushSettingsViewModel(_ viewModel: SBUGroupChannelPushSettingsViewModel, didChangeNotification pushTriggerOption: GroupChannelPushTriggerOption) {
        self.listComponent?.reloadTableView()
    }
    
    open func baseChannelSettingsViewModel(_ viewModel: SBUBaseChannelSettingsViewModel, didChangeChannel channel: BaseChannel?, withContext context: MessageContext) {
        self.viewModel?.updateChannelPushTriggerOption()
    }
    
    open func baseChannelSettingsViewModel(_ viewModel: SBUBaseChannelSettingsViewModel, shouldDismissForChannelSettings channel: BaseChannel?) {
        guard let channelVC = SendbirdUI.findChannelViewController(
            rootViewController: self.navigationController
        ) else { return }
        
        self.navigationController?.popToViewController(channelVC, animated: false)
    }
    
    // MARK: - SBUGroupChannelPushSettingsModuleHeaderDelegate
    open func groupChannelPushSettingsModule(_ headerComponent: SBUGroupChannelPushSettingsModule.Header, didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func groupChannelPushSettingsModule(_ headerComponent: SBUGroupChannelPushSettingsModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func groupChannelPushSettingsModule(_ headerComponent: SBUGroupChannelPushSettingsModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func groupChannelPushSettingsModule(_ headerComponent: SBUGroupChannelPushSettingsModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) {
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    open func groupChannelPushSettingsModule(_ headerComponent: SBUGroupChannelPushSettingsModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) {
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    open func groupChannelPushSettingsModule(_ headerComponent: SBUGroupChannelPushSettingsModule.Header, didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func groupChannelPushSettingsModule(_ headerComponent: SBUGroupChannelPushSettingsModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        // NOTE: Do nothing as defaults
    }
    
    // MARK: - SBUGroupChannelPushSettingsModuleListDelegate
    open func groupChannelPushSettingsModule(
        _ listComponent: SBUGroupChannelPushSettingsModule.List,
        didChangeNotification pushTriggerOption: GroupChannelPushTriggerOption
    ) {
        self.viewModel?.changeNotification(pushTriggerOption)
    }
    
    // MARK: - SBUGroupChannelPushSettingsModuleListDataSource
    open func groupChannelPushSettingsModule(
        _ listComponent: SBUGroupChannelPushSettingsModule.List,
        pushTriggerOptionForTableView tableView: UITableView
    ) -> GroupChannelPushTriggerOption? {
        return self.viewModel?.currentTriggerOption
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.description ?? "")
    }
}
