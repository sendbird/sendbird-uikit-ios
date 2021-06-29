//
//  SBUInviteUserViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUInviteUserViewController: SBUBaseViewController {
    
    // MARK: - UI properties (Public)
    public var titleView: UIView? = nil {
        didSet { self.navigationItem.titleView = self.titleView }
    }
    public var leftBarButton: UIBarButtonItem? = nil {
        didSet { self.navigationItem.leftBarButtonItem = self.leftBarButton }
    }
    public var rightBarButton: UIBarButtonItem? = nil {
        didSet { self.navigationItem.rightBarButtonItem = self.rightBarButton }
    }
    public private(set) lazy var tableView = UITableView()
    public private(set) var userCell: UITableViewCell?
    
    public var theme: SBUUserListTheme = SBUTheme.userListTheme
    
    
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
        titleView.text = self.inviteListType == .operators
            ? SBUStringSet.InviteChannel_Header_Select_Members
            : SBUStringSet.InviteChannel_Header_Title
        
        titleView.textAlignment = .center
        return titleView
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let leftItem =  UIBarButtonItem(
            title: SBUStringSet.Cancel,
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
        leftItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return leftItem
    }()
    
    private lazy var inviteButton: UIBarButtonItem = {
        let rightItem =  UIBarButtonItem(
            title: SBUStringSet.Invite,
            style: .plain,
            target: self,
            action: #selector(onClickInviteOrPromote)
        )
        rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
        return rightItem
    }()
    
    
    // MARK: - Logic properties (Public, get-only)
    public var inviteListType: ChannelInviteListType {
        return inviteUserListViewModel?.inviteListType ?? .users
    }
    
    public var channel: SBDGroupChannel? {
        return inviteUserListViewModel?.channel as? SBDGroupChannel
    }
    public var channelUrl: String? {
        return inviteUserListViewModel?.channelUrl
    }
    
    public var userList: [SBUUser] {
        return inviteUserListViewModel?.userList ?? []
    }
    public var selectedUserList: Set<SBUUser> {
        return inviteUserListViewModel?.selectedUserList ?? []
    }
    
    public var joinedUserIds: Set<String> {
        return inviteUserListViewModel?.joinedUserIds ?? []
    }
    public var userListQuery: SBDApplicationUserListQuery? {
        return inviteUserListViewModel?.userListQuery
    }
    
    public var memberListQuery: SBDGroupChannelMemberListQuery? {
        return inviteUserListViewModel?.memberListQuery
    }
    
    
    // MARK: - Logic properties (Private)
    private var customizedUsers: [SBUUser]? {
        return inviteUserListViewModel?.customizedUsers
    }

    private var inviteUserListViewModel: SBUInviteUserListViewModel? {
        willSet { self.disposeViewModel() }
        didSet { self.bindViewModel() }
    }
    
    
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

        self.createViewModel(type: type)
        self.loadChannel(channelUrl: channel.channelUrl)
    }

    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameters:
    ///   - channelUrl: Channel url string
    ///   - type: Invite list type (default `.users`)
    public init(channelUrl: String, type: ChannelInviteListType = .users) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")

        self.createViewModel(type: type)
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
        
        self.createViewModel(users: users, type: type)
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
        
        self.createViewModel(users: users, type: type)
        self.loadChannel(channelUrl: channelUrl)
    }

    open override func loadView() {
        super.loadView()
        SBULog.info("")
        
        if self.titleView == nil {
            self.titleView = self.defaultTitleView
        }
        if self.leftBarButton == nil {
            self.leftBarButton = self.cancelButton
        }
        if self.rightBarButton == nil {
            self.rightBarButton = self.inviteButton
        }
        
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
        self.theme = SBUTheme.userListTheme
        
        self.navigationController?.navigationBar
            .setBackgroundImage(UIImage.from(color: theme.navigationBarTintColor), for: .default)
        self.navigationController?.navigationBar
            .shadowImage = UIImage.from(color: theme.navigationShadowColor)

        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = inviteUserListViewModel?.selectedUserList.isEmpty ?? true
            ? theme.rightBarButtonTintColor
            : theme.rightBarButtonSelectedTintColor

        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.theme = SBUTheme.userListTheme
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUNavigationTitleView {
            titleView.setupStyles()
        }
        
        self.reloadData()
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
        
        self.updateStyles()
    }
    
    deinit {
        SBULog.info("")
        self.disposeViewModel()
    }
    
    
    // MARK: - ViewModel
    
    private func createViewModel(users: [SBUUser]? = nil,
                                 type: ChannelInviteListType) {
        self.inviteUserListViewModel = SBUInviteUserListViewModel(
            users: users,
            type: type
        )
        self.inviteUserListViewModel?.datasource = self
    }
    
    private func bindViewModel() {
        guard let inviteUserListViewModel = self.inviteUserListViewModel else { return }
        
        inviteUserListViewModel.errorObservable.observe { [weak self] error in
            self?.didReceiveError(error.localizedDescription)
        }
        
        inviteUserListViewModel.loadingObservable.observe { [weak self] isLoading in
            if isLoading {
                self?.shouldShowLoadingIndicator()
            } else {
                self?.shouldDismissLoadingIndicator()
            }
        }
        
        inviteUserListViewModel.channelLoadedObservable.observe { [weak self] channel in
            guard let self = self else { return }
            
            SBULog.info("Channel loaded: \(String(describing: channel))")

            self.resetUserList()
        }
        
        inviteUserListViewModel.channelChangedObservable.observe { [weak self] channel, type in
            switch type {
            case .invite:
                self?.popToChannel()
            case .promote:
                self?.popToChannel()
            default:
                break
            }
        }
        
        inviteUserListViewModel.userListChangedObservable.observe { [weak self] _ in
            self?.reloadData()
        }
        
        inviteUserListViewModel.selectedUserObservable.observe { [weak self] selectedUserList in
            switch self?.inviteListType {
            case .users:
                self?.rightBarButton?.title = SBUStringSet.InviteChannel_Invite(selectedUserList.count)
            case .operators:
                self?.rightBarButton?.title = SBUStringSet.InviteChannel_Add(selectedUserList.count)
            default:
                self?.rightBarButton?.title = ""
            }
            
            self?.setupStyles()
        }
    }
    
    private func disposeViewModel() {
        self.inviteUserListViewModel?.dispose()
    }
    
    
    // MARK: - SDK relations
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        inviteUserListViewModel?.loadChannel(url: channelUrl, type: .group)
    }
    
    /// Load user list.
    ///
    /// If want using your custom user list, filled users with your custom user list.
    ///
    /// - Parameters:
    ///   - reset: `true` is reset user list and load new list
    ///   - users: customized `SBUUser` array for add to user list
    public func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        self.inviteUserListViewModel?.loadNextUserList(reset: reset, users: users)
    }
    
    /// Invites users in the channel with selected userIds.
    /// - Since: 1.0.9
    public func inviteUsers() {
        let userIds = Array(self.selectedUserList).sbu_getUserIds()
        self.inviteUserListViewModel?.inviteUsers(userIds: userIds)
    }
    
    /// Invites users in the channel with directly generated userIds.
    /// - Parameter userIds: User IDs to invite
    /// - Since: 1.0.9
    public func inviteUsers(userIds: [String]) {
        self.inviteUserListViewModel?.inviteUsers(userIds: userIds)
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
        self.inviteUserListViewModel?.promoteToOperators(memberIds: memberIds)
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
    
    /// This function resets the user list.
    ///
    /// If want to use your custom user list, add users object during this class initialization.
    /// - Since: 1.2.5
    public func resetUserList() {
        self.loadNextUserList(reset: true, users: self.customizedUsers ?? nil)
    }
    
    /// This function reloads the list.
    /// - Since: 1.2.5
    public func reloadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    /// This function calls `inviteUsers` or `promoteToOperators` functions with `inviteListType`.
    /// - Since: 1.2.5
    public func onClickInviteOrPromote() {
        guard !selectedUserList.isEmpty else { return }

        switch self.inviteListType {
        case .users:
            self.inviteUsers()
        case .operators:
            self.promoteToOperators()
        default:
            break
        }
    }
    
    /// This function selects or deselects user.
    /// - Parameter user: `SBUUser` object
    public func selectUser(user: SBUUser) {
        self.inviteUserListViewModel?.selectUser(user: user)
    }
    
    /// This function is used to pop to channelViewController.
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
    
    /// This function is used to pop to previous viewController.
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
        self.inviteUserListViewModel?.preLoadNextUserList(indexPath: indexPath)
    }
}


// MARK: - LoadingIndicatorDelegate
extension SBUInviteUserViewController: LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        SBULoading.start()
        return false;
    }
    
    open func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
}


// MARK: - SBUInviteUserListDatasource
extension SBUInviteUserViewController: SBUInviteUserListDatasource {
    /// When creating and using a user list directly, overriding this function and return the next user list.
    /// Make this function return the next list each time it is called.
    /// - Important: If you want to use this function, please set the `SBUInviteUserListDatasource` in your class.
    ///
    /// - Returns: next user list
    /// - Since: 1.1.1
    open func nextUserList() -> [SBUUser]? {
        return nil
    }
}
