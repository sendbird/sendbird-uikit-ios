//
//  SBUCreateChannelViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUCreateChannelViewController: SBUBaseViewController {
    
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
    public lazy var emptyView: UIView? = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()
    
    public private(set) lazy var tableView = UITableView()

    public private(set) var userCell: UITableViewCell?
    
    @SBUThemeWrapper(theme: SBUTheme.userListTheme)
    public var theme: SBUUserListTheme
    
    
    // MARK: - UI properties (Private)
    private lazy var defaultTitleView: SBUNavigationTitleView = {
        var titleView = SBUNavigationTitleView()
        titleView.text = SBUStringSet.CreateChannel_Header_Select_Members
        titleView.textAlignment = .center
        return titleView
    }()
    
    private lazy var backButton: UIBarButtonItem = SBUCommonViews.backButton(
        vc: self,
        selector: #selector(onClickBack)
    )
    
    private lazy var createButton: UIBarButtonItem = {
        let rightItem =  UIBarButtonItem(
            title: SBUStringSet.CreateChannel_Create(0),
            style: .plain,
            target: self,
            action: #selector(onClickCreate)
        )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
    
    // MARK: - Logic properties (Public)
    public private(set) var channelType: ChannelType = .group
    
    @SBUAtomic public private(set) var userList: [SBUUser] = []
    @SBUAtomic public private(set) var selectedUserList: Set<SBUUser> = []

    public private(set) var userListQuery: SBDApplicationUserListQuery?

    
    // MARK: - Logic properties (Private)
    @SBUAtomic private var customizedUsers: [SBUUser]?
    private var useCustomizedUsers = false
    var isLoading = false
    let limit: UInt = 20
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUCreateChannelViewController(type:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUCreateChannelViewController.init()")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }
    
    convenience public init() {
        self.init(users: nil)
    }

    /// If you have user objects, use this initialize function.
    /// - Parameters:
    ///   - users: `SBUUser` array object
    ///   - type: The type of channel to create (default: `.group`)
    public init(users: [SBUUser]? = nil, type: ChannelType = .group) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelType = type
        self.customizedUsers = users
        if users?.count ?? 0 > 0 {
            useCustomizedUsers = true
        }
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
        if self.rightBarButton == nil {
            self.rightBarButton = self.createButton
        }
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = self.emptyView
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        if self.userCell == nil {
            self.register(userCell: SBUUserCell())
        }
        self.view.addSubview(self.tableView)
        
        // autolayout
        self.setupAutolayout()
        
        // Styles
        self.setupStyles()
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupAutolayout() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
        ])
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )
        
        // For iOS 15
        self.navigationController?.sbu_setupNavigationBarAppearance(tintColor: theme.navigationBarTintColor)

        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = self.selectedUserList.isEmpty
            ? theme.rightBarButtonTintColor
            : theme.rightBarButtonSelectedTintColor

        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUNavigationTitleView {
            titleView.setupStyles()
        }
        
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.setupStyles()
        }
        
        self.reloadData()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        // If want using your custom user list, filled users with your custom user list.
        self.loadNextUserList(reset: true, users: self.customizedUsers ?? nil)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateStyles()
    }
    
    deinit {
        SBULog.info("")
    }

    
    // MARK: - SDK relations
    
    /// Load user list.
    ///
    /// If want using your custom user list, filled users with your custom user list.
    ///
    /// - Parameters:
    ///   - reset: `true` is reset user list and load new list
    ///   - users: customized `SBUUser` array for add to user list
    public func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        guard !self.isLoading else { return }
        self.showLoading(state: true)
        
        if reset {
            self.userListQuery = nil
            self.userList = []
            
            SBULog.info("[Request] User List")
        } else {
            SBULog.info("[Request] Next user List")
        }

        if let users = users {
            // for using customized user list
            SBULog.info("\(users.count) customized users have been added.")
            
            self.userList += users
            self.reloadData()
            self.showLoading(state: false)
        }
        else if !self.useCustomizedUsers {
            if self.userListQuery == nil {
                self.userListQuery = SBDMain.createApplicationUserListQuery()
                self.userListQuery?.limit = self.limit
            }
            
            guard self.userListQuery?.hasNext == true else {
                self.showLoading(state: false)
                SBULog.info("All users have been loaded.")
                return
            }
            
            self.userListQuery?.loadNextPage(completionHandler: { [weak self] users, error in
                guard let self = self else { return }
                defer {
                    self.reloadData()
                    self.showLoading(state: false)
                }
                
                if let error = error {
                    SBULog.error("[Failed] User list request: \(error.localizedDescription)")
                    self.errorHandler(error)
                    if let emptyView = self.emptyView as? SBUEmptyView {
                        emptyView.reloadData(.error)
                    }
                    return
                }
                let filteredUsers = users?.filter { $0.userId != SBUGlobals.CurrentUser?.userId }

                guard let users = filteredUsers?.sbu_convertUserList() else { return }
                
                SBULog.info("[Response] \(users.count) users")
                
                self.userList += users
                
                if let emptyView = self.emptyView as? SBUEmptyView {
                    if self.userList.isEmpty {
                        emptyView.reloadData(.noMembers)
                    } else {
                        emptyView.reloadData(.none)
                    }
                }
                
                self.reloadData()
                self.showLoading(state: false)
            })
        }
    }
    
    /// When creating and using a user list directly, overriding this function and return the next user list.
    /// - Returns: [`SBUUser`] next user list
    /// - Since: 1.1.1
    open func nextUserList() -> [SBUUser]? {
        return nil
    }
    
    /// Creates the channel with userIds.
    /// - Parameter userIds: User Ids to include
    /// - Since: 1.0.9
    public func createChannel(userIds: [String]) {
        let params = SBDGroupChannelParams()
        params.name = ""
        params.coverUrl = ""
        params.addUserIds(userIds)
        params.isDistinct = false

        let type = self.channelType
        params.isSuper = (type == .broadcast) || (type == .supergroup)
        params.isBroadcast = (type == .broadcast)
        
        if let currentUser = SBUGlobals.CurrentUser {
            params.operatorUserIds = [currentUser.userId]
        }

        SBUGlobalCustomParams.groupChannelParamsCreateBuilder?(params)
        
        self.createChannel(params: params)
    }
    
    /// Creates the channel with channelParams.
    ///
    /// You can create a channel by setting various properties of ChannelParams.
    /// - Parameters:
    ///   - params: `SBDGroupChannelParams` class object
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    /// - Since: 1.0.9
    public func createChannel(params: SBDGroupChannelParams,
                              messageListParams: SBDMessageListParams? = nil) {
        SBULog.info("""
            [Request] Create channel with users,
            Users: \(Array(self.selectedUserList))
            """)
        self.shouldShowLoadingIndicator()
        
        self.rightBarButton?.isEnabled = false
        
        SBDGroupChannel.createChannel(with: params) { [weak self] channel, error in
            defer { self?.shouldDismissLoadingIndicator() }
            guard let self = self else { return }
            self.rightBarButton?.isEnabled = true
            
            if let error = error {
                SBULog.error("""
                    [Failed] Create channel request:
                    \(String(error.localizedDescription))
                    """)
                self.errorHandler(error)
                return
            }
            
            guard let channelUrl = channel?.channelUrl else {
                SBULog.error("[Failed] Create channel request: There is no channel url.")
                return
            }
            SBULog.info("[Succeed] Create channel: \(channel?.description ?? "")")
            SBUMain.moveToChannel(channelUrl: channelUrl, messageListParams: messageListParams)
        }
    }
    

    // MARK: - Custom viewController relations
    
    /// Used to register a custom cell as a base cell based on `UITableViewCell`.
    /// - Parameters:
    ///   - userCell: Customized channel cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(userCell: UITableViewCell, nib: UINib? = nil) {
        self.userCell = userCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: userCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: userCell),
                forCellReuseIdentifier: userCell.sbu_className
            )
        }
    }
    
    
    // MARK: - Common
    
    /// This function reloads user list.
    /// - Since: 1.2.5
    @available(*, deprecated, renamed: "reloadData()") // 2.1.11
    public func reloadUserList() {
        self.reloadData()
    }
    
    /// This function reloads the list.
    /// - Since: 2.1.11
    public func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    
    /// This function shows loading indicator.
    /// - Parameter state: If state is `true`, start loading indicator.
    /// - Since: 1.2.5
    public func showLoading(state: Bool) {
        self.isLoading = state

        if self.userListQuery == nil, state {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }

    
    // MARK: - Actions
    
    /// This function calls `createChannel:` function using the `selectedUserList`.
    /// - Since: 1.2.5
    public func onClickCreate() {
        guard !selectedUserList.isEmpty else { return }
        
        let userIds = Array(self.selectedUserList).sbu_getUserIds()
        self.createChannel(userIds: userIds)
    }
    
    /// This function selects or deselects user.
    /// - Parameter user: `SBUUser` object
    /// - Since: 1.2.5
    public func selectUser(user: SBUUser) {
        if let index = self.selectedUserList.firstIndex(of: user) {
            self.selectedUserList.remove(at: index)
        } else {
            self.selectedUserList.insert(user)
        }
        
        SBULog.info("Selected user: \(user)")
        
        self.rightBarButton?.title = SBUStringSet.CreateChannel_Create(selectedUserList.count)
        self.view.setNeedsLayout()
        self.setupStyles()
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
    
    @available(*, deprecated, renamed: "errorHandler") // 2.1.12
    open func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}


// MARK: - UITableView relations
extension SBUCreateChannelViewController: UITableViewDelegate, UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = userList[indexPath.row]

        var cell: UITableViewCell? = nil
        if let userCell = self.userCell {
            cell = tableView.dequeueReusableCell(withIdentifier: userCell.sbu_className)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className)
        }

        cell?.selectionStyle = .none

        if let defaultCell = cell as? SBUUserCell {
            defaultCell.configure(
                type: .createChannel,
                user: user,
                isChecked: self.selectedUserList.contains(user)
            )
        }
        return cell ?? UITableViewCell()
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userList[indexPath.row]
        self.selectUser(user: user)
        
        if let defaultCell = self.tableView.cellForRow(at: indexPath) as? SBUUserCell {
            defaultCell.selectUser(self.selectedUserList.contains(user))
        }
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        
        if self.userList.count > 0,
            (self.useCustomizedUsers ||
                (self.userListQuery?.hasNext == true && self.userListQuery != nil)),
            indexPath.row == (self.userList.count - Int(self.limit)/2),
            !self.isLoading {
            
            let nextUserList = (self.nextUserList()?.count ?? 0) > 0 ? self.nextUserList() : nil
            self.loadNextUserList(
                reset: false,
                users: self.useCustomizedUsers ? nextUserList : nil
            )
        }
    }
}


// MARK: - SBUEmptyViewDelegate
extension SBUCreateChannelViewController: SBUEmptyViewDelegate {
    @objc open func didSelectRetry() {
        self.loadNextUserList(reset: true, users: self.customizedUsers ?? nil)
    }
}


// MARK: - LoadingIndicatorDelegate
extension SBUCreateChannelViewController: LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        SBULoading.start()
        return false;
    }
    
    open func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
}
