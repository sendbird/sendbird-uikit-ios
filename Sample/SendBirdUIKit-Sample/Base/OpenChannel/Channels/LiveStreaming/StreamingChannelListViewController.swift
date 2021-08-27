//
//  StreamingChannelListViewController.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/11/15.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class StreamingChannelListViewController: SBUBaseChannelListViewController, SBUEmptyViewDelegate, UITableViewDataSource, UITableViewDelegate {
    // MARK: - UI properties (Public)
    lazy var titleView: UIView? = {
        var titleView: SBUNavigationTitleView
        if #available(iOS 11, *) {
            titleView = SBUNavigationTitleView()
        } else {
            titleView = SBUNavigationTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        titleView.text = SBUStringSet.ChannelList_Header_Title
        titleView.textAlignment = .center
        
        return titleView
    }()
    
    lazy var emptyView: UIView? = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()
    private(set) var tableView = UITableView()
    private lazy var guidelineCell: UITableViewCell = {
        let cell = UITableViewCell()
        let isDarkMode = (self.tabBarController as? MainOpenChannelTabbarController)?.isDarkMode ?? false
        
        cell.textLabel?.text = "Preset channels developed by UIKit"
        cell.textLabel?.font = SBUFontSet.body2
        cell.textLabel?.textColor = SBUTheme.channelCellTheme.memberCountTextColor
        cell.textLabel?.sbu_constraint(
            equalTo: cell.contentView,
            left: 16,
            top: 16,
            bottom: 8
        )
        cell.contentView.backgroundColor = SBUTheme.channelCellTheme.backgroundColor
        cell.isUserInteractionEnabled = false
        
        return cell
    }()
    
    var theme = SBUTheme.channelListTheme

    var channelCell = StreamingChannelCell()

    private var timer: Timer?
    
    
    // MARK: - Logic properties (Public)
    
    /// This object has a list of all channels.
    @SBUAtomic public private(set) var channelList: [SBDOpenChannel] = []
    
    /// This is a query used to get a list of channels. Only getter is provided, please use initialization function to set query directly.
    /// - note: For query properties, see `SBDOpenChannelListQuery` class.
    public private(set) var channelListQuery: SBDOpenChannelListQuery?
    
    public private(set) var isLoading = false
    public private(set) var limit: UInt = 20
    
    
    // MARK: - Logic properties (Private)
    
    
    // MARK: - Lifecycle
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        // tableview
        self.setupTableView()
        self.registerCell()
        self.setupNavigationItem()
        
        self.setupAutolayout()
        self.setupStyles()
    }
    
    /// Called in `loadView()`
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = self.emptyView
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)
    }
    
    /// Called in `loadView()`
    func registerCell() {
        let channelCellTyep = type(of: self.channelCell)
        let cellId = self.channelCell.sbu_className
        self.tableView.register(channelCellTyep, forCellReuseIdentifier: cellId)
    }
    
    /// Called in `loadView()`
    func setupNavigationItem() {
        self.navigationItem.titleView = self.titleView
    }

    override func setupAutolayout() {
        super.setupAutolayout()
        self.tableView.sbu_constraint(equalTo: self.view,
                                      left: 0,
                                      right: 0,
                                      top: 0,
                                      bottom: 0)
    }
    
    override func setupStyles() {
        super.setupStyles()
        
        self.theme = SBUTheme.channelListTheme
        
        let navigationBar = self.navigationController?.navigationBar
        navigationBar?.setBackgroundImage(UIImage.from(color: theme.navigationBarTintColor),
                                         for: .default)
        navigationBar?.shadowImage = UIImage.from(color: theme.navigationBarShadowColor)
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    override func updateStyles() {
        super.updateStyles()
        
        self.theme = SBUTheme.channelListTheme
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUNavigationTitleView {
            titleView.setupStyles()
        }
        
        self.reloadTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            self.loadNextChannelList(reset: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    deinit { }
    
    
    // MARK: - SDK Data relations
    
    /// This function loads the channel list. If the reset value is true, the channel list will reset.
    /// - Parameter reset: To reset the channel list
    public func loadNextChannelList(reset: Bool) {
        if self.isLoading { return }
        self.setLoading(true, false)
        
        if reset {
            self.channelListQuery = nil
            self.channelList = []
        }
        
        if self.channelListQuery == nil {
            self.channelListQuery = SBDOpenChannel.createOpenChannelListQuery()
            self.channelListQuery?.limit = self.limit
            self.channelListQuery?.customTypeFilter = "SB_LIVE_TYPE"
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
    
    /// Sorts the channel lists.
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
                emptyView.reloadData(self.channelList.isEmpty ? .noChannels : .none)
            }
            
            guard needReload else { return }
            
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Custom viewController relations
    
    /// Shows the channelViewController.
    ///
    /// If you want to use a custom channelViewController, override it and implement it.
    /// - Parameters:
    ///   - channelUrl: channel url for use in channelViewController.
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    ///   - streamingData:custom parameter for streaming channel.
    func showChannel(_ openChannel: SBDOpenChannel) {
        guard let streamingData = openChannel.toStreamChannel() else { return }
        let channelVC = StreamingChannelViewController(channel: openChannel, streamingData: streamingData)
        channelVC.hideChannelInfoView = false
        channelVC.enableMediaView()
        channelVC.mediaView = UIImageView()
        channelVC.mediaView.isUserInteractionEnabled = true
        channelVC.updateRatio(mediaView: 0.3, messageList: 0.7)
        channelVC.mediaViewIgnoringSafeArea(false)
        channelVC.channelDescription = streamingData.creatorInfo.name
        
        let channelNC = UINavigationController(rootViewController: channelVC)
        channelNC.modalPresentationStyle = .fullScreen
        self.present(channelNC, animated: true, completion: nil)
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
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        self.isLoading = loadingState
        guard showIndicator else { return }
        
        if loadingState {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }


    // MARK: - UITableView relations
    enum SectionType: Int {
        case guideline = 0
        case streamingChannels = 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        // 0: "Preset channels developed by UIKit"
        // 1: StreamingChannelCell
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = !self.channelList.isEmpty
        if section == SectionType.guideline.rawValue {
            return 1
        } else {
            return self.channelList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case SectionType.guideline.rawValue:
            let cell = guidelineCell
            cell.textLabel?.textColor = SBUTheme.channelCellTheme.memberCountTextColor
            cell.contentView.backgroundColor = SBUTheme.channelCellTheme.backgroundColor
            
            return cell
        default:
            let channel = self.channelList[indexPath.row]
            var cell: SBUBaseChannelCell? = nil
            let cellId = self.channelCell.sbu_className
            
            cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? SBUBaseChannelCell
            cell?.selectionStyle = .none
            cell?.configure(channel: channel)
            
            return cell ?? UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard !self.channelList.isEmpty else { return }
        guard !self.isLoading else { return }
        guard let query = self.channelListQuery else { return }
        guard query.hasNext == true else { return }
        guard indexPath.row == (self.channelList.count - Int(self.limit) / 2) else { return }
        
        self.loadNextChannelList(reset: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = self.channelList[indexPath.row]
        self.showChannel(channel)
    }

    // MARK: - SBUEmptyViewDelegate
    func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noChannels)
        }
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            self.loadNextChannelList(reset: true)
        }
    }
}
