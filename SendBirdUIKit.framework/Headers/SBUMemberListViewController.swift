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
open class SBUMemberListViewController: SBUBaseViewController {
    
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
    public lazy var emptyView: UIView? = _emptyView
    public private(set) lazy var tableView = UITableView()

    /// To use the custom user profile view, set this to the custom view created using `SBUUserProfileViewProtocol`. And, if you do not want to use the user profile feature, please set this value to nil.
    public lazy var userProfileView: UIView? = _userProfileView
    public private(set) var userCell: UITableViewCell?
    
    public var theme: SBUUserListTheme = SBUTheme.userListTheme
    public var componentTheme: SBUComponentTheme = SBUTheme.componentTheme

    
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
        switch self.memberListType {
        case .channelMembers:
            titleView.text = SBUStringSet.MemberList_Title_Members
        case .operators:
            titleView.text = SBUStringSet.MemberList_Title_Operators
        case .mutedMembers:
            titleView.text = SBUStringSet.MemberList_Title_Muted_Members
        case .bannedMembers:
            titleView.text = SBUStringSet.MemberList_Title_Banned_Members
        case .participants:
            titleView.text = SBUStringSet.MemberList_Title_Participants
        default:
            break
        }
        
        titleView.textAlignment = .center
        return titleView
    }()

    private lazy var _leftBarButton: UIBarButtonItem = {
        return SBUCommonViews.backButton(vc: self, selector: #selector(onClickBack))
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
        guard self.memberListType == .channelMembers ||
            self.memberListType == .operators else { return UIBarButtonItem() }
        
        return UIBarButtonItem(
            image: SBUIconSetType.iconPlus.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onClickInviteUser)
        )
    }()
    
    private lazy var _userProfileView: SBUUserProfileView = {
       let userProfileView = SBUUserProfileView(delegate: self)
        return userProfileView
    }()
    
    private lazy var _emptyView: SBUEmptyView = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()
    
    
    // MARK: - Logic properties (Public)
    public private(set) var memberListType: ChannelMemberListType = .none

    public private(set) var channel: SBDBaseChannel?
    public private(set) var channelUrl: String?

    public private(set) var memberList: [SBUUser] = []
    
    public private(set) var memberListQuery: SBDGroupChannelMemberListQuery?
    public private(set) var operatorListQuery: SBDOperatorListQuery?
    public private(set) var mutedMemberListQuery: SBDGroupChannelMemberListQuery?
    public private(set) var bannedMemberListQuery: SBDBannedUserListQuery?
    public private(set) var participantListQuery: SBDParticipantListQuery?

    
    // MARK: - Logic properties (Private)
    @SBUAtomic private var customizedMembers: [SBUUser]?
    private var useCustomizedMembers = false
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
    public init(channel: SBDBaseChannel, type: ChannelMemberListType = .channelMembers) {
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
    public init(channel: SBDBaseChannel,
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
        self.tableView.sbu_constraint(
            equalTo: self.view,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0
        )
    }
    
    /// This function handles the initialization of styles
    open override func setupStyles() {
        self.theme = SBUTheme.userListTheme
        self.componentTheme = SBUTheme.componentTheme
        
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
    
    open override func updateStyles() {
        self.theme = SBUTheme.userListTheme
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUNavigationTitleView {
            titleView.setupStyles()
        }
        
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.setupStyles()
        }
        
        if let userProfileView = self.userProfileView as? SBUUserProfileView {
            userProfileView.setupStyles()
        }
        
        self.reloadData()
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
        
        self.updateStyles()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let userProfileView = userProfileView as? SBUUserProfileView {
            userProfileView.dismiss()
        }
        
        SBUActionSheet.dismiss()
        SBULoading.stop()
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
            guard let self = self else { return }
            if let error = error { self.didReceiveError(error.localizedDescription) }
            
            SBULog.info("[Request] Load channel: \(String(channelUrl))")
            
            let completionHandler: ((SBDBaseChannel?, SBDError?) -> Void)? = { [weak self] channel, error in
                guard let self = self else { return }
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    self.didReceiveError(error.localizedDescription)
                    return
                }
                
                self.channel = channel
                
                SBULog.info("""
                    [Succeed] Load channel request:
                    \(String(format: "%@", self.channel ?? ""))
                    """)
                
                // If want using your custom member list, filled users with your custom user list.
                self.loadNextMemberList(reset: true, members: self.customizedMembers ?? nil)
            }
            
            if self.channel is SBDGroupChannel {
                SBDGroupChannel.getWithUrl(channelUrl, completionHandler: completionHandler)
            } else if self.channel is SBDOpenChannel {
                SBDOpenChannel.getWithUrl(channelUrl, completionHandler: completionHandler)
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
            self.participantListQuery = nil
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
            case .participants:
                self.loadNextChannelParticipantsList()
            default:
                break
            }
        }
    }
    
    /// This function loads channel member list.
    ///
    /// If you want to call a list of operators, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `MemberList` alone.
    private func loadNextChannelMemberList() {
        if self.memberListQuery == nil, let channel = self.channel as? SBDGroupChannel {
            self.memberListQuery = channel.createMemberListQuery()
            self.memberListQuery?.limit = self.limit
        }
        
        guard self.memberListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All members have been loaded.")
            return
        }
        
        self.memberListQuery?.loadNextPage(completionHandler: {
            [weak self] members, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Member list request: \(error.localizedDescription)")
                self.didReceiveError(error.localizedDescription)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(members.count) members")
            
            self.memberList += members
            self.reloadData()
        })
    }
    
    /// This function loads operator list.
    ///
    /// If you want to call a list of operators, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `OperatorList` alone.
    private func loadNextOperatorList() {
        if self.operatorListQuery == nil {
            self.operatorListQuery = self.channel?.createOperatorListQuery()
            self.operatorListQuery?.limit = self.limit
        }
        
        guard self.operatorListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All operators have been loaded.")
            return
        }
        
        self.operatorListQuery?.loadNextPage(completionHandler: {
            [weak self] operators, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Operator list request: \(error.localizedDescription)")
                self.didReceiveError(error.localizedDescription)
                return
            }
            guard let operators = operators?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(operators.count) operators")
            
            self.memberList += operators
            self.reloadData()
        })
    }
    
    /// This function loads muted member list.
    ///
    /// If you want to call a list of muted members, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `MutedMemberList` alone.
    private func loadNextMutedMemberList() {
        if self.mutedMemberListQuery == nil, let channel = self.channel as? SBDGroupChannel {
            self.mutedMemberListQuery = channel.createMemberListQuery()
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
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Muted member list request: \(error.localizedDescription)")
                self.didReceiveError(error.localizedDescription)
                return
            }
            guard let members = members?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(members.count) members")
            
            self.memberList += members
            self.reloadData()
        })
    }
    
    
    /// This function loads banned member list.
    ///
    /// If you want to call a list of banned members, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `BannedMemberList` alone.
    private func loadNextBannedMemberList() {
        if self.bannedMemberListQuery == nil, let channel = self.channel as? SBDGroupChannel {
            self.bannedMemberListQuery = channel.createBannedUserListQuery()
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
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Muted member list request: \(error.localizedDescription)")
                self.didReceiveError(error.localizedDescription)
                return
            }
            guard let users = users?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(users.count) members")
            
            self.memberList += users
            self.reloadData()
        })
    }
    
    /// This function loads channel participants list.
    ///
    /// If you want to call a list of operators, use the `loadNextMemberList(reset:members:)` function.
    /// - Warning: Use this function only when you need to call `MemberList` alone.
    /// - Since: 2.0.0
    private func loadNextChannelParticipantsList() {
        if self.participantListQuery == nil, let channel = self.channel as? SBDOpenChannel {
            self.participantListQuery = channel.createParticipantListQuery()
            self.participantListQuery?.limit = self.limit
        }
        
        guard self.participantListQuery?.hasNext == true else {
            self.isLoading = false
            SBULog.info("All participants have been loaded.")
            return
        }
        
        self.participantListQuery?.loadNextPage(completionHandler: {
            [weak self] participants, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                SBULog.error("[Failed] Participants list request: \(error.localizedDescription)")
                self.didReceiveError(error.localizedDescription)
                return
            }
            guard let participants = participants?.sbu_convertUserList() else { return }
            
            SBULog.info("[Response] \(participants.count) participants")
            
            self.memberList += participants
            self.reloadData()
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
        guard let channel = self.channel as? SBDGroupChannel else { return }
        if let members = channel.members as? [SBDMember] {
            self.memberList = members.sbu_convertUserList()
            SBULog.info("Load with \(self.memberList.count) members")
            
            self.reloadData()
        }
    }

    /// This function promotes the member as an operator.
    /// - Parameter member: A member to be promoted
    /// - Since: 1.2.0
    public func promoteToOperator(member: SBUUser) {
        self.shouldShowLoadingIndicator()
        self.channel?.addOperators(
            withUserIds: [member.userId],
            completionHandler: { [weak self] error in
                self?.shouldDismissLoadingIndicator()
                self?.resetMemberList()
            })
    }
    
    /// This function dismiss the operator as a member.
    /// - Parameter member: A member to be dismissed
    /// - Since: 1.2.0
    public func dismissOperator(member: SBUUser) {
        self.shouldShowLoadingIndicator()
        self.channel?.removeOperators(
            withUserIds: [member.userId],
            completionHandler: { [weak self] error in
                self?.shouldDismissLoadingIndicator()
                self?.resetMemberList()
            })
    }
    
    /// This function mutes the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be muted
    /// - Since: 1.2.0
    public func mute(member: SBUUser) {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        self.shouldShowLoadingIndicator()
        channel.muteUser(
            withUserId: member.userId,
            completionHandler: { [weak self] error in
                self?.shouldDismissLoadingIndicator()
                self?.resetMemberList()
            })
    }
    
    /// This function unmutes the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be unmuted
    /// - Since: 1.2.0
    public func unmute(member: SBUUser) {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        self.shouldShowLoadingIndicator()
        channel.unmuteUser(
            withUserId: member.userId,
            completionHandler: { [weak self] error in
                self?.shouldDismissLoadingIndicator()
                self?.resetMemberList()
            })
    }
    
    /// This function bans the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be banned
    /// - Since: 1.2.0
    public func ban(member: SBUUser) {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        self.shouldShowLoadingIndicator()
        channel.banUser(
            withUserId: member.userId,
            seconds: -1,
            description: nil,
            completionHandler: { [weak self] error in
                self?.shouldDismissLoadingIndicator()
                self?.resetMemberList()
            })
    }
    
    /// This function unbans the member.
    /// - Parameter member: A member to be unbanned
    /// - Since: 1.2.0
    public func unban(member: SBUUser) {
        if let groupChannel = self.channel as? SBDGroupChannel {
            self.shouldShowLoadingIndicator()
            groupChannel.unbanUser(withUserId: member.userId) { [weak self] error in
                guard let self = self else { return }
                self.shouldDismissLoadingIndicator()
                self.resetMemberList()
            }
        } else if let openChannel = self.channel as? SBDOpenChannel {
            self.shouldShowLoadingIndicator()
            openChannel.unbanUser(withUserId: member.userId) { [weak self] error in
                guard let self = self else { return }
                self.shouldDismissLoadingIndicator()
                self.resetMemberList()
            }
        }
    }
    
    
    // MARK: - Custom viewController relations
    
    /// If you want to use a custom inviteChannelViewController, override it and implement it.
    open func showInviteUser() {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        
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
    
    /// This function resets the member list.
    /// - Since: 1.2.0
    /// - Deprecate:
    @available(*, deprecated, message: "deprecated in 1.2.5", renamed: "resetMemberList()")
    public func reloadMemberList() {
        self.resetMemberList()
    }
    /// This function resets the member list.
    /// - Since: 1.2.5
    public func resetMemberList() {
        self.loadNextMemberList(reset: true)
    }
    
    /// This function reloads the list.
    /// - Since: 1.2.5
    public func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let emptyView = self.emptyView as? SBUEmptyView,
                (self.memberListType == .mutedMembers || self.memberListType == .bannedMembers) {
                
                if self.memberList.count != 0 {
                    emptyView.reloadData(.none)
                } else {
                    emptyView.reloadData(self.memberListType == .mutedMembers
                    ? .noMutedMembers : .noBannedMembers)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Actions
    
    /// This function shows inviteChannelViewController.
    @objc open func onClickInviteUser() {
        self.showInviteUser()
    }
    
    /// This function sets the cell's more menu button action handling. (GroupChannel only)
    /// - Parameter member: `SBUUser` obejct
    /// - Since: 1.2.0
    open func setMoreMenuActionHandler(_ member: SBUUser) {
        guard let channel = self.channel as? SBDGroupChannel else { return }
        
        let userNameItem = SBUActionSheetItem(
            title: member.nickname ?? member.userId,
            color: self.componentTheme.actionSheetSubTextColor,
            textAlignment: .center,
            completionHandler: nil
        )
        
        let operatorItem = SBUActionSheetItem(
            title: member.isOperator || self.memberListType == .operators
                ? SBUStringSet.MemberList_Dismiss_Operator
                : SBUStringSet.MemberList_Promote_Operator,
            color: self.componentTheme.actionSheetTextColor,
            textAlignment: .center
        ) { [weak self] in
            guard let self = self else { return }
            if member.isOperator || self.memberListType == .operators {
                self.dismissOperator(member: member)
            } else {
                self.promoteToOperator(member: member)
            }
        }
        
        let muteItem = SBUActionSheetItem(
            title: member.isMuted
                ? SBUStringSet.MemberList_Unmute
                : SBUStringSet.MemberList_Mute,
            color: self.componentTheme.actionSheetTextColor,
            textAlignment: .center
        ) { [weak self] in
            guard let self = self else { return }
            if member.isMuted {
                self.unmute(member: member)
            } else {
                self.mute(member: member)
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
            guard let self = self else { return }
            if self.memberListType == .bannedMembers {
                self.unban(member: member)
            } else {
                self.ban(member: member)
            }
        }
        
        let cancelItem = SBUActionSheetItem(
            title: SBUStringSet.Cancel,
            color: self.componentTheme.actionSheetItemColor,
            completionHandler: nil)

        var items: [SBUActionSheetItem] = [userNameItem]
        
        switch self.memberListType {
        case .channelMembers:
            let isBroadcast = channel.isBroadcast
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
    
    /// This function sets the user profile tap gesture handling.
    ///
    /// If you do not want to use the user profile function, override this function and leave it empty.
    /// - Parameter user: `SBUUser` object used for user profile configuration
    ///
    /// - Since: 1.2.2
    open func setUserProfileTapGestureHandler(_ user: SBUUser) {
        guard let userProfileView = self.userProfileView as? SBUUserProfileView else { return }
        guard let baseView = self.navigationController?.view else { return }
        switch self.channel {
        case is SBDGroupChannel:
            guard SBUGlobals.UsingUserProfile else { return }
            userProfileView.show(baseView: baseView, user: user)
            
        case is SBDOpenChannel:
            guard SBUGlobals.UsingUserProfileInOpenChannel else { return }
            userProfileView.show(baseView: baseView, user: user, isOpenChannel: true)
            
        default: return
        }
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
            case .participants:
                userListType = .participants
            default:
                break
            }
            
            var operatorMode = false
            if let channel = self.channel as? SBDGroupChannel {
                operatorMode = channel.myRole == .operator
            }
            
            cell.configure(
                type: userListType,
                user: member,
                operatorMode: operatorMode
            )
            
            if self.channel is SBDGroupChannel {
                cell.moreMenuHandler = { [weak self] in
                    guard let self = self else { return }
                    self.setMoreMenuActionHandler(member)
                }
            }
            cell.userProfileTapHandler = { [weak self] in
                guard let self = self else { return }
                self.setUserProfileTapGestureHandler(member)
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
        case .participants:
            queryCheck = (self.participantListQuery?.hasNext == true && self.participantListQuery != nil)
        default:
            break
        }
        
        if let groupChannel = self.channel as? SBDGroupChannel {
            guard self.memberList.count > 0,
                (self.useCustomizedMembers || queryCheck),
                indexPath.row == (self.memberList.count - Int(self.limit)/2),
                (groupChannel.isBroadcast || groupChannel.isSuper),
                !self.isLoading
                else { return }
        } else if self.channel is SBDOpenChannel {
            guard self.memberList.count > 0,
                (self.useCustomizedMembers || queryCheck),
                indexPath.row == (self.memberList.count - Int(self.limit)/2),
                !self.isLoading
                else { return }
        }
        
        let nextMemberList = (self.nextMemberList()?.count ?? 0) > 0
            ? self.nextMemberList()
            : nil
        
        self.loadNextMemberList(
            reset: false,
            members: self.useCustomizedMembers ? nextMemberList : nil
        )
    }
}


// MARK: - SBUEmptyViewDelegate
extension SBUMemberListViewController: SBUEmptyViewDelegate {
    @objc open func didSelectRetry() {
        
    }
}


// MARK: - SBUUserProfileViewDelegate
extension SBUMemberListViewController: SBUUserProfileViewDelegate {
    open func didSelectMessage(userId: String?) {
        if let userProfileView = self.userProfileView
            as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
            if let userId = userId {
                SBUMain.createAndMoveToChannel(userIds: [userId])
            }
        }
    }
    
    open func didSelectClose() {
        if let userProfileView = self.userProfileView
            as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
        }
    }
}


// MARK: - SBDChannelDelegate
extension SBUMemberListViewController: SBDChannelDelegate {
    open func channelDidUpdateOperators(_ sender: SBDBaseChannel) {
        self.resetMemberList()
    }
    
    open func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        self.resetMemberList()
    }
    
    open func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        self.resetMemberList()
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        self.resetMemberList()
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        self.resetMemberList()
    }
}

extension SBUMemberListViewController: LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        SBULoading.start()
        return false
    }
    
    open func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
}
