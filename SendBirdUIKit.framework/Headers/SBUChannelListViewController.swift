//
//  SBUChannelListViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objcMembers
open class SBUChannelListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDChannelDelegate, SBDConnectionDelegate, SBUEmptyViewDelegate {
    
    // MARK: - Public property
    // for UI
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton

    
    // MARK: - Private property
    // for UI
    var theme: SBUChannelListTheme = SBUTheme.channelListTheme

    private lazy var titleView: SBUNavigationTitleView = _titleView
    private var tableView = UITableView()
    private lazy var _titleView: SBUNavigationTitleView = {
        let titleView = SBUNavigationTitleView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        titleView.text = SBUStringSet.ChannelList_Header_Title
        titleView.textAlignment = .center
        
        return titleView
    }()

    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem( image: nil,
                         style: .plain,
                         target: self,
                         action: #selector(onClickBack) )
    }()
    
    private lazy var _rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem( image: nil,
                                style: .plain,
                                target: self,
                                action: #selector(onClickCreate) )
    }()
    
    private lazy var emptyView: SBUEmptyView = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()

    // for Logic
    @SBUAtomic var channelList: [SBDGroupChannel] = []
    var channelListQuery: SBDGroupChannelListQuery?
    var lastUpdatedTimestamp: Int64 = 0
    var lastUpdatedToken: String? = nil
    var isLoading = false
    var limit: UInt = 20

    // for cell
    var channelCell: SBUBaseChannelCell? = nil
    var customCell: SBUBaseChannelCell? = nil

    // MARK: - Lifecycle
    open override func loadView() {
        super.loadView()

        // tableview
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = self.emptyView
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)

        if self.channelCell == nil {
            self.register(channelCell: SBUChannelCell())
        }

        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        self.navigationItem.titleView = self.titleView
        
        // autolayout
        self.setupAutolayout()
        
        // Styles
        self.setupStyles()
    }
    
    public func setupAutolayout() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        ])
    }
    
    public func setupStyles() {
        
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = theme.navigationBarTintColor
        self.navigationController?.navigationBar.shadowImage = UIImage.from(color: theme.navigationBarShadowColor)

        self.view.backgroundColor = theme.backgroundColor
        self.leftBarButton?.image = SBUIconSet.iconBack
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
       
        self.rightBarButton?.image = SBUIconSet.iconCreate
        self.rightBarButton?.tintColor = theme.rightBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error { self.didReceiveError(error.localizedDescription) }
        
            SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
            SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
            
            self.loadNextChannelList(reset: true)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.setupStyles()

        if self.isLoading { return }
        self.loadChannelChangeLogs(hasMore: true, token: self.lastUpdatedToken)
    }

    deinit {
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
    }

    
    // MARK: - Custom viewController relations
    
    /// If you want to use a custom channelViewController, override it and implement it.
    /// - Parameter channelUrl: channel url for use in channelViewController.
    open func showChannel(channelUrl: String) {
        let channelVC = SBUChannelViewController(channelUrl: channelUrl)
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    /// If you want to use a custom createChannelViewController, override it and implement it.
    open func showCreateChannel() {
        let createChannelVC = SBUCreateChannelViewController()
        self.navigationController?.pushViewController(createChannelVC, animated: true)
    }
    
    
    // MARK: - SDK Data relations
    func loadNextChannelList(reset: Bool) {
        if self.isLoading { return }
        self.setLoading(true, false)
        
        if reset {
            self.channelListQuery = nil
            self.channelList = []
            self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
            self.lastUpdatedToken = nil
        }
        
        if self.channelListQuery == nil {
            self.channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
            self.channelListQuery?.order = .latestLastMessage
            self.channelListQuery?.limit = self.limit
            self.channelListQuery?.includeEmptyChannel = false
        }
        
        guard self.channelListQuery?.hasNext == true else {
            self.setLoading(false, false)
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { [weak self] channels, error in
            defer { self?.setLoading(false, false) }
            
            guard error == nil else {
                self?.didReceiveError(error?.localizedDescription)
                self?.showNetworkError()
                return
            }
            guard let channels = channels else { return }
            
            self?.channelList += channels
            self?.sortChannelList(needReload: true)
            self?.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
        })
    }
    
    func loadChannelChangeLogs(hasMore: Bool, token: String?) {
        guard hasMore == true else {
            self.sortChannelList(needReload: true)
            return
        }
        
        if let token = token {
            SBDMain.getMyGroupChannelChangeLogs(byToken: token, customTypes: nil) { [weak self] updatedChannels, deletedChannelUrls, hasMore, token, error in
                if let error = error { self?.didReceiveError(error.localizedDescription) }
                
                self?.lastUpdatedToken = token
                
                self?.upsertChannels(channels: updatedChannels, needReload: false)
                self?.deleteChannels(channelUrls: deletedChannelUrls, needReload: false)
                
                self?.loadChannelChangeLogs(hasMore: hasMore, token: token)
            }
        }
        else {
            SBDMain.getMyGroupChannelChangeLogs(byTimestamp: self.lastUpdatedTimestamp, customTypes: nil) { [weak self] updatedChannels, deletedChannelUrls, hasMore, token, error in
                if let error = error { self?.didReceiveError(error.localizedDescription) }

                self?.lastUpdatedToken = token
                
                self?.upsertChannels(channels: updatedChannels, needReload: false)
                self?.deleteChannels(channelUrls: deletedChannelUrls, needReload: false)
                
                self?.loadChannelChangeLogs(hasMore: hasMore, token: token)
            }
        }
    }
    
    func sortChannelList(needReload: Bool) {
        let sortedChannelList = self.channelList.sorted(by: { (lhs: SBDGroupChannel, rhs: SBDGroupChannel) -> Bool in            
            var createdAt1: Int64
            var createdAt2: Int64
            
            if let m1 = lhs.lastMessage, let m2 = rhs.lastMessage {
                createdAt1 = m1.createdAt
                createdAt2 = m2.createdAt
            } else if lhs.lastMessage == nil, let m2 = rhs.lastMessage {
                createdAt1 = -1
                createdAt2 = m2.createdAt
            } else if let m1 = lhs.lastMessage, rhs.lastMessage == nil {
                createdAt1 = m1.createdAt
                createdAt2 = -1;
            } else {
                createdAt1 = Int64(lhs.createdAt*1000)
                createdAt2 = Int64(rhs.createdAt*1000)
            }
            
            return createdAt1 > createdAt2
        })
        
        self.channelList = sortedChannelList.unique()
        DispatchQueue.main.async {
            self.emptyView.updateType((self.channelList.count == 0) ? .noChannels : .none)
            
            guard needReload == true else { return }
            
            self.tableView.reloadData()
        }
    }
    
    func updateChannels(channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
            guard let index = self.channelList.firstIndex(of: channel) else { continue }
            self.channelList.append(self.channelList.remove(at: index))
        }
        self.sortChannelList(needReload: needReload)
    }
    
    func upsertChannels(channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
            guard channel.lastMessage != nil else { continue }
            guard let index = self.channelList.firstIndex(of: channel) else {
                self.channelList.append(channel)
                continue
            }
            self.channelList.append(self.channelList.remove(at: index))
        }
        self.sortChannelList(needReload: needReload)
    }
    
    func deleteChannels(channelUrls: [String]?, needReload: Bool) {
        guard let channelUrls = channelUrls else { return }
        
        var toBeDeleteIndexes: [Int] = []
        
        for channelUrl in channelUrls {
            if let index = self.channelList.firstIndex(where: { $0.channelUrl == channelUrl }) {
                toBeDeleteIndexes.append(index)
            }
        }
        
        // for remove from last
        let sortedIndexes = toBeDeleteIndexes.sorted().reversed()
        
        for toBeDeleteIdx in sortedIndexes {
            self.channelList.remove(at: toBeDeleteIdx)
        }
        
        self.sortChannelList(needReload: needReload)
    }
    
    
    // MARK: - Common
    func showNetworkError() {
        self.channelListQuery = nil
        self.channelList = []
        self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
        self.emptyView.updateType(.error)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    public func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        self.isLoading = loadingState
        guard showIndicator == true else { return }
        
        if loadingState == true {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }

    
    // MARK: - Actions
    func onClickBack() {
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func onClickCreate() {
        self.showCreateChannel()
    }
    
    
    // MARK: - UITableView relations
    
    /// Used to register a custom cell as a base cell based on SBUBaseChannelCell.
    /// - Parameters:
    ///   - channelCell: Customized channel cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(channelCell: SBUBaseChannelCell, nib: UINib? = nil) {
        self.channelCell = channelCell

        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: channelCell.className)
        } else {
            self.tableView.register(type(of: channelCell), forCellReuseIdentifier: channelCell.className)
        }
    }
    
    /// Used to register a custom cell as a additional cell based on SBUBaseChannelCell.
    /// - Parameters:
    ///   - customCell: Customized channel cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(customCell: SBUBaseChannelCell?, nib: UINib? = nil) {
        self.customCell = customCell

        guard let customCell = customCell else { return }
        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: customCell.className)
        } else {
            self.tableView.register(type(of: customCell), forCellReuseIdentifier: customCell.className)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showChannel(channelUrl: self.channelList[indexPath.row].channelUrl)
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = self.channelList[indexPath.row]

        var cell: SBUBaseChannelCell? = nil
        
        if let customCell = self.customCell, let customType = channel.customType, !customType.isEmpty {
            cell = tableView.dequeueReusableCell(withIdentifier: customCell.className) as? SBUBaseChannelCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: self.channelCell?.className ?? SBUBaseChannelCell.className) as? SBUBaseChannelCell
        }

        cell?.selectionStyle = .none
        cell?.configure(channel: channel)
        return cell ?? UITableViewCell()

    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.channelList.count > 0,
            self.channelListQuery?.hasNext == true,
            indexPath.row == (self.channelList.count - Int(self.limit)/2),
            self.isLoading == false,
            self.channelListQuery != nil
        {
            self.loadNextChannelList(reset: false)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = (self.channelList.count != 0)

        return self.channelList.count
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let index = indexPath.row
        let channel = self.channelList[index]
        let size = tableView.visibleCells[0].frame.height
        let iconSize: CGFloat = 40.0
        
        let leaveAction = UIContextualAction(style: .normal, title: "") { action, view, success in
            channel.leave { [weak self] error in
                if let error = error { self?.didReceiveError(error.localizedDescription) }
            }
            success(true)
        }
        
        let leaveTypeView = UIImageView(frame: CGRect(x: (size-iconSize)/2, y: (size-iconSize)/2, width: iconSize, height: iconSize))
        leaveTypeView.layer.cornerRadius = iconSize/2
        leaveTypeView.backgroundColor = theme.leaveBackgroundColor

        let leaveIcon = SBUIconSet.iconActionLeave.with(tintColor: theme.leaveTintColor)
        
        leaveAction.backgroundColor = UIColor.from(image: leaveIcon, imageView: leaveTypeView, size: size, backgroundColor: theme.alertBackgroundColor)
        

        let pushOption = channel.myPushTriggerOption
        
        let alarmAction = UIContextualAction(style: .normal, title: "") { action, view, success in
            channel.setMyPushTriggerOption(pushOption == .off ? .all : .off) { [weak self] error in
                if let error = error { self?.didReceiveError(error.localizedDescription) }
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
            success(true)
        }
        
        let alarmTypeView = UIImageView(frame: CGRect(x: (size-iconSize)/2, y: (size-iconSize)/2, width: iconSize, height: iconSize))
        alarmTypeView.layer.cornerRadius = iconSize/2
        let alarmIcon: UIImage
        if pushOption == .off {
            alarmTypeView.backgroundColor = theme.notificationOnBackgroundColor
            alarmIcon = SBUIconSet.iconActionNotificationOn.with(tintColor: theme.notificationOnTintColor)
        } else {
            alarmTypeView.backgroundColor = theme.notificationOffBackgroundColor
            alarmIcon = SBUIconSet.iconActionNotificationOff.with(tintColor: theme.notificationOffTintColor)
        }
        
        alarmAction.backgroundColor = UIColor.from(image: alarmIcon, imageView: alarmTypeView, size: size, backgroundColor: theme.alertBackgroundColor)
        
        return UISwipeActionsConfiguration(actions: [leaveAction, alarmAction])
    }

    @available(iOS, deprecated: 13.0)
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if #available(iOS 11.0, *) { return nil }
        
        let index = indexPath.row
        let channel = self.channelList[index]
        let size = tableView.visibleCells[0].frame.height
        let iconSize: CGFloat = 40.0
        
        let leave = UITableViewRowAction(style: .normal, title: "") { action, indexPath in
            channel.leave { [weak self] error in
                if let error = error { self?.didReceiveError(error.localizedDescription) }
            }
        }
        
        leave.title = SBUUtils.emptyTitleForRowEditAction(for: CGSize(width: size, height: size))
        
        let leaveTypeView = UIImageView(frame: CGRect(x: (size-iconSize)/2, y: (size-iconSize)/2, width: iconSize, height: iconSize))
        leaveTypeView.layer.cornerRadius = iconSize/2
        leaveTypeView.backgroundColor = theme.leaveBackgroundColor
        let leaveIcon = SBUIconSet.iconActionLeave.with(tintColor: theme.leaveTintColor)
        
        leave.backgroundColor = UIColor.from(image: leaveIcon, imageView: leaveTypeView, size: size, backgroundColor: theme.alertBackgroundColor)

        
        let pushOption = channel.myPushTriggerOption
        let alarm = UITableViewRowAction(style: .normal, title: "") { action, indexPath in
            channel.setMyPushTriggerOption(pushOption == .off ? .all : .off) { [weak self] error in
                if let error = error { self?.didReceiveError(error.localizedDescription) }

                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }

        alarm.title = SBUUtils.emptyTitleForRowEditAction(for: CGSize(width: size, height: size))
        
        let alarmTypeView = UIImageView(frame: CGRect(x: (size-iconSize)/2, y: (size-iconSize)/2, width: iconSize, height: iconSize))
        alarmTypeView.layer.cornerRadius = iconSize/2
        let alarmIcon: UIImage
        if pushOption == .off {
            alarmTypeView.backgroundColor = theme.notificationOnBackgroundColor
            alarmIcon = SBUIconSet.iconActionNotificationOn.with(tintColor: theme.notificationOnTintColor)
        } else {
            alarmTypeView.backgroundColor = theme.notificationOffBackgroundColor
            alarmIcon = SBUIconSet.iconActionNotificationOff.with(tintColor: theme.notificationOffTintColor)
        }
        
        alarm.backgroundColor = UIColor.from(image: alarmIcon, imageView: alarmTypeView, size: size, backgroundColor: theme.alertBackgroundColor)

        return [leave, alarm]
    }
    
    
    // MARK: - SBDChannelDelegate
    open func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        if self.channelListQuery?.includeEmptyChannel == false {
            self.updateChannels(channels: [sender], needReload: true)
        } else {
            self.upsertChannels(channels: [sender], needReload: true)
        }
    }
        
    open func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        guard user.userId == SBUGlobals.CurrentUser?.userId else { return }

        self.deleteChannels(channelUrls: [sender.channelUrl], needReload: true)
    }
    
    open func channelWasChanged(_ sender: SBDBaseChannel) {
        guard let channel = sender as? SBDGroupChannel else { return }
        self.upsertChannels(channels: [channel], needReload: true)
    }
    
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard let channel = sender as? SBDGroupChannel else { return }
        self.upsertChannels(channels: [channel], needReload: false)
    }
    
    
    // MARK: - Error handling
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameter message: error message
    open func didReceiveError(_ message: String?) {
        
    }
    
    
    // MARK: - SBDConnectionDelegate
    open func didSucceedReconnection() {
        self.loadChannelChangeLogs(hasMore: true, token: self.lastUpdatedToken)
    }
    
    
    // MARK: - SBUEmptyViewDelegate
    func didSelectRetry() {
        self.emptyView.updateType(.noChannels)
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error { self.didReceiveError(error.localizedDescription) }
        
            SBDMain.removeChannelDelegate(forIdentifier: self.description)
            SBDMain.removeConnectionDelegate(forIdentifier: self.description)
            
            SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
            SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
            
            self.loadNextChannelList(reset: true)
        }
    }
}
