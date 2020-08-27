//
//  SBUCreateChannelViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUCreateChannelViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - Public property
    public lazy var titleView: UIView? = _titleView
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    
    public private(set) var channelType: ChannelType = .group
    
    // MARK: - Private property
    // for UI
    var theme: SBUUserListTheme = SBUTheme.userListTheme
    private var tableView = UITableView()
    
    var userCell: UITableViewCell?
    
    private lazy var _titleView: SBUNavigationTitleView = {
        var titleView: SBUNavigationTitleView
        if #available(iOS 11, *) {
            titleView = SBUNavigationTitleView()
        } else {
            titleView = SBUNavigationTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        titleView.text = SBUStringSet.CreateChannel_Header_Select_Members
        titleView.textAlignment = .center
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
    
    private lazy var _rightBarButton: UIBarButtonItem = {
            let rightItem =  UIBarButtonItem(
                title: SBUStringSet.CreateChannel_Create(0),
                style: .plain,
                target: self,
                action: #selector(onClickCreate)
            )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
    // for logic
    @SBUAtomic public private(set) var userList: [SBUUser] = []
    @SBUAtomic public private(set) var selectedUserList: Set<SBUUser> = []
    
    @SBUAtomic private var customizedUsers: [SBUUser]?
    private var useCustomizedUsers = false
    var userListQuery: SBDApplicationUserListQuery?
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
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        // tableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
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
    open func setupAutolayout() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
        ])
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )

        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = self.selectedUserList.isEmpty
            ? theme.rightBarButtonTintColor
            : theme.rightBarButtonSelectedTintColor

        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        // If want using your custom user list, filled users with your custom user list.
        self.loadNextUserList(reset: true, users: self.customizedUsers ?? nil)
        
        self.tableView.reloadData()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.setupStyles()
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
        if self.isLoading { return }
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
            self.reloadUserList()
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
                defer { self?.showLoading(state: false) }
                
                if let error = error {
                    SBULog.error("[Failed] User list request: \(error.localizedDescription)")
                    self?.didReceiveError(error.localizedDescription)
                    return
                }
                let filteredUsers = users?.filter { $0.userId != SBUGlobals.CurrentUser?.userId }

                guard let users = filteredUsers?.sbu_convertUserList() else { return }
                
                SBULog.info("[Response] \(users.count) users")
                
                self?.userList += users
                self?.reloadUserList()
                self?.showLoading(state: false)
            })
        }
    }
    
    /// When creating and using a user list directly, overriding this function and return the next user list.
    /// - Returns: next user list
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

        self.createChannel(params: params)
    }
    
    /// Creates the channel with channelParams.
    ///
    /// You can create a channel by setting various properties of ChannelParams.
    /// - Parameter params: `SBDGroupChannelParams` class object
    /// - Since: 1.0.9
    public func createChannel(params: SBDGroupChannelParams) {
        SBULog.info("""
            [Request] Create channel with users,
            Users: \(Array(self.selectedUserList))
            """)
        SBDGroupChannel.createChannel(with: params) { [weak self] channel, error in
            if let error = error {
                SBULog.error("""
                    [Failed] Create channel request:
                    \(String(error.localizedDescription))
                    """)
                self?.didReceiveError(error.localizedDescription)
            }
            
            guard let channelUrl = channel?.channelUrl else {
                SBULog.error("[Failed] Create channel request: There is no channel url.")
                return
            }
            SBULog.info("[Succeed] Create channel: \(channel?.description ?? "")")
            SBUMain.openChannel(channelUrl: channelUrl)
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
    func reloadUserList() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func showLoading(state: Bool) {
        self.isLoading = state

        if self.userListQuery == nil, state {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }

    
    // MARK: - Actions
    @objc private func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func onClickCreate() {
        guard selectedUserList.isEmpty == false else { return }
        
        let userIds = Array(self.selectedUserList).sbu_getUserIds()
        self.createChannel(userIds: userIds)
    }
    
    private func selectUser(user: SBUUser) {
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
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
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
