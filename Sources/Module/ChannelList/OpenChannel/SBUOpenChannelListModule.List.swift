//
//  SBUOpenChannelListModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the list component in the open channel list.
public protocol SBUOpenChannelListModuleListDelegate: SBUBaseChannelListModuleListDelegate {}

/// Methods to get data source for the list component in the open channel list.
public protocol SBUOpenChannelListModuleListDataSource: SBUBaseChannelListModuleListDataSource {}

extension SBUOpenChannelListModule {
    /// A module component that represent the list of `SBUOpenChannelListModule`.
    @objc(SBUOpenChannelListModuleList)
    @objcMembers open class List: SBUBaseChannelListModule.List {
        
        // MARK: - UI properties (Public)
        /// The object that is used as the theme of the list component. The theme must adopt the `SBUOpenChannelListTheme` class.
        public var theme: SBUOpenChannelListTheme?
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUOpenChannelListModuleListDelegate`.
        public weak var delegate: SBUOpenChannelListModuleListDelegate? {
            get { self.baseDelegate as? SBUOpenChannelListModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUOpenChannelListModuleListDataSource`.
        public weak var dataSource: SBUOpenChannelListModuleListDataSource? {
            get { self.baseDataSource as? SBUOpenChannelListModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        /// The current channel list object from `baseChannelListModule(_:channelsInTableView:)` data source method.
        public var channelList: [OpenChannel]? {
            self.baseChannelList as? [OpenChannel]
        }

        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUOpenChannelListModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUOpenChannelListModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUOpenChannelListModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUOpenChannelListModuleListDataSource`
        ///   - theme: `SBUOpenChannelListTheme` object
        open func configure(delegate: SBUOpenChannelListModuleListDelegate,
                            dataSource: SBUOpenChannelListModuleListDataSource,
                            theme: SBUOpenChannelListTheme) {
            
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.isPullToRefreshEnabled = true
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the list component when it needs.
        open override func setupViews() {
            super.setupViews()

            // register cell
            if self.channelCell == nil {
                self.register(channelCell: SBUOpenChannelCell())
            }
        }
        
        /// Sets up style with theme. If set theme parameter is nil value, using the stored theme.
        /// - Parameter theme: `SBUOpenChannelListTheme` object
        open func setupStyles(theme: SBUOpenChannelListTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
            
            (self.emptyView as? SBUEmptyView)?.setupStyles()
            
            if isPullToRefreshEnabled {
                self.tableView.refreshControl?.backgroundColor = self.theme?.refreshBackgroundColor
                self.tableView.refreshControl?.tintColor = self.theme?.refreshIndicatorColor
            }
        }
    }
}

// MARK: - UITableView relations
extension SBUOpenChannelListModule.List {
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return super.numberOfSections(in: tableView)
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.baseChannelListModule(self, didSelectRowAt: indexPath)
    }
    
    open override func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < self.channelList?.count ?? 0 else {
            let error = SBError(domain: "The index is out of range.", code: -1, userInfo: nil)
            self.delegate?.didReceiveError(error, isBlocker: false)
            return UITableViewCell()
        }
        
        var cell: SBUBaseChannelCell?
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
    
    open override func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        let rowForPreloading = Int(SBUOpenChannelListViewModel.channelLoadLimit)/2
        let channelListCount = self.channelList?.count ?? 0
        if channelListCount > 0,
           indexPath.row == (channelListCount - rowForPreloading) {
            self.delegate?.baseChannelListModule(self, didDetectPreloadingPosition: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView?.isHidden = !(self.channelList?.isEmpty ?? true)
        
        return self.channelList?.count ?? 0
    }
}
