//
//  SBUModerationsViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/27.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

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
    private lazy var _titleView: SBUNavigationTitleView = {
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
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        return SBUCommonViews.backButton(vc: self, selector: #selector(onClickBack))
    }()
    
    private lazy var _rightBarButton = UIBarButtonItem()
    
    
    // MARK: - Logic properties (Public)
    public private(set) var channel: SBDGroupChannel?
    public private(set) var channelUrl: String?
    
    
    // MARK: - Logic properties (Private)
    
    
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
        
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameter channelUrl: Channel url string
    public init(channelUrl: String) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        
        self.loadChannel(channelUrl: channelUrl)
    }
    
    open override func loadView() {
        super.loadView()
        SBULog.info("")
        
        if self.titleView == nil {
            self.titleView = _titleView
        }
        if self.leftBarButton == nil {
            self.leftBarButton = _leftBarButton
        }
        if self.rightBarButton == nil {
            self.rightBarButton = _rightBarButton
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
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SBULoading.stop()
    }
    
    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        self.shouldShowLoadingIndicator()
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            if let error = error { self.didReceiveError(error.localizedDescription) }
            
            SBULog.info("[Request] Load channel: \(String(channelUrl))")
            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                defer { self?.shouldDismissLoadingIndicator() }
                guard let self = self else { return }
                
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    self.didReceiveError(error.localizedDescription)
                    return
                }
                
                self.channel = channel
                
                SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    /// This function freezes the channel.
    /// - Parameter completionHandler: completion handler of freeze status change
    public func freezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        SBULog.info("""
            [Request] Freeze channel,
            ChannelUrl:\(self.channel?.channelUrl ?? "")
            """)
        self.shouldShowLoadingIndicator()
        self.channel?.freeze { [weak self] error in
            defer { self?.shouldDismissLoadingIndicator() }
            
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            if let error = error {
                SBULog.error("""
                    [Failed] Freeze channel request:
                    \(String(error.localizedDescription))
                    """)
                completionHandler?(false)
                return
            }
            
            SBULog.info("""
                [Succeed] Freeze channel request,
                ChannelUrl:\(self.channel?.channelUrl ?? "")
                """)
            completionHandler?(true)
        }
    }
    
    /// This function unfreezes the channel.
    /// - Parameter completionHandler: completion handler of freeze status change
    public func unfreezeChannel(completionHandler: ((Bool) -> Void)? = nil) {
        SBULog.info("""
            [Request] Freeze channel,
            ChannelUrl:\(self.channel?.channelUrl ?? "")
            """)
        self.shouldShowLoadingIndicator()
        self.channel?.unfreeze { [weak self] error in
            defer { self?.shouldDismissLoadingIndicator() }
            
            guard let self = self else {
                completionHandler?(false)
                return
            }
            
            if let error = error {
                SBULog.error("""
                    [Failed] Unfreeze channel request:
                    \(String(error.localizedDescription))
                    """)
                completionHandler?(false)
                return
            }
            
            SBULog.info("""
                [Succeed] Unfreeze channel request,
                ChannelUrl:\(self.channel?.channelUrl ?? "")
                """)
            completionHandler?(true)
        }
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
    
    /// This is a function that shows the muted member List.
    /// If you want to use a custom MemberListViewController, override it and implement it.
    open func showMutedMeberList() {
        guard let channel = self.channel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        let memberListVC = SBUMemberListViewController(channel: channel, type: .mutedMembers)
        self.navigationController?.pushViewController(memberListVC, animated: true)
    }
    
    /// This is a function that shows the banned member List.
    /// If you want to use a custom MemberListViewController, override it and implement it.
    open func showBannedMeberList() {
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
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
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
            self.showMutedMeberList()
        case .bannedMembers:
            self.showBannedMeberList()
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
                self.changeFreeze(isOn, { [weak cell] success in
                    guard let cell = cell else{ return }
                    if !success { cell.changeBackSwitch() }
                })
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
        return false;
    }
    
    open func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
}
