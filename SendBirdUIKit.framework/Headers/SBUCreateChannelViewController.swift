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
open class SBUCreateChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    // MARK: - Public property
    // for UI
    
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    
    
    // MARK: - Private property
    // for UI
    var theme: SBUUserListTheme = SBUTheme.userListTheme
    
    private lazy var titleView: SBUNavigationTitleView = _titleView
    private var tableView = UITableView()
    
    private lazy var _titleView: SBUNavigationTitleView = {
        let titleView = SBUNavigationTitleView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        titleView.text = SBUStringSet.CreateChannel_Header_Title
        titleView.textAlignment = .center
        return titleView
    }()
    
    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem(image: nil,
                               style: .plain,
                               target: self,
                               action: #selector(onClickBack) )
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(title: SBUStringSet.CreateChannel_Create(0),
                               style: .plain,
                               target: self,
                               action: #selector(onClickCreate) )
    }()
    
    // for logic
    @SBUAtomic private var customizedUsers: [SBUUser]?
    @SBUAtomic var userList: [SBUUser] = []
    @SBUAtomic var selectedUserList: Set<SBUUser> = []
    var userListQuery: SBDApplicationUserListQuery?
    var isLoading = false
    let limit: UInt = 20
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUCreateChannelViewController.init()")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    convenience public init() {
        self.init(users: nil)
    }

    /// If you have user objects, use this initialize function.
    /// - Parameter users: User object
    public init(users: [SBUUser]?) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        self.customizedUsers = users
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
        self.tableView.register(SBUUserCell.loadNibForSB(), forCellReuseIdentifier: SBUUserCell.className) // for xib
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
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.from(color: theme.navigationBarTintColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.from(color: theme.navigationShadowColor)

        self.leftBarButton?.image = SBUIconSet.iconBack
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = self.selectedUserList.isEmpty ? theme.rightBarButtonTintColor : theme.rightBarButtonSelectedTintColor

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
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
    open func loadNextUserList(reset: Bool, users: [SBUUser]? = nil) {
        if self.isLoading { return }
        self.isLoading = true
        
        if reset {
            self.userListQuery = nil
            self.userList = []
            
            SBULog.info("[Request] User List")
        } else {
            SBULog.info("[Request] Next user List")
        }

        if let users = users {
            // for using customized user list
            if self.customizedUsers != nil {
                self.customizedUsers! += users
            }
            
            SBULog.info("\(users.count) customized users have been added.")
            
            self.userList += users
            self.reloadUserList()
            self.isLoading = false
        }
        else if self.customizedUsers == nil {
            if self.userListQuery == nil {
                self.userListQuery = SBDMain.createApplicationUserListQuery()
                self.userListQuery?.limit = self.limit
            }
            
            guard self.userListQuery?.hasNext == true else {
                self.isLoading = false
                SBULog.info("All users have been loaded.")
                return
            }
            
            self.userListQuery?.loadNextPage(completionHandler: { [weak self] users, error in
                defer { self?.isLoading = false }
                
                if let error = error {
                    SBULog.error("[Failed] User list request: \(error.localizedDescription)")
                    self?.didReceiveError(error.localizedDescription)
                    return
                }
                let filteredUsers = users?.filter { $0.userId != SBUGlobals.CurrentUser?.userId }

                guard let users = SBUUserManager.convertUserList(users: filteredUsers) else { return }
                
                SBULog.info("[Response] \(users.count) users")
                
                self?.userList += users
                self?.reloadUserList()
                self?.isLoading = false
            })
        }
    }
    
    /// Creates the channel with userIds.
    /// - Parameter params: `SBDGroupChannelParams` class object
    /// - Since: 1.0.9
    public func createChannel(userIds: [String]) {
        let params = SBDGroupChannelParams()
        params.name = ""
        params.coverUrl = ""
        params.addUserIds(userIds)
        params.isDistinct = false

        self.createChannel(params: params)
    }
    
    /// Creates the channel with channelParams.
    ///
    /// You can create a channel by setting various properties of ChannelParams.
    /// - Parameter params: `SBDGroupChannelParams` class object
    /// - Since: 1.0.9
    public func createChannel(params: SBDGroupChannelParams) {
        SBULog.info("[Request] Create channel with users, Users: \(Array(self.selectedUserList))")
        SBDGroupChannel.createChannel(with: params) { [weak self] channel, error in
            if let error = error {
                SBULog.error("[Failed] Create channel request: \(String(error.localizedDescription))")
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
    
    
    // MARK: - Common
    func reloadUserList() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
    
    @objc private func onClickCreate() {
        guard selectedUserList.isEmpty == false else { return }
        
        let userIds = SBUUserManager.getUserIds(users: Array(self.selectedUserList))
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
    }
    
    
    // MARK: - UITableView relations
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.className) as? SBUUserCell
            else { return UITableViewCell() }
        let user = userList[indexPath.row]
        cell.selectionStyle = .none
        cell.configure(type: .createChannel,
                       user:user,
                       isChecked: self.selectedUserList.contains(user))
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userList[indexPath.row]
        self.selectUser(user: user)
        
        let cell = self.tableView.cellForRow(at: indexPath) as? SBUUserCell
        cell?.setSelected(isChecked: self.selectedUserList.contains(user))
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.userList.count > 0,
            self.userListQuery?.hasNext == true,
            indexPath.row == (self.userList.count - Int(self.limit)/2),
            self.isLoading == false,
            self.userListQuery != nil
        {
            self.loadNextUserList(reset: false, users: self.customizedUsers ?? nil)
        }
    }
    
    
    // MARK: - Error handling
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
}
