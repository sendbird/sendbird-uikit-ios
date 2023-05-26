//
//  SBUOpenChannelSettingsViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/11/09.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUOpenChannelSettingsViewController: SBUBaseChannelSettingsViewController, SBUOpenChannelSettingsModuleHeaderDelegate, SBUOpenChannelSettingsModuleListDelegate, SBUOpenChannelSettingsModuleListDataSource, SBUOpenChannelSettingsViewModelDelegate {
    
    // MARK: - UI Properties (Public)
    public var headerComponent: SBUOpenChannelSettingsModule.Header? {
        get { self.baseHeaderComponent as? SBUOpenChannelSettingsModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUOpenChannelSettingsModule.List? {
        get { self.baseListComponent as? SBUOpenChannelSettingsModule.List }
        set { self.baseListComponent = newValue }
    }
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUOpenChannelSettingsViewModel? {
        get { self.baseViewModel as? SBUOpenChannelSettingsViewModel }
        set { self.baseViewModel = newValue }
    }
    
    public override var channel: OpenChannel? { self.viewModel?.channel as? OpenChannel }
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUOpenChannelSettingsViewController(channelURL:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUOpenChannelSettingsViewController(channelURL:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    required public init(channel: OpenChannel) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channel: channel)
        self.headerComponent = SBUModuleSet.openChannelSettingsModule.headerComponent
        self.listComponent = SBUModuleSet.openChannelSettingsModule.listComponent
    }
    
    /// If you don't have channel object and have channelURL, use this initialize function.
    /// - Parameter channelURL: Channel url string
    required public init(channelURL: String) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channelURL: channelURL)
        self.headerComponent = SBUModuleSet.openChannelSettingsModule.headerComponent
        self.listComponent = SBUModuleSet.openChannelSettingsModule.listComponent
    }
    
    // MARK: - ViewModel
    open override func createViewModel(channel: BaseChannel? = nil, channelURL: String? = nil) {
        self.baseViewModel = SBUOpenChannelSettingsViewModel(
            channel: channel,
            channelURL: channelURL,
            delegate: self
        )
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(delegate: self, theme: self.theme)
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.headerComponent?.leftBarButton
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
    
    // MARK: - Actions
    /// If you want to use a custom userListViewController, override it and implement it.
    open func showParticipantsList() {
        guard let channel = self.channel else { return }
        
        let participantListVC = SBUViewControllerSet.OpenUserListViewController.init(channel: channel, userListType: .participants)
        self.navigationController?.pushViewController(participantListVC, animated: true)
    }
    
    /// If you want to use a custom moderationsViewController, override it and implement it.
    /// - Since: 3.1.0
    open override func showModerationList() {
        guard let channel = self.channel else { return }
        
        let moderationsVC = SBUViewControllerSet.OpenModerationsViewController.init(channel: channel)
        self.navigationController?.pushViewController(moderationsVC, animated: true)
    }

    /// Shows deletes channel confirm alert.
    /// - Since: 3.1.0
    open func showDeleteChannelAlert() {
        let deleteButton = SBUAlertButtonItem(
            title: SBUStringSet.Delete,
            color: self.theme.itemDeleteTextColor) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel?.deleteChannel()
            }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
        
        SBUAlertView.show(
            title: SBUStringSet.ChannelSettings_Delete_Question_Mark,
            message: SBUStringSet.ChannelSettings_Delete_Description,
            needInputField: false,
            confirmButtonItem: deleteButton,
            cancelButtonItem: cancelButton,
            delegate: self
        )
    }
    
    // MARK: - SBUOpenChannelSettingsModuleHeaderDelegate
    open func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header,
                                        didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header,
                                        didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header,
                                        didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header,
                                        didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header,
                                        didTapRightItem rightItem: UIBarButtonItem) {
        self.showChannelEditActionSheet()
    }
    
    // MARK: - SBUOpenChannelSettingsModuleListDelegate
    open func openChannelSettingsModule(_ listComponent: SBUOpenChannelSettingsModule.List,
                                        didSelectRowAt indexPath: IndexPath) {
    }
    
    open func openChannelSettingsModuleDidSelectModerations(_ listComponent: SBUOpenChannelSettingsModule.List) {
        self.showModerationList()
    }
    
    open func openChannelSettingsModuleDidSelectParticipants(_ listComponent: SBUOpenChannelSettingsModule.List) {
        self.showParticipantsList()
    }
    
    open func openChannelSettingsModuleDidSelectDelete(_ listComponent: SBUOpenChannelSettingsModule.List) {
        self.showDeleteChannelAlert()
    }
    
    // MARK: - SBUOpenChannelSettingsModuleListDataSource
    open func baseChannelSettingsModule(_ listComponent: SBUBaseChannelSettingsModule.List,
                                        channelForTableView tableView: UITableView) -> BaseChannel? {
        return self.channel
    }
    
    open func baseChannelSettingsModuleIsOperator(_ listComponent: SBUBaseChannelSettingsModule.List) -> Bool {
        return self.viewModel?.isOperator ?? false
    }
    
    // MARK: - SBUOpenChannelSettingsViewModelDelegate
    open func openChannelSettingsViewModel(_ viewModel: SBUOpenChannelSettingsViewModel,
                                           didDeleteChannel channel: OpenChannel) {
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.count > 1 else {
                  self.dismiss(animated: true, completion: nil)
                  return
              }
        
        for vc in navigationController.viewControllers where vc is SBUBaseChannelListViewController {
            navigationController.popToViewController(vc, animated: true)
            return
        }
        
        navigationController.popToRootViewController(animated: true)
    }
    
    open override func baseChannelSettingsViewModel(
        _ viewModel: SBUBaseChannelSettingsViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    ) {
        super.baseChannelSettingsViewModel(viewModel, didChangeChannel: channel, withContext: context)
        
        self.listComponent?.reloadChannelInfoView()
        self.listComponent?.reloadTableView()
    }
    
    // MARK: - SBUAlertViewDelegate
    open override func didDismissAlertView() { }
}
