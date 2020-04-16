//
//  SBUMemberListViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUMemberListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Public property
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    
    
    // MARK: - Private property
    // for UI
    var theme: SBUUserListTheme = SBUTheme.userListTheme
    
    private lazy var titleView: SBUNavigationTitleView = _titleView
    private lazy var _titleView: SBUNavigationTitleView = {
        let titleView = SBUNavigationTitleView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        titleView.text = SBUStringSet.MemberList_Header_Title
        titleView.textAlignment = .center
        return titleView
    }()

    private var tableView = UITableView()
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem(image: SBUIconSet.iconBack,
                               style: .plain,
                               target: self,
                               action: #selector(onClickBack) )
        
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(image: SBUIconSet.iconPlus,
                               style: .plain,
                               target: self,
                               action: #selector(onClickInviteUser) )
    }()
    
    // for logic
    private var channel: SBDGroupChannel?
    private var channelUrl: String?
    
    private var memberList: [SBDMember] = []
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUMemberListViewController.init(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    public init(channel: SBDGroupChannel) {
        super.init(nibName: nil, bundle: nil)

        self.channel = channel
    }

    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameter channelUrl: Channel url string
    public init(channelUrl: String) {
        super.init(nibName: nil, bundle: nil)

        self.channelUrl = channelUrl
        
        self.loadChannel(channelUrl: channelUrl)
    }
    
    open override func loadView() {
        super.loadView()

        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.register(SBUUserCell.loadNib(), forCellReuseIdentifier: SBUUserCell.className) // for xib
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)
        
        // autolayout
        self.setupAutolayout()
        
        // Styles
        self.setupStyles()
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
        ])
    }
    
    /// This function handles the initialization of styles
    open func setupStyles() {
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = theme.navigationBarTintColor
        self.navigationController?.navigationBar.shadowImage = .from(color: theme.navigationShadowColor)

        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.rightBarButtonSelectedTintColor

        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        if let members = self.channel?.members as? [SBDMember] {
            self.memberList = members
        }
        
        self.tableView.reloadData()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.setupStyles()
    }

    
    // MARK: - Custom viewController relations
    
    /// If you want to use a custom inviteChannelViewController, override it and implement it.
    open func showInviteUser() {
        guard let channel = self.channel else { return }
        let inviteUserVC = SBUInviteUserViewController(channel: channel)
        self.navigationController?.pushViewController(inviteUserVC, animated: true)
    }
    
    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        SBUMain.connectionCheck { [weak self] user, error in
            if let error = error { self?.didReceiveError(error.localizedDescription) }

            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard error == nil else {
                    self?.didReceiveError(error?.localizedDescription)
                    return
                }
                
                self?.channel = channel
            }
        }
    }
    
    
    // MARK: - Actions
    @objc private func onClickBack() {
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc open func onClickInviteUser() {
        self.showInviteUser()
    }
    
    
    // MARK: - UITableView relations
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.className) as? SBUUserCell
            else { return UITableViewCell() }
        cell.selectionStyle = .none
        
        let member = memberList[indexPath.row]
        let user = SBUUser.init(user: member)
        
        cell.configure(type: .channelMembers, user: user)
        return cell
    }
    
    
    // MARK: - Error handling
    open func didReceiveError(_ message: String?) {
        
    }
}
