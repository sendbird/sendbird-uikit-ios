//
//  SBUBaseChannelListModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class SBUBaseChannelListModule_List: NSObject {

}

/// Event methods for the views updates and performing actions from the list component in the channel list.
public protocol SBUBaseChannelListModuleListDelegate: SBUCommonDelegate {
    /// Called when the channel cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelListModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func baseChannelListModule(_ listComponent: SBUBaseChannelListModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelListModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func baseChannelListModule(_ listComponent: SBUBaseChannelListModule.List, didDetectPreloadingPosition indexPath: IndexPath)
    
    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUOpenChannelListModule.List` object.
    func baseChannelListModuleDidSelectRetry(_ listComponent: SBUBaseChannelListModule.List)
    
    /// Called when the refresh button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUOpenChannelListModule.List` object.
    func baseChannelListModuleDidSelectRefresh(_ listComponent: SBUBaseChannelListModule.List)
}

/// Methods to get data source for the list component in the channel list.
public protocol SBUBaseChannelListModuleListDataSource: AnyObject {
    /// Ask the data source to return the channel list.
    /// - Parameters:
    ///    - listComponent: `SBUOpenChannelListModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `BaseChannel` object.
    func baseChannelListModule(_ listComponent: SBUBaseChannelListModule.List, channelsInTableView tableView: UITableView) -> [BaseChannel]?
}

extension SBUBaseChannelListModule {
    /// A module component that represent the list of `SBUBaseChannelListModule`.
    @objc(SBUBaseChannelListModuleList)
    @objcMembers open class List: UIView {
        
        // MARK: - UI properties (Public)
        
        /// The table view to show the list of channels
        public var tableView = UITableView()
        /// A view that shows when there is no channel.
        public var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        /// The channel cell for `SBUBaseChannelCell` object. Use `register(channelCell:nib:)` to update.
        public var channelCell: SBUBaseChannelCell?
        /// The custom channel cell for `SBUBaseChannelCell` object. Use `register(customCell:nib:)` to update.
        public var customCell: SBUBaseChannelCell?
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUBaseChannelListModuleListDelegate`.
        public weak var baseDelegate: SBUBaseChannelListModuleListDelegate?
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUBaseChannelListModuleListDataSource`.
        public weak var baseDataSource: SBUBaseChannelListModuleListDataSource?
        
        /// The current channel list object from `channelListModule(_:channelsInTableView:)` data source method.
        public var baseChannelList: [BaseChannel]? {
            self.baseDataSource?.baseChannelListModule(self, channelsInTableView: self.tableView)
        }
        
        /// If this value is enabled, pull to refresh feature is enabled.
        /// - Since: 3.2.0
        public var isPullToRefreshEnabled: Bool = false

        // MARK: - LifeCycle
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            // empty view
            if self.emptyView == nil {
                self.emptyView = self.defaultEmptyView
            }
            
            // table view
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.tableView.alwaysBounceVertical = false
            self.tableView.separatorStyle = .none
            self.tableView.backgroundView = self.emptyView
            
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.sectionHeaderHeight = 0
            
            self.addSubview(self.tableView)
            
            self.setupPullToRefresh()
        }
        
        /// Sets layouts of the views in the list component.
        open func setupLayouts() {
            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        open func setupPullToRefresh() {
            if self.isPullToRefreshEnabled {
                self.tableView.refreshControl = UIRefreshControl()
                self.tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
            }
        }
        
        // MARK: - TableView: Cell
        
        /// Configures cell for a particular row.
        /// - Parameters:
        ///   - channelCell: `SBUBaseChannelCell` object
        ///   - indexPath: An index path representing the `channelCell`
        open func configureCell(_ channelCell: SBUBaseChannelCell?, indexPath: IndexPath) {
            guard let channel = self.baseChannelList?[indexPath.row] else { return }
            
            channelCell?.configure(channel: channel)
            channelCell?.setupStyles()
        }
        
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
        
        // MARK: - TableView
        
        /// Pulls to refresh.
        /// - Parameter sender: Sender
        ///
        /// - Since: 3.2.0
        open func pullToRefresh(_ sender: Any) {
            self.baseDelegate?.baseChannelListModuleDidSelectRefresh(self)
            
            self.tableView.refreshControl?.endRefreshing()
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
extension SBUBaseChannelListModule.List: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noChannels)
        }
        
        SBULog.info("[Request] Retry load channel list")
        self.baseDelegate?.baseChannelListModuleDidSelectRetry(self)
    }
}

// MARK: - UITableView relations
extension SBUBaseChannelListModule.List: UITableViewDataSource, UITableViewDelegate {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView,
                        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        return nil
    }
}
