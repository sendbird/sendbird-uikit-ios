//
//  SBUModerationsViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUModerationsViewController: SBUBaseViewController {
    
    // MARK: - UI properties (Public)
    public var titleView: UIView? = nil {
        didSet {
            self.navigationItem.titleView = self.titleView
        }
    }
    public var leftBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        }
    }
    public var rightBarButton: UIBarButtonItem? = nil {
        didSet {
                self.navigationItem.rightBarButtonItem = self.rightBarButton
        }
    }
    public private(set) lazy var tableView = UITableView()
    
    public var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme

    
    // MARK: - UI properties (Private)
    private lazy var defaultTitleView: SBUNavigationTitleView = {
        var titleView: SBUNavigationTitleView
        if #available(iOS 11, *) {
            titleView = SBUNavigationTitleView()
        } else {
            titleView = SBUNavigationTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        titleView.text = SBUStringSet.ChannelSettings_Moderations
        titleView.textAlignment = .left
        
        return titleView
    }()
    
    private lazy var backButton: UIBarButtonItem = SBUCommonViews.backButton(
        vc: self,
        selector: #selector(onClickBack)
    )
    
    
    // MARK: - Logic properties (Public)
    public private(set) var channel: SBDGroupChannel?
    public private(set) var channelUrl: String?
    
    
    // MARK: - Logic properties (Private)
    
    private var channelActionViewModel: SBUChannelActionViewModel = SBUChannelActionViewModel() {
        willSet { self.disposeViewModel() }
        didSet { self.bindViewModel() }
    }
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUModerationsViewController(channel:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    public init(channel: SBDGroupChannel) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channel = channel
        self.channelUrl = channel.channelUrl
        
        self.bindViewModel()
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameter channelUrl: Channel url string
    public init(channelUrl: String) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        
        self.bindViewModel()
        self.loadChannel(channelUrl: channelUrl)
    }
    
    open override func loadView() {
        super.loadView()
        SBULog.info("")
        
        if self.titleView == nil {
            self.titleView = self.defaultTitleView
        }
        if self.leftBarButton == nil {
            self.leftBarButton = self.backButton
        }
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.titleView = self.titleView
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.register(
            type(of: SBUModerationCell()),
            forCellReuseIdentifier: SBUModerationCell.sbu_className
        )
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)
        
        // autolayout
        self.setupAutolayout()
        
        // styles
        self.setupStyles()
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupAutolayout() {
        self.tableView.sbu_constraint(
            equalTo: self.view,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0
        )
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor), for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )
        
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.theme = SBUTheme.channelSettingsTheme
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUNavigationTitleView {
            titleView.setupStyles()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if let channelUrl = self.channel?.channelUrl {
            self.loadChannel(channelUrl: channelUrl)
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateStyles()
    }
    
    deinit {
        self.disposeViewModel()
    }
    
    
    // MARK: - ViewModel
    
    private func bindViewModel() {
        self.channelActionViewModel.errorObservable.observe { [weak self] error in
            guard let self = self else { return }
            
            self.errorHandler(error)
        }
        
        self.channelActionViewModel.loadingObservable.observe { [weak self] isLoading in
            guard let self = self else { return }
            
            if isLoading {
                self.shouldShowLoadingIndicator()
            } else {
                self.shouldDismissLoadingIndicator()
            }
        }
        
        self.channelActionViewModel.channelLoadedObservable.observe { [weak self] channel in
            guard let self = self else { return }
            guard let channel = channel as? SBDGroupChannel else { return }
            
            SBULog.info("Channel loaded: \(String(describing: channel))")
            self.channel = channel
            self.updateStyles()
        }
        
        self.channelActionViewModel.channelChangedObservable.observe { [weak self] channel, _ in
            guard let self = self else { return }
            guard let channel = channel as? SBDGroupChannel else { return }
            
            SBULog.info("Channel changed: \(String(describing: channel))")
            self.channel = channel
            self.updateStyles()
        }
    }
    
    private func disposeViewModel() {
        self.channelActionViewModel.dispose()
    }
    
    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        self.channelActionViewModel.loadGroupChannel(with: channelUrl)
    }
    
    /// This function freezes the channel.
    /// - Parameter completionHandler: completion handler of freeze status change
    public func freezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        SBULog.info("""
            [Request] Freeze channel,
            ChannelUrl:\(self.channel?.channelUrl ?? "")
            """)
        self.channelActionViewModel.freezeChannel(completionHandler: completionHandler)
    }
    
    /// This function unfreezes the channel.
    /// - Parameter completionHandler: completion handler of freeze status change
    public func unfreezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        SBULog.info("""
            [Request] Freeze channel,
            ChannelUrl:\(self.channel?.channelUrl ?? "")
            """)
        self.channelActionViewModel.unfreezeChannel(completionHandler: completionHandler)
    }
    
    
    // MARK: - Custom viewController relations
    
    /// This is a function that shows the operator List.
    /// If you want to use a custom MemberListViewController, override it and implement it.
    open func showOperatorList() {
        guard let channel = self.channel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        let memberListVC = SBUMemberListViewController(channel: channel, type: .operators)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    @available(*, deprecated, message: "deprecated in 2.1.9", renamed: "showMutedMemberList")
    open func showMutedMeberList() { self.showMutedMemberList() }
    
    /// This is a function that shows the muted member List.
    /// If you want to use a custom MemberListViewController, override it and implement it.
    open func showMutedMemberList() {
        guard let channel = self.channel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        let memberListVC = SBUMemberListViewController(channel: channel, type: .mutedMembers)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    @available(*, deprecated, message: "deprecated in 2.1.9", renamed: "showMutedMemberList")
    open func showBannedMeberList() { self.showBannedMemberList() }
    
    /// This is a function that shows the banned member List.
    /// If you want to use a custom MemberListViewController, override it and implement it.
    open func showBannedMemberList() {
        guard let channel = self.channel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        let memberListVC = SBUMemberListViewController(channel: channel, type: .bannedMembers)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    
    // MARK: - Actions
    
    /// Changes freeze status on channel.
    /// - Parameter freeze: freeze status
    /// - Parameter completionHandler: completion handler of freeze status change
    public func changeFreeze(_ freeze: Bool, _ completionHandler: ((Bool) -> Void)? = nil) {
        if freeze {
            self.freezeChannel(completionHandler: completionHandler)
        } else {
            self.unfreezeChannel(completionHandler: completionHandler)
        }
    }
    
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBDError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    @available(*, deprecated, message: "deprecated in 2.1.12", renamed: "errorHandler")
    open func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}


extension SBUModerationsViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - UITableView relations
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isBroadcast = self.channel?.isBroadcast ?? false
        let type = ModerationItemType.allTypes(isBroadcast: isBroadcast)[indexPath.row]
        switch type {
        case .operators:
            self.showOperatorList()
        case .mutedMembers:
            self.showMutedMemberList()
        case .bannedMembers:
            self.showBannedMemberList()
        case .freezeChannel:
            break
        default:
            break
        }
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SBUModerationCell.sbu_className
            ) as? SBUModerationCell else { fatalError() }
        
        cell.selectionStyle = .none
        
        let isBroadcast = self.channel?.isBroadcast ?? false
        let type = ModerationItemType.allTypes(isBroadcast: isBroadcast)[indexPath.row]
        cell.configure(type: type, channel: self.channel)
        
        if type == .freezeChannel {
            cell.switchAction = { [weak self] isOn in
                guard let self = self else { return }
                
                self.changeFreeze(isOn)
            }
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ModerationItemType.allTypes(isBroadcast: self.channel?.isBroadcast ?? false).count
    }
}

extension SBUModerationsViewController : LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        SBULoading.start()
        return true
    }
    
    open func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
}
