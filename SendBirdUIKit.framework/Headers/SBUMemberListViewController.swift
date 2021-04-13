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
    public lazy var emptyView: UIView? = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()
    
    public private(set) lazy var tableView = UITableView()

    /// To use the custom user profile view, set this to the custom view created using `SBUUserProfileViewProtocol`. And, if you do not want to use the user profile feature, please set this value to nil.
    public lazy var userProfileView: UIView? = SBUUserProfileView(delegate: self)
    
    public private(set) var userCell: UITableViewCell?
    
    public var theme: SBUUserListTheme = SBUTheme.userListTheme
    public var componentTheme: SBUComponentTheme = SBUTheme.componentTheme

    
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

    private lazy var backButton: UIBarButtonItem = SBUCommonViews.backButton(
        vc: self,
        selector: #selector(onClickBack)
    )
    
    private lazy var addButton: UIBarButtonItem = {
        guard self.memberListType == .channelMembers ||
            self.memberListType == .operators else { return UIBarButtonItem() }
        
        return UIBarButtonItem(
            image: SBUIconSetType.iconPlus.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onClickInviteUser)
        )
    }()
    
    
    // MARK: - Logic properties (Public)
    public private(set) var memberListType: ChannelMemberListType = .none

    public private(set) var channel: SBDBaseChannel?
    public private(set) var channelUrl: String?
    private var channelType: SBDChannelType = .group

    public private(set) var memberList: [SBUUser] = []
    
    public var memberListQuery: SBDGroupChannelMemberListQuery? {
        return memberListViewModel?.memberListQuery
    }
    public var operatorListQuery: SBDOperatorListQuery? {
        return memberListViewModel?.operatorListQuery
    }
    public var mutedMemberListQuery: SBDGroupChannelMemberListQuery? {
        return memberListViewModel?.mutedMemberListQuery
    }
    public var bannedMemberListQuery: SBDBannedUserListQuery? {
        return memberListViewModel?.bannedMemberListQuery
    }
    public var participantListQuery: SBDParticipantListQuery? {
        return memberListViewModel?.participantListQuery
    }
    
    private var memberListViewModel: SBUMemberListViewModel? {
        willSet { self.disposeViewModel() }
        didSet { self.bindViewModel() }
    }

    
    // MARK: - Logic properties (Private)
    @SBUAtomic private var customizedMembers: [SBUUser]?
    
    
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

        if channel is SBDGroupChannel {
            self.channelType = .group
        } else if channel is SBDOpenChannel {
            self.channelType = .open
        }
        
        self.createViewModel()
        self.loadChannel(channelUrl: channel.channelUrl)
    }

    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - type: Channel member list type (default: `.channelMembers`)
    @available(*, deprecated, message: "deprecated in 2.1.0", renamed: "init(channelUrl:channelType:memberListType:)")
    public init(channelUrl: String, type: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")

        self.channelUrl = channelUrl
        self.memberListType = type
        
        self.createViewModel()
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
        self.memberListType = type
        
        if channel is SBDGroupChannel {
            self.channelType = .group
        } else if channel is SBDOpenChannel {
            self.channelType = .open
        }
        
        self.createViewModel()
        self.loadChannel(channelUrl: channel.channelUrl)
    }

    /// If you have channelUrl and members objects, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - members: `SBUUser` array object
    ///   - type: Channel member list type (default: `.channelMembers`)
    /// - Since: 1.2.0
    @available(*, deprecated, message: "deprecated in 2.1.0", renamed: "init(channelUrl:channelType:members:memberListType:)")
    public init(channelUrl: String,
                members: [SBUUser],
                type: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        self.customizedMembers = members
        self.memberListType = type
        
        self.createViewModel()
        self.loadChannel(channelUrl: channelUrl)
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - type: Channel member list type (default: `.channelMembers`)
    public init(channelUrl: String, channelType: SBDChannelType, memberListType: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")

        self.channelUrl = channelUrl
        self.channelType = channelType
        self.memberListType = memberListType
        
        self.createViewModel()
        self.loadChannel(channelUrl: channelUrl)
    }
    
    /// If you have channelUrl and members objects, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - members: `SBUUser` array object
    ///   - type: Channel member list type (default: `.channelMembers`)
    /// - Since: 1.2.0
    public init(channelUrl: String,
                channelType: SBDChannelType,
                members: [SBUUser],
                memberListType: ChannelMemberListType = .channelMembers) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        self.channelType = channelType
        self.customizedMembers = members
        self.memberListType = memberListType
        
        self.createViewModel()
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
        if self.rightBarButton == nil {
            self.rightBarButton = self.addButton
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
    }
    
    deinit {
        SBULog.info("")
        disposeViewModel()
    }
    
    
    // MARK: - ViewModel
    
    private func createViewModel() {
        self.memberListViewModel = SBUMemberListViewModel(
            useCustomList: (self.customizedMembers?.count ?? 0) > 0
        )
    }
    
    private func bindViewModel() {
        guard let memberListViewModel = self.memberListViewModel else { return }
        
        memberListViewModel.errorObservable.observe { [weak self] error in
            guard let self = self else { return }

            self.didReceiveError(error.localizedDescription)
        }
        
        memberListViewModel.loadingObservable.observe { [weak self] isLoading in
            guard let self = self else { return }

            if isLoading {
                self.shouldShowLoadingIndicator()
            } else {
                self.shouldDismissLoadingIndicator()
            }
        }
        
        memberListViewModel.channelLoadedObservable.observe { [weak self] channel in
            guard let self = self else { return }

            SBULog.info("Channel loaded: \(String(describing: channel))")
            self.channel = channel
            self.updateStyles()
            
            // If want using your custom member list, filled users with your custom user list.
            self.loadNextMemberList(reset: true, members: self.customizedMembers ?? nil)
        }
        
        memberListViewModel.channelChangedObservable.observe { [weak self] channel in
            guard let self = self else { return }

            SBULog.info("Channel changed: \(String(describing: channel))")
            self.channel = channel
            self.updateStyles()
            self.resetMemberList()
        }
        
        memberListViewModel.resetObservable.observe { [weak self] _ in
            guard let self = self else { return }
            self.memberList = []
        }
        
        memberListViewModel.queryListObservable.observe { [weak self] memberList in
            guard let self = self else { return }
            
            self.memberList += memberList
            self.reloadData()
        }
    }
    
    private func disposeViewModel() {
        self.memberListViewModel?.dispose()
    }

    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        self.memberListViewModel?.loadChannel(url: channelUrl, type: self.channelType)
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
        if reset {
            self.memberListViewModel?.resetQuery()
        }
        
        self.memberListViewModel?.loadNextMemberList(memberListType: self.memberListType,
                                                     members: members)
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
        self.memberListViewModel?.loadMembersFromChannelObject()
    }

    /// This function promotes the member as an operator.
    /// - Parameter member: A member to be promoted
    /// - Since: 1.2.0
    public func promoteToOperator(member: SBUUser) {
        self.memberListViewModel?.promoteToOperator(member: member)
    }
    
    /// This function dismiss the operator as a member.
    /// - Parameter member: A member to be dismissed
    /// - Since: 1.2.0
    public func dismissOperator(member: SBUUser) {
        self.memberListViewModel?.dismissOperator(member: member)
    }
    
    /// This function mutes the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be muted
    /// - Since: 1.2.0
    public func mute(member: SBUUser) {
        self.memberListViewModel?.mute(member: member)
    }
    
    /// This function unmutes the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be unmuted
    /// - Since: 1.2.0
    public func unmute(member: SBUUser) {
        self.memberListViewModel?.unmute(member: member)
    }
    
    /// This function bans the member in the case of Group/SuperGroup/Broadcast channel.
    /// - Parameter member: A member to be banned
    /// - Since: 1.2.0
    public func ban(member: SBUUser) {
        self.memberListViewModel?.ban(member: member)
    }
    
    /// This function unbans the member.
    /// - Parameter member: A member to be unbanned
    /// - Since: 1.2.0
    public func unban(member: SBUUser) {
        self.memberListViewModel?.unban(member: member)
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
        
        guard self.memberList.count > 0,
              indexPath.row >= (self.memberList.count - Int(SBUMemberListViewModel.limit) / 2),
              (self.memberListViewModel?.hasNext(memberListType: self.memberListType) == true) else { return }
        
        self.loadNextMemberList(
            reset: false,
            members: self.nextMemberList()
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
        return true
    }
    
    open func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
}
