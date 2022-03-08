//
//  SBUChannelListViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUChannelListViewController: SBUBaseChannelListViewController {
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
    
    public var emptyView: UIView? = nil {
        didSet { self.tableView.backgroundView = self.emptyView }
    }
    
    public private(set) var tableView = UITableView()
    
    @SBUThemeWrapper(theme: SBUTheme.channelListTheme)
    public var theme: SBUChannelListTheme

    /// This is a function that allows you to select the channel type when creating a channel.
    /// If set to the nil value, it is moved to groupChannel creation.
    /// - note: Type: GroupChannel / SuperGroupChannel / BroadcastChannel
    /// - Since: 1.2.0
    public lazy var createChannelTypeSelector: UIView? = nil

    // for cell
    public private(set) var channelCell: SBUBaseChannelCell? = nil
    public private(set) var customCell: SBUBaseChannelCell? = nil


    // MARK: - UI properties (Private)
    private lazy var defaultTitleView: SBUNavigationTitleView = {
        var titleView = SBUNavigationTitleView()
        titleView.text = SBUStringSet.ChannelList_Header_Title
        titleView.textAlignment = .center
        
        return titleView
    }()
    
    private lazy var backButton: UIBarButtonItem = SBUCommonViews.backButton(
        vc: self,
        selector: #selector(onClickBack)
    )
    
    private lazy var createChannelButton: UIBarButtonItem = UIBarButtonItem(
        image: SBUIconSetType.iconCreate.image(to: SBUIconSetType.Metric.defaultIconSize),
        style: .plain,
        target: self,
        action: #selector(onClickCreate)
    )
    
    private lazy var defaultCreateChannelTypeSelector: SBUCreateChannelTypeSelector = {
        let view = SBUCreateChannelTypeSelector(delegate: self)
        view.isHidden = true
        return view
    }()
    
    private lazy var defaultEmptyView: SBUEmptyView? = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()
    
    
    // MARK: - Logic properties (Public)
    
    /// This object has a list of all channels.
    @SBUAtomic public private(set) var channelList: [SBDGroupChannel] = []
    
    /// This is a query used to get a list of channels. Only getter is provided, please use initialization function to set query directly.
    /// - note: For query properties, see `SBDGroupChannelListQuery` class.
    /// - Since: 1.0.11
    public var channelListQuery: SBDGroupChannelListQuery? { self.channelListViewModel?.channelListQuery }
    
    public var isLoading: Bool { channelListViewModel?.isLoading ?? false }
    public var lastUpdatedTimestamp: Int64 { channelListViewModel?.lastUpdatedTimestamp ?? Int64(Date().timeIntervalSince1970 * 1000) }
    public var lastUpdatedToken: String? { channelListViewModel?.lastUpdatedToken }
    public var limit: UInt { SBUChannelListViewModel.channelLoadLimit }
    public var includeEmptyChannel: Bool { channelListViewModel?.channelListQuery?.includeEmptyChannel ?? false }
    
    
    // MARK: - Logic properties (Private)
    var customizedChannelListQuery: SBDGroupChannelListQuery? = nil
    
    private var channelListViewModel: SBUChannelListViewModel? {
        didSet { bindViewModel() }
        willSet { disposeViewModel() }
    }
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUChannelListViewController()")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }

    /// You can initialize the class through this function.
    /// If you have `channelListQuery`, please set it. If not set, it is used as default value.
    ///
    /// See the example below for query generation.
    /// ```
    ///     let query = SBDGroupChannel.createMyGroupChannelListQuery()
    ///     query?.includeEmptyChannel = false
    ///     query?.includeFrozenChannel = true
    ///     ...
    /// ```
    /// - Parameter channelListQuery: Your own `SBDGroupChannelListQuery` object
    /// - Since: 1.0.11
    public init(channelListQuery: SBDGroupChannelListQuery? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.customizedChannelListQuery = channelListQuery
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
            self.rightBarButton = self.createChannelButton
        }
        if self.emptyView == nil {
            self.emptyView = self.defaultEmptyView
        }
        
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
    
    open override func setupAutolayout() {
        super.setupAutolayout()
        
        self.tableView.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
        
        if let view = self.navigationController?.view,
            let createChannelTypeSelector = self.createChannelTypeSelector {
            createChannelTypeSelector.sbu_constraint(
                equalTo: view,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
        }
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationBarShadowColor
        )
        
        // For iOS 15
        self.navigationController?.sbu_setupNavigationBarAppearance(tintColor: theme.navigationBarTintColor)
        
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.rightBarButtonTintColor
        
        if let createChannelTypeSelector = self.createChannelTypeSelector as? SBUCreateChannelTypeSelector {
            createChannelTypeSelector.setupStyles()
        }
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        super.updateStyles()
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUNavigationTitleView {
            titleView.setupStyles()
        }
        
        self.reloadTableView()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme.statusBarStyle
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)
        
        SBUMain.connectIfNeeded { user, error in
            if let error = error {
                self.errorHandler(error)
                return
            }
            
            self.initChannelList()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
    }
    
    deinit {
        SBULog.info("")
        disposeViewModel()
        
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
    }
    
    
    // MARK: - View Binding
    
    /// Recreates the view model, loading initial messages from given starting point.
    /// - Parameters:
    ///     - startingPoint: The starting point timestamp of the messages. `nil` to start from the latest.
    ///     - showIndicator: Whether to show loading indicator on loading the initial messages.
    func createViewModel() {
        self.channelListViewModel = SBUChannelListViewModel(
            customizedChannelListQuery: self.customizedChannelListQuery
        )
    }

    private func bindViewModel() {
        SBULog.info("bindViewModel")
        guard let channelListViewModel = self.channelListViewModel else { return }
        
        channelListViewModel.errorObservable.observe { [weak self] error in
            guard let self = self else { return }
            
            SBULog.error("""
                    [Failed] \(String(describing: error.localizedDescription))
                    """)
            self.errorHandler(error)
            self.showNetworkError()
        }
        
        channelListViewModel.loadingObservable.observe { [weak self] loadingState in
            guard let self = self else { return }
            
            if loadingState {
                self.shouldShowLoadingIndicator()
            } else {
                self.shouldDismissLoadingIndicator()
            }
        }
        
        channelListViewModel.channelDeleteObservable.observe {
            [weak self] deletedChannelUrls in
            
            guard let self = self else { return }
            
            if !deletedChannelUrls.isEmpty {
                self.deleteChannels(channelUrls: deletedChannelUrls, needReload: true)
            }
        }
        
        channelListViewModel.channelUpsertObservable.observe {
            [weak self] channels in
            
            guard let self = self else { return }
            
            self.upsertChannels(channels, needReload: true)
        }
    }
    
    private func disposeViewModel() {
        self.channelListViewModel?.dispose()
    }
    
    
    // MARK: - SDK Data relations
    
    /// Changes push trigger option on a channel.
    /// - Parameters:
    ///   - option: Push trigger option to change
    ///   - channel: Channel to change option
    ///   - completionHandler: Completion handler
    /// - Since: 1.0.9
    public func changePushTriggerOption(option: SBDGroupChannelPushTriggerOption,
                                        channel: SBDGroupChannel,
                                        completionHandler: ((Bool)-> Void)? = nil) {
        SBULog.info("""
            [Request]
            Channel push status: \(option == .off ? "on" : "off"),
            ChannelUrl: \(channel.channelUrl)
            """)
        channel.setMyPushTriggerOption(option) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                SBULog.error("""
                    [Failed]
                    Channel push status request: \(String(error.localizedDescription))
                    """)
                completionHandler?(false)
                self.errorHandler(error)
                return
            }
            
            SBULog.info("[Succeed] Channel push status, ChannelUrl: \(channel.channelUrl)")
            
            completionHandler?(true)
        }
    }
    
    /// Leaves the channel.
    /// - Parameters:
    ///   - channel: Channel to leave
    ///   - completionHandler: Completion handler
    /// - Since: 1.0.9
    public func leaveChannel(_ channel: SBDGroupChannel,
                             completionHandler: ((Bool)-> Void)? = nil) {
        SBULog.info("[Request] Leave channel, ChannelUrl: \(channel.channelUrl)")
        
        channel.leave { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                SBULog.error("""
                    [Failed]
                    Leave channel request: \(String(error.localizedDescription))
                    """)
                completionHandler?(false)
                self.errorHandler(error)
                return
            }
            
            SBULog.info("[Succeed] Leave channel request, ChannelUrl: \(channel.channelUrl)")
            
            completionHandler?(true)
        }
    }
    
    /// This function resets the channel list.
    /// - Since: x.x.x
    public func resetChannelList() {
        self.channelList = []
        self.channelListViewModel?.reset()
    }

    /// This function loads the channel list. If the reset value is true, the channel list will reset.
    /// - Parameter reset: To reset the channel list
    /// - Since: 1.2.5
    public func loadNextChannelList(reset: Bool) {
        if reset {
            self.resetChannelList()
        }
        self.channelListViewModel?.loadNextChannelList()
    }
    
    /// This function sorts the channel lists.
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func sortChannelList(needReload: Bool) {
        let sortedChannelList = self.channelList
            .sorted(by: { (lhs: SBDGroupChannel, rhs: SBDGroupChannel) -> Bool in
                return SBDGroupChannel.compare(withChannelA: lhs, channelB: rhs, order: channelListQuery?.order ?? .latestLastMessage) == .orderedAscending
            })
        
        self.channelList = sortedChannelList.sbu_unique()

        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(self.channelList.isEmpty ? .noChannels : .none)
        }
        
        guard needReload else { return }
        
        self.reloadTableView()
    }
    
    /// This function updates the channels.
    ///
    /// It is updated only if the channels already exist in the list, and if not, it is ignored.
    /// And, after updating the channels, a function to sort the channel list is called.
    /// - Parameters:
    ///   - channels: Channel array to update
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func updateChannels(_ channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
            guard self.channelListQuery?.belongs(to: channel) == true else { continue }
            guard let index = self.channelList.firstIndex(of: channel) else { continue }
            self.channelList.append(self.channelList.remove(at: index))
        }
        self.sortChannelList(needReload: needReload)
    }
    
    /// This function upserts the channels.
    ///
    /// If the channels are already in the list, it is updated, otherwise it is inserted.
    /// And, after upserting the channels, a function to sort the channel list is called.
    /// - Parameters:
    ///   - channels: Channel array to upsert
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func upsertChannels(_ channels: [SBDGroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        let includeEmptyChannel = self.channelListViewModel?.channelListQuery?.includeEmptyChannel ?? false
        for channel in channels {
            guard (channel.lastMessage != nil || includeEmptyChannel) else { continue }
            guard let index = self.channelList.firstIndex(where: { $0.channelUrl == channel.channelUrl }) else {
                self.channelList.append(channel)
                continue
            }
            self.channelList.append(self.channelList.remove(at: index))
        }
        self.sortChannelList(needReload: needReload)
    }
    
    /// This function deletes the channels using the channel urls.
    /// - Parameters:
    ///   - channelUrls: Channel url array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func deleteChannels(channelUrls: [String]?, needReload: Bool) {
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
    
    
    // MARK: - Custom viewController relations
    
    /// This is a function that shows the channelViewController.
    ///
    /// If you want to use a custom channelViewController, override it and implement it.
    /// - Parameters:
    ///   - channelUrl: channel url for use in channelViewController.
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    open override func showChannel(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
        let channelVC = SBUChannelViewController(
            channelUrl: channelUrl,
            messageListParams: messageListParams
        )
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    /// This is a function that shows the channel type selector when a supergroup/broadcast channel can be set.
    ///
    /// * If you want to use a custom `createChannelTypeSelector`, override it and implement it.
    /// - Since: 1.2.0
    open func showCreateChannelTypeSelector() {
        if let typeSelector = self.createChannelTypeSelector as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.show()        // create channel type selector
        }
    }
    
    /// This is a function that shows the channel creation viewController with channel type.
    ///
    /// If you want to use a custom createChannelViewController, override it and implement it.
    /// - Parameter type: Using the Specified Type in CreateChannelViewController (default: `.group`)
    open func showCreateChannel(type: ChannelType = .group) {
        let createChannelVC = SBUCreateChannelViewController(type: type)
        self.navigationController?.pushViewController(createChannelVC, animated: true)
    }
    
    /// Used to register a custom cell as a base cell based on `SBUBaseChannelCell`.
    /// - Parameters:
    ///   - channelCell: Customized channel cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(channelCell: SBUBaseChannelCell, nib: UINib? = nil) {
        self.channelCell = channelCell
        
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: channelCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: channelCell),
                forCellReuseIdentifier: channelCell.sbu_className
            )
        }
    }
    
    /// Used to register a custom cell as a additional cell based on `SBUBaseChannelCell`.
    /// - Parameters:
    ///   - customCell: Customized channel cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(customCell: SBUBaseChannelCell?, nib: UINib? = nil) {
        self.customCell = customCell
        
        guard let customCell = customCell else { return }
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: customCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: customCell),
                forCellReuseIdentifier: customCell.sbu_className
            )
        }
    }
    
    
    // MARK: - Actions
    
    func onClickCreate() {
        if (SBUAvailable.isSupportSuperGroupChannel() || SBUAvailable.isSupportBroadcastChannel())
            && self.createChannelTypeSelector != nil {
            self.showCreateChannelTypeSelector()
        } else {
            self.showCreateChannel(type: .group)
        }
    }
    
    
    // MARK: - Common
    
    private func initChannelList() {
        if SBUAvailable.isSupportSuperGroupChannel() || SBUAvailable.isSupportBroadcastChannel() {
            self.createChannelTypeSelector = self.defaultCreateChannelTypeSelector
            
            if let createChannelTypeSelector = self.createChannelTypeSelector {
                self.navigationController?.view.addSubview(createChannelTypeSelector)
            }
            self.setupAutolayout()
        }
        
        self.createViewModel()
        self.loadNextChannelList(reset: true)
    }
    
    func showNetworkError() {
        self.channelList = []
        self.channelListViewModel?.reset()
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.error)
        }
        
        self.reloadTableView()
    }
    
    public func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    public func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        guard showIndicator else { return }
        
        if loadingState {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }
    
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBDError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    @available(*, deprecated, renamed: "errorHandler") // 2.1.12
    open func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
}


// MARK: - UITableView relations
extension SBUChannelListViewController: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showChannel(channelUrl: self.channelList[indexPath.row].channelUrl)
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.channelList.count else {
            self.errorHandler("The index is out of range.", -1)
            return UITableViewCell()
        }
        
        let channel = self.channelList[indexPath.row]
        
        var cell: SBUBaseChannelCell? = nil
        
        if let customCell = self.customCell,
            let customType = channel.customType,
            !customType.isEmpty {
            
            cell = tableView.dequeueReusableCell(
                withIdentifier: customCell.sbu_className
                ) as? SBUBaseChannelCell
        } else {
            cell = tableView.dequeueReusableCell(
                withIdentifier: self.channelCell?.sbu_className
                    ?? SBUBaseChannelCell.sbu_className
                ) as? SBUBaseChannelCell
        }
        
        cell?.selectionStyle = .none
        cell?.configure(channel: channel)
        cell?.setupStyles()
        return cell ?? UITableViewCell()
        
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        if self.channelList.count > 0,
            indexPath.row == (self.channelList.count - Int(SBUChannelListViewModel.channelLoadLimit) / 2) {
            self.loadNextChannelList(reset: false)
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = !self.channelList.isEmpty
        
        return self.channelList.count
    }
    
    open func tableView(_ tableView: UITableView,
                        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
            
            let index = indexPath.row
            let channel = self.channelList[index]
            let size = tableView.visibleCells[0].frame.height
            let iconSize: CGFloat = 40.0
            
            let leaveAction = UIContextualAction(
                style: .normal,
                title: ""
            ) { action, view, actionHandler in
                self.leaveChannel(channel) { success in
                    actionHandler(success)
                }
            }
            
            let leaveTypeView = UIImageView(
                frame: CGRect(
                    x: (size-iconSize)/2,
                    y: (size-iconSize)/2,
                    width: iconSize,
                    height: iconSize
            ))
            leaveTypeView.layer.cornerRadius = iconSize/2
            leaveTypeView.backgroundColor = theme.leaveBackgroundColor
            leaveTypeView.image = SBUIconSetType.iconLeave.image(with: theme.leaveTintColor,
                                                             to: SBUIconSetType.Metric.defaultIconSize)
            leaveTypeView.contentMode = .center
            
            leaveAction.image = leaveTypeView.asImage()
            leaveAction.backgroundColor = theme.alertBackgroundColor
            
            let pushOption = channel.myPushTriggerOption
            let alarmAction = UIContextualAction(
                style: .normal,
                title: ""
            ) { action, view, actionHandler in
                self.changePushTriggerOption(
                    option: (pushOption == .off ? .all : .off),
                    channel: channel
                ) { success in
                    guard success else { return }
                    
                    actionHandler(true)
                    
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                }
            }
            
            let alarmTypeView = UIImageView(
                frame: CGRect(
                    x: (size-iconSize)/2,
                    y: (size-iconSize)/2,
                    width: iconSize,
                    height: iconSize
            ))
            let alarmIcon: UIImage
            
            if pushOption == .off {
                alarmTypeView.backgroundColor = theme.notificationOnBackgroundColor
                alarmIcon = SBUIconSetType.iconNotificationFilled.image(
                    with: theme.notificationOnTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
            } else {
                alarmTypeView.backgroundColor = theme.notificationOffBackgroundColor
                alarmIcon = SBUIconSetType.iconNotificationOffFilled.image(
                    with: theme.notificationOffTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
            }
            alarmTypeView.image = alarmIcon
            alarmTypeView.contentMode = .center
            alarmTypeView.layer.cornerRadius = iconSize/2
            
            alarmAction.image = alarmTypeView.asImage()
            alarmAction.backgroundColor = theme.alertBackgroundColor
            
            return UISwipeActionsConfiguration(actions: [leaveAction, alarmAction])
    }
}


// MARK: - SBUEmptyViewDelegate
extension SBUChannelListViewController: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noChannels)
        }
        
        SBULog.info("[Request] Retry load channel list")
        SBUMain.connectIfNeeded { user, error in
            if let error = error {
                SBULog.error("[Failed] Retry request: \(String(error.localizedDescription))")
                self.errorHandler(error)
                return
            }

            if self.channelListViewModel == nil {
                self.initChannelList()
            } else {
                self.loadNextChannelList(reset: true)
            }
        }
    }
}


// MARK: - SBDChannelDelegate : Please do not use it.
extension SBUChannelListViewController: SBDChannelDelegate {
    open func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {}
    open func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {}
    open func channelWasChanged(_ sender: SBDBaseChannel) {}
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {}
    open func channelWasFrozen(_ sender: SBDBaseChannel) {}
    open func channelWasUnfrozen(_ sender: SBDBaseChannel) {}
    open func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {}
}


// MARK: - SBDConnectionDelegate
extension SBUChannelListViewController: SBDConnectionDelegate {
    open func didSucceedReconnection() {
        SBULog.info("Did succeed reconnection")
        SBUMain.updateUserInfo { error in
            if let error = error {
                SBULog.error("[Failed] Update user info: \(error.localizedDescription)")
            }
        }
        if self.channelListViewModel == nil {
            self.initChannelList()
        }
    }
}


// MARK: - SBUCreateChannelTypeSelectorDelegate
extension SBUChannelListViewController: SBUCreateChannelTypeSelectorDelegate {
    open func didSelectCloseSelector() {
        if let typeSelector = self.createChannelTypeSelector
            as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.dismiss()
        }
    }
    
    open func didSelectCreateGroupChannel() {
        if let typeSelector = self.createChannelTypeSelector
            as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.dismiss()
        }
        self.showCreateChannel(type: .group)
    }
    
    open func didSelectCreateSuperGroupChannel() {
        if let typeSelector = self.createChannelTypeSelector
            as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.dismiss()
        }
        self.showCreateChannel(type: .supergroup)
    }
    
    open func didSelectCreateBroadcastChannel() {
        if let typeSelector = self.createChannelTypeSelector
            as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.dismiss()
        }
        self.showCreateChannel(type: .broadcast)
    }
}

// MARK: - LoadingIndicatorDelegate
extension SBUChannelListViewController: LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        return false
    }
    
    open func shouldDismissLoadingIndicator() {}
}








// MARK: - Deprecated
extension SBUChannelListViewController {
    @available(*, deprecated, message: "Since it automatically detects channel changes internally, it is no longer necessary to use this function.") // 2.2.0
    public func loadChannelChangeLogs(hasMore: Bool, token: String?) { }
}
