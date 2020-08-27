//
//  SBUModerationsViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/27.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objcMembers
open class SBUModerationsViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - Public property
    public lazy var titleView: UIView? = _titleView
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    
    
    // MARK: - Private property
    var theme: SBUChannelSettingsTheme = SBUTheme.channelSettingsTheme
    
    private lazy var tableView = UITableView()
    
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
        return UIBarButtonItem(
            image: SBUIconSet.iconBack,
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
    }()
    
    private lazy var _rightBarButton = UIBarButtonItem()
    
    /// One of two must be set.
    public private(set) var channel: SBDGroupChannel?
    private var channelUrl: String?
    
    
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
    open func setupAutolayout() {
        self.tableView.sbu_constraint(
            equalTo: self.view,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0
        )
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
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
        self.setNeedsStatusBarAppearanceUpdate()
        self.setupStyles()
    }
    
    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        SBUMain.connectionCheck { [weak self] user, error in
            if let error = error { self?.didReceiveError(error.localizedDescription) }
            
            SBULog.info("[Request] Load channel: \(String(channelUrl))")
            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    self?.didReceiveError(error.localizedDescription)
                    return
                }
                
                self?.channel = channel
                
                SBULog.info("""
                    [Succeed] Load channel request:
                    \(String(format: "%@", self?.channel ?? ""))
                    """)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
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
        self.channel?.freeze { [weak self] error in
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
        self.channel?.unfreeze { [weak self] error in
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
    func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
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
                self?.changeFreeze(isOn, { [weak cell] success in
                    if !success {
                        cell?.changeBackSwitch()
                    }
                })
            }
        }
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ModerationItemType.allTypes(isBroadcast: self.channel?.isBroadcast ?? false).count
    }
}
