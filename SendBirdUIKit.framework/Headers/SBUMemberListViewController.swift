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
open class SBUMemberListViewController: UIViewController {
    // MARK: - Public property
    public lazy var titleView: UIView? = _titleView
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    public lazy var emptyView: UIView? = _emptyView
    
    public private(set) var memberListType: ChannelMemberListType = .none

    // MARK: - Private property
    // for UI
    var theme: SBUUserListTheme = SBUTheme.userListTheme
    var componentTheme: SBUComponentTheme = SBUTheme.componentTheme
    
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
        switch self.memberListType {
        case .channelMembers:
            titleView.text = SBUStringSet.MemberList_Title_Members
        case .operators:
            titleView.text = SBUStringSet.MemberList_Title_Operators
        case .mutedMembers:
            titleView.text = SBUStringSet.MemberList_Title_Muted_Members
        case .bannedMembers:
            titleView.text = SBUStringSet.MemberList_Title_Banned_Members
        default:
            break
        }
        
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
        guard self.memberListType == .channelMembers ||
            self.memberListType == .operators else { return UIBarButtonItem() }
        
        return UIBarButtonItem(
            image: SBUIconSet.iconPlus,
            style: .plain,
            target: self,
            action: #selector(onClickInviteUser)
        )
    }()
    
    private lazy var _emptyView: SBUEmptyView = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()
    
    
    // for logic
    public private(set) var channel: SBDGroupChannel?
    public private(set) var channelUrl: String?
    public private(set) var memberList: [SBUUser] = []
    
    @SBUAtomic private var customizedMembers: [SBUUser]?
    private var useCustomizedMembers = false
    var memberListQuery: SBDGroupChannelMemberListQuery?
    var operatorListQuery: SBDOperatorListQuery?
    var mutedMemberListQuery: SBDGroupChannelMemberListQuery?
    var bannedMemberListQuery: SBDBannedUserListQuery?
    var isLoading = false
    let limit: UInt = 20
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUMemberListViewController(channelUrl:type:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUMemberListViewController.init(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }
    
    /// If you have channel object, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - type: Channel member list type (default: `.channelMembers`)
    public init(channel: SBDGroupChannel, type: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")

        self.channel = channel
        self.channelUrl = channel.channelUrl
        self.memberListType = type
        
        self.loadChannel(channelUrl: channel.channelUrl)
    }

    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - type: Channel member list type (default: `.channelMembers`)
    public init(channelUrl: String, type: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")

        self.channelUrl = channelUrl
        self.memberListType = type
        
        self.loadChannel(channelUrl: channelUrl)
    }

    /// If you have channel and members objects, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - members: `SBUUser` array object
    ///   - type: Channel member list type (default: `.channelMembers`)
    /// - Since: 1.2.0
    public init(channel: SBDGroupChannel,
                members: [SBUUser],
                type: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channel = channel
        self.channelUrl = channel.channelUrl
        self.customizedMembers = members
        self.useCustomizedMembers = members.count > 0
        self.memberListType = type
        
        self.loadChannel(channelUrl: channel.channelUrl)
    }

    /// If you have channelUrl and members objects, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - members: `SBUUser` array object
    ///   - type: Channel member list type (default: `.channelMembers`)
    /// - Since: 1.2.0
    public init(channelUrl: String,
                members: [SBUUser],
                type: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        self.customizedMembers = members
        self.useCustomizedMembers = members.count > 0
        self.memberListType = type
        
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
    open func setupAutolayout() {
        self.tableView.sbu_constraint(
            equalTo: self.view,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0
        )
    }
    
    /// This function handles the initialization of styles
    open func setupStyles() {
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationShadowColor
        )

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
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
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
                
                // If want using your custom member list, filled users with your custom user list.
                self?.loadNextMemberList(reset: true, members: self?.customizedMembers ?? nil)
            }
        }
    }
    
    /// This function to load the member list.
    ///
    /// This requests the required list according to `memberListType`.
    /// If you want using your custom member list, filled members with your custom member list.
    ///
    /// - Parameters:
    ///   - reset: `true` is reset member list and load new list
    ///   - members: customized `SBUUser` array for add to member list
    /// - Since: 1.2.0
    public func loadNextMemberList(reset: Bool, members: [SBUUser]? = nil) {
        if self.isLoading { return }
        self.isLoading = true
        
        if reset {
            self.memberListQuery = nil
            self.operatorListQuery = nil
            self.mutedMemberListQuery = nil
            self.bannedMemberListQuery = nil
            self.memberList = []
            
            SBULog.info("[Request] Member List")
        } else {
            SBULog.info("[Request] Next member List")
        }

        if let members = members {
            // Customized member list
            SBULog.info("\(members.count) customized members have been added.")
            
            self.memberList += members
            self.reloadData()
            self.isLoading = false
        }
        else if !self.useCustomizedMembers {
            switch self.memberListType {
            case .channelMembers:
                self.loadNextChannelMemberList()
            case .operators:
                self.loadNextOperatorList()
            case .mutedMembers:
                self.loadNextMutedMemberList()
            case .bannedMembers:
                self.loadNextBannedMemberList()
            default:
                break
            }
        }
    }
    
    func loadNextChannelMemberList() {
        if self.memberListQuery == nil {
            self.memberListQuery = self.channel?.createMemberListQuery()
            self.memberListQuery?.limit = self.limit
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
            
            self?.memberList += members
            self?.reloadData()
        })
    }
    
    func loadNextOperatorList() {
        if self.operatorListQuery == nil {
            self.operatorListQuery = self.channel?.createOperatorListQuery()
            self.operatorListQuery?.limit = self.limit
        }
        
        guard self.operatorListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All operators have been loaded.")
            return
        }
        
        // return [SBDUser]
        self.operatorListQuery?.loadNextPage(completionHandler: {
            [weak self] operators, error in
            
            defer { self?.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Operator list request: \(error.localizedDescription)")
                self?.didReceiveError(error.localizedDescription)
                return
            }
            guard let operators = operators?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(operators.count) operators")
            
            self?.memberList += operators
            self?.reloadData()
        })
    }
    
    func loadNextMutedMemberList() {
        if self.mutedMemberListQuery == nil {
            self.mutedMemberListQuery = self.channel?.createMemberListQuery()
            self.mutedMemberListQuery?.limit = self.limit
            self.mutedMemberListQuery?.mutedMemberFilter = .muted
        }
        
        guard self.mutedMemberListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All muted members have been loaded.")
            return
        }
        
        // return [SBDMember]
        self.mutedMemberListQuery?.loadNextPage(completionHandler: {
            [weak self] members, error in
            
            defer { self?.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Muted member list request: \(error.localizedDescription)")
                self?.didReceiveError(error.localizedDescription)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(members.count) members")
            
            self?.memberList += members
            self?.reloadData()
        })
    }
    
    func loadNextBannedMemberList() {
        if self.bannedMemberListQuery == nil {
            self.bannedMemberListQuery = self.channel?.createBannedUserListQuery()
            self.bannedMemberListQuery?.limit = self.limit
        }
        
        guard self.bannedMemberListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All muted members have been loaded.")
            return
        }
        
        // return [SBDUser]
        self.bannedMemberListQuery?.loadNextPage(completionHandler: {
            [weak self] users, error in
            
            defer { self?.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Muted member list request: \(error.localizedDescription)")
                self?.didReceiveError(error.localizedDescription)
                return
            }
            guard let users = users?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(users.count) members")
            
            self?.memberList += users
            self?.reloadData()
        })
    }
    
    
    /// When creating and using a member list directly, overriding this function and return the next member list.
    /// Make this function return the next list each time it is called.
    ///
    /// - Returns: next member list
    /// - Since: 1.2.0
    open func nextMemberList() -> [SBUUser]? {
        return nil
    }
    
    /// This function to get member information directly from the channel in the case of GroupChannel.
    /// If you use it in SuperGroup, Broadcast channel, only some member information can be loaded.
    /// - Since: 1.2.0
    public func loadMembers() {
        if let members = self.channel?.members as? [SBDMember] {
            self.memberList = members.sbu_convertUserList()
            SBULog.info("Load with \(self.memberList.count) members")
            
            self.reloadData()
        }
    }

    /// This function promotes the member as an operator.
    /// - Parameter member: A member to be promoted
    /// - Since: 1.2.0
    public func promoteToOperator(member: SBUUser) {
        self.channel?.addOperators(
            withUserIds: [member.userId],
            completionHandler: { [weak self] error in
                self?.reloadMemberList()
        })
    }
    
    /// This function dismiss the operator as a member.
    /// - Parameter member: A member to be dismissed
    /// - Since: 1.2.0
    public func dismissOperator(member: SBUUser) {
        self.channel?.removeOperators(
            withUserIds: [member.userId],
            completionHandler: { [weak self] error in
                self?.reloadMemberList()
        })
    }
    
    /// This function mutes the member.
    /// - Parameter member: A member to be muted
    /// - Since: 1.2.0
    public func mute(member: SBUUser) {
        self.channel?.muteUser(
            withUserId: member.userId,
            completionHandler: { [weak self] error in
                self?.reloadMemberList()
        })
    }
    
    /// This function unmutes the member.
    /// - Parameter member: A member to be unmuted
    /// - Since: 1.2.0
    public func unmute(member: SBUUser) {
        self.channel?.unmuteUser(
            withUserId: member.userId,
            completionHandler: { [weak self] error in
                self?.reloadMemberList()
        })
    }
    
    /// This function bans the member.
    /// - Parameter member: A member to be banned
    /// - Since: 1.2.0
    public func ban(member: SBUUser) {
        self.channel?.banUser(
            withUserId: member.userId,
            seconds: -1,
            description: nil,
            completionHandler: { [weak self] error in
                self?.reloadMemberList()
        })
    }
    
    /// This function unbans the member.
    /// - Parameter member: A member to be unbanned
    /// - Since: 1.2.0
    public func unban(member: SBUUser) {
        self.channel?.unbanUser(
            withUserId: member.userId,
            completionHandler: { [weak self] error in
                self?.reloadMemberList()
        })
    }
    
    
    // MARK: - Custom viewController relations
    
    /// If you want to use a custom inviteChannelViewController, override it and implement it.
    open func showInviteUser() {
        guard let channel = self.channel else { return }
        
        let type: ChannelInviteListType = self.memberListType == .operators ? .operators : .users
        let inviteUserVC = SBUInviteUserViewController(channel: channel, type: type)
        self.navigationController?.pushViewController(inviteUserVC, animated: true)
    }
    
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
    
    /// This function reloads the member list.
    /// - Since: 1.2.0
    public func reloadMemberList() {
        self.loadNextMemberList(reset: true)
    }
    
    private func reloadData() {
        DispatchQueue.main.async { [weak self] in
            if let emptyView = self?.emptyView as? SBUEmptyView,
                (self?.memberListType == .mutedMembers || self?.memberListType == .bannedMembers) {
                
                if self?.memberList.count != 0 {
                    emptyView.reloadData(.none)
                } else {
                    emptyView.reloadData((self?.memberListType == .mutedMembers)
                    ? .noMutedMembers : .noBannedMembers)
                }
            }
            
            self?.tableView.reloadData()
        }
    }
    
    
    // MARK: - Actions
    @objc private func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            
            navigationController.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc open func onClickInviteUser() {
        self.showInviteUser()
    }
    
    /// /// This function sets the cell's more menu button action handling.
    /// - Parameter member: `SBUUser` obejct
    /// - Since: 1.2.0
    open func setMoreMenuActionHandler(_ member: SBUUser) {
        let userNameItem = SBUActionSheetItem(
            title: member.nickname ?? member.userId,
            color: self.componentTheme.actionSheetSubTextColor,
            textAlignment: .center
        )
        
        let operatorItem = SBUActionSheetItem(
            title: member.isOperator || self.memberListType == .operators
                ? SBUStringSet.MemberList_Dismiss_Operator
                : SBUStringSet.MemberList_Promote_Operator,
            color: self.componentTheme.actionSheetTextColor,
            textAlignment: .center
        ) { [weak self] in
            if member.isOperator || self?.memberListType == .operators {
                self?.dismissOperator(member: member)
            } else {
                self?.promoteToOperator(member: member)
            }
        }
        
        let muteItem = SBUActionSheetItem(
            title: member.isMuted
                ? SBUStringSet.MemberList_Unmute
                : SBUStringSet.MemberList_Mute,
            color: self.componentTheme.actionSheetTextColor,
            textAlignment: .center
        ) { [weak self] in
            if member.isMuted {
                self?.unmute(member: member)
            } else {
                self?.mute(member: member)
            }
        }
        
        let banItem = SBUActionSheetItem(
            title: self.memberListType == .bannedMembers
                ? SBUStringSet.MemberList_Unban
                : SBUStringSet.MemberList_Ban,
            color: self.memberListType == .bannedMembers
                ? self.componentTheme.actionSheetTextColor
                : self.componentTheme.actionSheetErrorColor,
            textAlignment: .center
        ) { [weak self] in
            if self?.memberListType == .bannedMembers {
                self?.unban(member: member)
            } else {
                self?.ban(member: member)
            }
        }
        
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: self.componentTheme.actionSheetItemColor)

        var items: [SBUActionSheetItem] = [userNameItem]
        
        switch self.memberListType {
        case .channelMembers:
            let isBroadcast = (self.channel?.isBroadcast ?? false)
            items += isBroadcast ? [operatorItem, banItem] : [operatorItem, muteItem, banItem]
        case .operators:
            items += [operatorItem]
        case .mutedMembers:
            items += [muteItem]
        case .bannedMembers:
            items += [banItem]
        default:
            break
        }
        
        SBUActionSheet.show(items: items, cancelItem: cancelItem)
    }
    
    
    // MARK: - Error handling
    open func didReceiveError(_ message: String?) {
        
    }
}

// MARK: - UITableView relations
extension SBUMemberListViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberList.count
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let member = memberList[indexPath.row]
        
        var cell: UITableViewCell? = nil
        if let userCell = self.userCell {
            cell = tableView.dequeueReusableCell(withIdentifier: userCell.sbu_className)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className)
        }

        cell?.selectionStyle = .none
        
        if let cell = cell as? SBUUserCell {
            var userListType: UserListType = .none
            
            switch self.memberListType {
            case .channelMembers:
                userListType = .channelMembers
            case .operators:
                userListType = .operators
            case .mutedMembers:
                userListType = .mutedMembers
            case .bannedMembers:
                userListType = .bannedMembers
            default:
                break
            }
            
            cell.configure(
                type: userListType,
                user: member,
                operatorMode: self.channel?.myRole == .operator
            )
            cell.moreMenuHandler = { [weak self] in
                self?.setMoreMenuActionHandler(member)
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        
        var queryCheck = false
        switch self.memberListType {
        case .channelMembers:
            queryCheck = (self.memberListQuery?.hasNext == true && self.memberListQuery != nil)
        case .operators:
            queryCheck = (self.operatorListQuery?.hasNext == true && self.operatorListQuery != nil)
        case .mutedMembers:
            queryCheck = (self.mutedMemberListQuery?.hasNext == true && self.mutedMemberListQuery != nil)
        case .bannedMembers:
            queryCheck = (self.bannedMemberListQuery?.hasNext == true && self.bannedMemberListQuery != nil)
        default:
            break
        }
        
        guard self.memberList.count > 0,
            (self.useCustomizedMembers || queryCheck),
            indexPath.row == (self.memberList.count - Int(self.limit)/2),
            (self.channel?.isBroadcast ?? false || self.channel?.isSuper ?? false),
            !self.isLoading
            else { return }
        
        let nextMemberList = (self.nextMemberList()?.count ?? 0) > 0
            ? self.nextMemberList()
            : nil
        
        self.loadNextMemberList(
            reset: false,
            members: self.useCustomizedMembers ? nextMemberList : nil
        )
    }
}


extension SBUMemberListViewController: SBUEmptyViewDelegate {
    @objc public func didSelectRetry() {
        
    }
}

extension SBUMemberListViewController: SBDChannelDelegate {
    public func channelDidUpdateOperators(_ sender: SBDBaseChannel) {
        self.reloadMemberList()
    }
}
