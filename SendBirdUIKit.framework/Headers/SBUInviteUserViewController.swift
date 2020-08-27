//
//  SBUInviteUserViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUInviteUserViewController: UIViewController {
    
    // MARK: - Public property
    public lazy var titleView: UIView? = _titleView
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton

    public private(set) var inviteListType: ChannelInviteListType = .users
    
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
        titleView.text = self.inviteListType == .operators
            ? SBUStringSet.InviteChannel_Header_Select_Members
            : SBUStringSet.InviteChannel_Header_Title
        
        titleView.textAlignment = .center
        return titleView
    }()

    private lazy var _leftBarButton: UIBarButtonItem = {
        let leftItem =  UIBarButtonItem(
            title: SBUStringSet.Cancel,
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
        leftItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return leftItem
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
        let rightItem =  UIBarButtonItem(
            title: SBUStringSet.Invite,
            style: .plain,
            target: self,
            action: #selector(onClickInvite)
        )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
    // for logic
    public private(set) var channel: SBDGroupChannel?
    public private(set) var channelUrl: String?
    @SBUAtomic public private(set) var userList: [SBUUser] = []
    @SBUAtomic public private(set) var selectedUserList: Set<SBUUser> = []
    
    @SBUAtomic private var customizedUsers: [SBUUser]?
    private var useCustomizedUsers = false
    var joinedUserIds: Set<String> = []
    var userListQuery: SBDApplicationUserListQuery?
    var memberListQuery: SBDGroupChannelMemberListQuery?
    var isLoading = false
    let limit: UInt = 20
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUInviteUserViewController.init(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUInviteUserViewController.init(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }
    
    /// If you have channel object, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - type: Invite list type (default `.users`)
    public init(channel: SBDGroupChannel, type: ChannelInviteListType = .users) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")

        self.channel = channel
        self.channelUrl = channel.channelUrl
        self.customizedUsers = nil
        self.inviteListType = type
        
        self.loadChannel(channelUrl: channel.channelUrl)
    }

    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - type: Invite list type (default `.users`)
    public init(channelUrl: String, type: ChannelInviteListType = .users) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")

        self.channelUrl = channelUrl
        self.inviteListType = type

        self.loadChannel(channelUrl: channelUrl)
    }
    
    /// If you have channel and users objects, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - users: `SBUUser` object
    ///   - type: Invite list type (default `.users`)
    public init(channel: SBDGroupChannel, users: [SBUUser], type: ChannelInviteListType = .users) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channel = channel
        self.channelUrl = channel.channelUrl
        self.customizedUsers = users
        self.useCustomizedUsers = users.count > 0
        self.inviteListType = type
        
        self.loadChannel(channelUrl: channel.channelUrl)
    }

    /// If you have channelUrl and users objects, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - users: `SBUUser` object
    ///   - type: Invite list type (default `.users`)
    public init(channelUrl: String, users: [SBUUser], type: ChannelInviteListType = .users) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        self.customizedUsers = users
        self.useCustomizedUsers = users.count > 0
        self.inviteListType = type
        
        self.loadChannel(channelUrl: channelUrl)
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
        self.navigationController?.navigationBar
            .setBackgroundImage(UIImage.from(color: theme.navigationBarTintColor), for: .default)
        self.navigationController?.navigationBar
            .shadowImage = UIImage.from(color: theme.navigationShadowColor)

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
    
    deinit {
        SBULog.info("")
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

                if self?.inviteListType == .users {
                    self?.prepareDatas()
                }
                // If want using your custom user list, filled users with your custom user list.
                self?.loadNextUserList(
                    reset: true,
                    users: self?.customizedUsers ?? nil
                )
            }
        }
    }
    
    /// Load user list.
    ///
    /// If want using your custom user list, filled users with your custom user list.
    ///
    /// - Parameters:
    ///   - reset: `true` is reset user list and load new list
    ///   - users: customized `SBUUser` array for add to user list
    public func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        if self.isLoading { return }
        self.isLoading = true
        
        if reset {
            self.userListQuery = nil
            self.memberListQuery = nil
            self.userList = []
            
            SBULog.info("[Request] User List")
        } else {
            SBULog.info("[Request] Next user List")
        }

        if let users = users {
            // Customized user list
            SBULog.info("\(users.count) customized users have been added.")
            
            self.appendUsersWithFiltering(users: users)
            self.reloadUserList()
            self.isLoading = false
        }
        else if !self.useCustomizedUsers {
            switch self.inviteListType {
            case .users:
                self.loadNextApplicationUserList()
            case .operators:
                self.loadNextChannelMemberList()
            default:
                break
            }
        }
    }
    
    func loadNextApplicationUserList() {
        if self.userListQuery == nil {
            self.userListQuery = SBDMain.createApplicationUserListQuery()
            self.userListQuery?.limit = self.limit
        }
        
        guard self.userListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All users have been loaded.")
            self.reloadUserList()
            return
        }
        
        self.userListQuery?.loadNextPage(completionHandler: { [weak self] users, error in
            defer { self?.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] User list request: \(error.localizedDescription)")
                self?.didReceiveError(error.localizedDescription)
                return
            }
            guard let users = users?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(users.count) users")
            
            self?.appendUsersWithFiltering(users: users)
            self?.reloadUserList()
        })
    }
    
    func loadNextChannelMemberList() {
        if self.memberListQuery == nil {
            self.memberListQuery = self.channel?.createMemberListQuery()
            self.memberListQuery?.limit = self.limit
            self.memberListQuery?.operatorFilter = .nonOperator
        }
        
        guard self.memberListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All members have been loaded.")
            return
        }
        
        // return [SBDMember]
        self.memberListQuery?.loadNextPage(completionHandler: {
            [weak self] members, error in
            
            defer { self?.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Member list request: \(error.localizedDescription)")
                self?.didReceiveError(error.localizedDescription)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(members.count) members")
            
            self?.userList += members
            self?.reloadUserList()
        })
    }
    

    /// When creating and using a user list directly, overriding this function and return the next user list.
    /// Make this function return the next list each time it is called.
    /// - Returns: next user list
    /// - Since: 1.1.1
    open func nextUserList() -> [SBUUser]? {
        return nil
    }
    
    private func appendUsersWithFiltering(users: [SBUUser]) {
        // Super,Broadcast channel does not contain all information in joined members.
        if self.channel?.isBroadcast ?? false || self.channel?.isSuper ?? false {
            self.userList += users
            return
        }

        guard self.joinedUserIds.count != 0 else {
            self.userList += users
            return
        }
        
        let filteredUsers = users.filter { joinedUserIds.contains($0.userId) == false }
        if filteredUsers.count == 0 {
            self.isLoading = false
            let nextUserList = (self.nextUserList()?.count ?? 0) > 0 ? self.nextUserList() : nil
            self.loadNextUserList(reset: false, users: self.useCustomizedUsers ? nextUserList : nil)
        } else {
            self.userList += filteredUsers
        }
    }
    
    /// Invites users in the channel with selected userIds.
    /// - Since: 1.0.9
    public func inviteUsers() {
        let userIds = Array(self.selectedUserList).sbu_getUserIds()
        
        self.inviteUsers(userIds: userIds)
    }
    
    /// Invites users in the channel with directly generated userIds.
    /// - Parameter userIds: User IDs to invite
    /// - Since: 1.0.9
    public func inviteUsers(userIds: [String]) {
        SBULog.info("[Request] Invite users, Users: \(Array(self.selectedUserList))")
        self.channel?.inviteUserIds(userIds, completionHandler: { [weak self] error in
            if let error = error {
                SBULog.error("""
                    [Failed] Invite users request:
                    \(String(error.localizedDescription))
                    """)
                self?.didReceiveError(error.localizedDescription)
            }
            
            SBULog.info("[Succeed] Invite users")
            self?.popToChannel()
        })
    }
    
    /// Promotes members as operator with selected userIds.
    /// - Since: 1.2.0
    public func promoteToOperators() {
        let memberIds = Array(self.selectedUserList).sbu_getUserIds()
        
        self.promoteToOperators(memberIds: memberIds)
    }
    
    /// Promotes members as operator with directly generated memberIds.
    /// - Parameter userIds: member IDs to invite
    /// - Since: 1.2.0
    public func promoteToOperators(memberIds: [String]) {
        SBULog.info("[Request] Promote members, Members: \(Array(self.selectedUserList))")
        self.channel?.addOperators(withUserIds: memberIds,
                                   completionHandler: { [weak self] error in
            if let error = error {
                SBULog.error("""
                    [Failed] Promote members request:
                    \(String(error.localizedDescription))
                    """)
                self?.didReceiveError(error.localizedDescription)
            }
            
            SBULog.info("[Succeed] Promote members")
            self?.popToPrevious()
        })
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
    private func prepareDatas() {
        guard let members = self.channel?.members as? [SBDUser] else { return }

        let joinedMemberList = members.sbu_convertUserList()
        if joinedMemberList.count > 0 {
            self.joinedUserIds = Set(joinedMemberList.sbu_getUserIds())
        }
    }
    
    private func reloadUserList() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
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
    
    @objc private func onClickInvite() {
        guard selectedUserList.isEmpty == false else { return }

        switch self.inviteListType {
        case .users:
            self.inviteUsers()
        case .operators:
            self.promoteToOperators()
        default:
            break
        }
    }
    
    public func selectUser(user: SBUUser) {
        if let index = self.selectedUserList.firstIndex(of: user) {
            self.selectedUserList.remove(at: index)
        } else {
            self.selectedUserList.insert(user)
        }
        
        SBULog.info("Selected user: \(user)")
        
        switch self.inviteListType {
        case .users:
            self.rightBarButton?.title = SBUStringSet.InviteChannel_Invite(selectedUserList.count)
        case .operators:
            self.rightBarButton?.title = SBUStringSet.InviteChannel_Add(selectedUserList.count)
        default:
            self.rightBarButton?.title = ""
        }
        
        self.setupStyles()
    }
    
    public func popToChannel() {
        guard let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        for vc in navigationController.viewControllers {
            if vc is SBUChannelViewController {
                navigationController.popToViewController(vc, animated: true)
                return
            }
        }
        
        navigationController.popToRootViewController(animated: true)
    }
    
    public func popToPrevious() {
        guard let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        navigationController.popViewController(animated: true)
    }
    
    
    // MARK: - Error handling
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
}


// MARK: - UITableView relations
extension SBUInviteUserViewController: UITableViewDelegate, UITableViewDataSource {
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
                type: .inviteUser,
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
        
        var queryCheck = false
        switch self.inviteListType {
        case .users:
            queryCheck = (self.userListQuery?.hasNext == true && self.userListQuery != nil)
        case .operators:
            queryCheck = (self.memberListQuery?.hasNext == true && self.memberListQuery != nil)
        case .none:
            break
        }
        
        if self.userList.count > 0,
            (self.useCustomizedUsers || queryCheck),
            indexPath.row == (self.userList.count - Int(self.limit)/2),
            !self.isLoading {
            let nextUserList = (self.nextUserList()?.count ?? 0) > 0
                ? self.nextUserList()
                : nil
            self.loadNextUserList(
                reset: false,
                users: self.useCustomizedUsers ? nextUserList : nil
            )
        }
    }
}
