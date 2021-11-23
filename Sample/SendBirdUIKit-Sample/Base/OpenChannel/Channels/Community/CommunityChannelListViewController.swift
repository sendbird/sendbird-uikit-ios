//
//  CommunityChannelListViewController.swift
//  SendBirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/18.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class CommunityChannelListViewController: SBUBaseChannelListViewController, SBUEmptyViewDelegate, SBDChannelDelegate, UITableViewDataSource, UITableViewDelegate {
    var theme: SBUChannelListTheme = SBUTheme.channelListTheme
    
    @SBUAtomic var channelList: [SBDOpenChannel] = []
    var channelListQuery: SBDOpenChannelListQuery?
    
    var tableView = UITableView()
    var channelCell: SBUBaseChannelCell = CommunityChannelCell()
    
    lazy var rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: SBUIconSet.iconCreate.resize(
                with: CGSize(width: 24, height: 24)
            ),
            style: .plain,
            target: self,
            action: #selector(onClickCreate)
        )
    }()
    lazy var emptyView: UIView? = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()

    var isLoading = false
    var limit: UInt = 20
    
    // MARK: - Lifecycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override methods
    // MARK: View life cycle
    override func loadView() {
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
        
        self.tableView.register(
            type(of: self.channelCell),
            forCellReuseIdentifier: self.channelCell.sbu_className
        )
        
        // navigation bar
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        
        // autolayout
        self.setupAutolayout()
        
        // Styles
        self.setupStyles()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        SBUMain.connectIfNeeded { [weak self] user, error in
            guard let self = self else { return }
            
            SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
            self.loadNextChannelList(reset: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
        
        self.updateStyles()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme.statusBarStyle
    }
    
    // MARK: SBUBaseChannelListViewController Methods
    override func setupAutolayout() {
        self.tableView.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    override func setupStyles() {
        self.theme = SBUTheme.channelListTheme
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationBarShadowColor
        )
        self.navigationController?.sbu_setupNavigationBarAppearance(
            tintColor: theme.navigationBarTintColor
        )
        
        self.rightBarButton.tintColor = theme.rightBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    override func updateStyles() {
        self.theme = SBUTheme.channelListTheme
        
        self.setupStyles()
        
        self.reloadTableView()
    }
    
    /// Shows channel based channel URL
    override func showChannel(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
        let channelVC = SBUOpenChannelViewController(channelUrl: channelUrl, messageListParams: messageListParams)
        
        self.navigationController?.pushViewController(channelVC, animated: true)
    }

    
    // MARK: - SDK Data relations
    
    /// Loads the channel list. If the reset value is true, the channel list will reset.
    func loadNextChannelList(reset: Bool) {
        if self.isLoading { return }
        self.setLoading(true, false)
        
        if reset {
            self.channelListQuery = nil
            self.channelList = []
        }
        
        if self.channelListQuery == nil {
            self.channelListQuery = SBDOpenChannel.createOpenChannelListQuery()
            self.channelListQuery?.limit = self.limit
            self.channelListQuery?.customTypeFilter = "SB_COMMUNITY_TYPE"
        }
        
        guard self.channelListQuery?.hasNext == true else {
            self.setLoading(false, false)
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { [weak self] channels, error in
            defer { self?.setLoading(false, false) }
            
            guard error == nil else {
                self?.showNetworkError()
                return
            }
            guard let channels = channels else { return }
            
            self?.channelList += channels
            self?.sortChannelList(needReload: true)
        })
    }
    
    /// Sorts channel list
    func sortChannelList(needReload: Bool) {
        let sortedChannelList = self.channelList
            .sorted(by: { (lhs: SBDOpenChannel, rhs: SBDOpenChannel) -> Bool in
                let createdAt1 = lhs.createdAt
                let createdAt2 = rhs.createdAt
                return createdAt1 > createdAt2
            })
        
        self.channelList = sortedChannelList.sbu_unique()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData((self.channelList.count == 0) ? .noChannels : .none)
            }
            
            guard needReload else { return }
            
            self.tableView.reloadData()
        }
    }
    
    /// Upserts the channels.
    func upsertChannels(_ channels: [SBDOpenChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
            guard let index = self.channelList.firstIndex(of: channel) else {
                self.channelList.append(channel)
                continue
            }
            self.channelList.append(self.channelList.remove(at: index))
        }
        self.sortChannelList(needReload: needReload)
    }
    
    /// Deletes the channels using the channel urls.
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
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.error)
        }
        
        self.reloadTableView()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    /// Checks the loading status and control loading indicator.
    func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        self.isLoading = loadingState
        guard showIndicator else { return }
        
        if loadingState {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }
    
    // MARK: - Action
    
    @objc func onClickCreate() {
        let createChannelVC = CreateCommunityChannelViewController()
        self.navigationController?.pushViewController(createChannelVC, animated: true)
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = self.channelList[indexPath.row]
        self.showChannel(channelUrl: channel.channelUrl)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let channel = self.channelList[indexPath.row]
        
        var cell: CommunityChannelCell? = nil
        
        cell = tableView.dequeueReusableCell(withIdentifier: self.channelCell.sbu_className) as? CommunityChannelCell
        
        cell?.selectionStyle = .none
        cell?.configure(channel: channel)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !self.channelList.isEmpty else { return }
        guard let query = channelListQuery else { return }
        guard query.hasNext else { return }
        guard indexPath.row == (self.channelList.count - Int(self.limit) / 2) else { return }
        guard !self.isLoading else { return }
        
        self.loadNextChannelList(reset: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = !self.channelList.isEmpty
        
        return self.channelList.count
    }

    // MARK: - SBUEmptyViewDelegate
    public func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noChannels)
        }
        
        SBUMain.connectIfNeeded { [weak self] user, error in
            self?.loadNextChannelList(reset: true)
        }
    }

    // MARK: - SBDChannelDelegate
    
    func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        self.upsertChannels([sender], needReload: true)
    }
    
    func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        self.upsertChannels([sender], needReload: true)
    }
    // when delete channel
    func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {
        guard channelType == .open else { return }
        self.deleteChannels(channelUrls: [channelUrl], needReload: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func channelWasFrozen(_ sender: SBDBaseChannel) {
        guard let channel = sender as? SBDOpenChannel else { return }
        self.upsertChannels([channel], needReload: true)
    }
    
    func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        guard let channel = sender as? SBDOpenChannel else { return }
        self.upsertChannels([channel], needReload: true)
    }
}
