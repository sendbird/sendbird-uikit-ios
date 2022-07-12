//
//  SBUGroupChannelListModuleList.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/01.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


/// Event methods for the views updates and performing actions from the list component in the group channel list.
public protocol SBUGroupChannelListModuleListDelegate: SBUCommonDelegate {
    /// Called when the channel cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelListModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelListModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, didDetectPreloadingPosition indexPath: IndexPath)
    
    /// Called when selected leave button in the swipped cell.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelListModule.List` object.
    ///    - channel: The channel that was selected.
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, didSelectLeave channel: GroupChannel)
    
    /// Called when selected alarm button in the swipped cell.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelListModule.List` object.
    ///    - channel: The channel that was selected.
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, didChangePushTriggerOption option: GroupChannelPushTriggerOption, channel: GroupChannel)
    
    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUGroupChannelListModule.List` object.
    func channelListModuleDidSelectRetry(_ listComponent: SBUGroupChannelListModule.List)
}

/// Methods to get data source for the list component in the group channel list.
public protocol SBUGroupChannelListModuleListDataSource: AnyObject {
    /// Ask the data source to return the channel list.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelListModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `GroupChannel` object.
    func channelListModule(_ listComponent: SBUGroupChannelListModule.List, channelsInTableView tableView: UITableView) -> [GroupChannel]?
}


extension SBUGroupChannelListModule {
    /// A module component that represent the list of `SBUGroupChannelListModule`.
    @objc(SBUGroupChannelListModuleList)
    @objcMembers open class List: UIView {
        
        // MARK: - UI properties (Public)
        
        /// The table view to show the list of group channels
        public var tableView = UITableView()
        /// A view that shows when there is no group channel.
        public var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        /// The channel cell for `SBUBaseChannelCell` object. Use `register(channelCell:nib:)` to update.
        public var channelCell: SBUBaseChannelCell?
        /// The custom channel cell for `SBUBaseChannelCell` object. Use `register(customCell:nib:)` to update.
        public var customCell: SBUBaseChannelCell?
        
        /// The object that is used as the theme of the list component. The theme must adopt the `SBUChannelListTheme` class.
        public var theme: SBUChannelListTheme?
        
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUBaseChannelModuleListDelegate`.
        public weak var delegate: SBUGroupChannelListModuleListDelegate?
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUBaseChannelModuleListDataSource`.
        public weak var dataSource: SBUGroupChannelListModuleListDataSource?
        
        /// The current channel list object from `channelListModule(_:channelsInTableView:)` data source method.
        public var channelList: [GroupChannel]? {
            self.dataSource?.channelListModule(self, channelsInTableView: self.tableView)
        }
        

        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUGroupChannelListModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUGroupChannelListModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelListModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUGroupChannelListModuleListDataSource`
        ///   - theme: `SBUChannelListTheme` object
        open func configure(delegate: SBUGroupChannelListModuleListDelegate,
                            dataSource: SBUGroupChannelListModuleListDataSource,
                            theme: SBUChannelListTheme) {
            
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            // empty view
            if self.emptyView == nil {
                self.emptyView = self.defaultEmptyView
            }
            
            // table view
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.tableView.bounces = false
            self.tableView.alwaysBounceVertical = false
            self.tableView.separatorStyle = .none
            self.tableView.backgroundView = self.emptyView
            
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.addSubview(self.tableView)
            
            // register cell
            if self.channelCell == nil {
                self.register(channelCell: SBUGroupChannelCell())
            }
        }
        
        /// Sets layouts of the views in the list component.
        open func setupLayouts() {
            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        /// Sets up style with theme. If set theme parameter is nil value, using the stored theme.
        /// - Parameter theme: `SBUChannelListTheme` object
        open func setupStyles(theme: SBUChannelListTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
        }
        
        
        // MARK: - TableView: Cell
        
        /// Registers a custom cell as a channel cell based on `SBUBaseChannelCell`.
        /// - Parameters:
        ///   - channelCell: Customized channel cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom channel cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(channelCell: MyChannelCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
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
        
        /// Registers a additional cell as a custom cell based on `SBUBaseChannelCell`.
        /// - Parameters:
        ///   - customCell: Additional channel cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register additional channel cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(customCell: MyChannelCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
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
        
        /// Configures cell for a particular row.
        /// - Parameters:
        ///   - channelCell: `SBUBaseChannelCell` object
        ///   - indexPath: An index path representing the `channelCell`
        open func configureCell(_ channelCell: SBUBaseChannelCell?, indexPath: IndexPath) {
            guard let channel = self.channelList?[indexPath.row] else { return }
            
            channelCell?.configure(channel: channel)
            channelCell?.setupStyles()
        }
        
        /// Creates leave contextual action for a particular swipped cell.
        /// - Parameter indexPath: An index path representing the `channelCell`
        /// - Returns: `UIContextualAction` object.
        public func leaveContextualAction(with indexPath: IndexPath) -> UIContextualAction? {
            guard let channel = self.channelList?[indexPath.row] else { return nil }
            
            let size = tableView.visibleCells[0].frame.height
            let itemSize: CGFloat = 40.0
            
            let leaveAction = UIContextualAction(
                style: .normal,
                title: ""
            ) { [weak self] action, view, actionHandler in
                guard let self = self else { return }
                self.delegate?.channelListModule(self, didSelectLeave: channel)
                actionHandler(true)
            }
            
            let leaveTypeView = UIImageView(
                frame: CGRect(
                    x: (size-itemSize)/2,
                    y: (size-itemSize)/2,
                    width: itemSize,
                    height: itemSize
                ))
            leaveTypeView.layer.cornerRadius = itemSize/2
            leaveTypeView.backgroundColor = self.theme?.leaveBackgroundColor
            leaveTypeView.image = SBUIconSetType.iconLeave.image(
                with: self.theme?.leaveTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
            leaveTypeView.contentMode = .center
            
            leaveAction.image = leaveTypeView.asImage()
            leaveAction.backgroundColor = self.theme?.alertBackgroundColor
            
            return leaveAction
        }
        
        /// Creates alarm contextual action for a particular swipped cell.
        /// - Parameter indexPath: An index path representing the `channelCell`
        /// - Returns: `UIContextualAction` object.
        public func alarmContextualAction(with indexPath: IndexPath) -> UIContextualAction? {
            guard let channel = self.channelList?[indexPath.row] else { return nil }
            
            let size = tableView.visibleCells[0].frame.height
            let itemSize: CGFloat = 40.0
            
            let pushOption = channel.myPushTriggerOption
            let alarmAction = UIContextualAction(
                style: .normal,
                title: ""
            ) { [weak self] action, view, actionHandler in
                guard let self = self else { return }
                self.delegate?.channelListModule(
                    self,
                    didChangePushTriggerOption: (pushOption == .off ? .all : .off),
                    channel: channel
                )
                actionHandler(true)
            }
            
            let alarmTypeView = UIImageView(
                frame: CGRect(
                    x: (size-itemSize)/2,
                    y: (size-itemSize)/2,
                    width: itemSize,
                    height: itemSize
                ))
            let alarmIcon: UIImage
            
            if pushOption == .off {
                alarmTypeView.backgroundColor = self.theme?.notificationOnBackgroundColor
                alarmIcon = SBUIconSetType.iconNotificationFilled.image(
                    with: self.theme?.notificationOnTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
            } else {
                alarmTypeView.backgroundColor = self.theme?.notificationOffBackgroundColor
                alarmIcon = SBUIconSetType.iconNotificationOffFilled.image(
                    with: self.theme?.notificationOffTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
            }
            alarmTypeView.image = alarmIcon
            alarmTypeView.contentMode = .center
            alarmTypeView.layer.cornerRadius = itemSize/2
            
            alarmAction.image = alarmTypeView.asImage()
            alarmAction.backgroundColor = self.theme?.alertBackgroundColor
            
            return alarmAction
        }
        
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        // MARK: - EmptyView
        public func updateEmptyView(type: EmptyViewType) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(type)
            }
        }
    }
}


// MARK: - SBUEmptyViewDelegate
extension SBUGroupChannelListModule.List: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noChannels)
        }
        
        SBULog.info("[Request] Retry load channel list")
        self.delegate?.channelListModuleDidSelectRetry(self)
    }
}


// MARK: - UITableView relations
extension SBUGroupChannelListModule.List: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.channelListModule(self, didSelectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.channelList?.count ?? 0 else {
            let error = SBError(domain: "The index is out of range.", code: -1, userInfo: nil)
            self.delegate?.didReceiveError(error, isBlocker: false)
            return UITableViewCell()
        }
        
        var cell: SBUBaseChannelCell? = nil
        if let channelCell = self.channelCell {
            cell = tableView.dequeueReusableCell(
                withIdentifier: channelCell.sbu_className
            ) as? SBUBaseChannelCell
        } else if let customCell = self.customCell {
            cell = tableView.dequeueReusableCell(
                withIdentifier: customCell.sbu_className
            ) as? SBUBaseChannelCell
        } else {
            cell = SBUBaseChannelCell()
        }
        
        cell?.selectionStyle = .none
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        let rowForPreloading = Int(SBUGroupChannelListViewModel.channelLoadLimit)/2
        let channelListCount = self.channelList?.count ?? 0
        if channelListCount > 0,
           indexPath.row == (channelListCount - rowForPreloading) {
            self.delegate?.channelListModule(self, didDetectPreloadingPosition: indexPath)
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = !(self.channelList?.isEmpty ?? true)
        
        return self.channelList?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView,
                        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        var actions: [UIContextualAction] = []
        if let leaveAction = leaveContextualAction(with: indexPath) {
            actions.append(leaveAction)
        }
        if let alarmAction = alarmContextualAction(with: indexPath) {
            actions.append(alarmAction)
        }
        
        return UISwipeActionsConfiguration(actions: actions)
    }
}
