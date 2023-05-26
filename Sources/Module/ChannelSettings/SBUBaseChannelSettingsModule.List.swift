//
//  SBUBaseChannelSettingsModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUBaseChannelSettingsModuleListDelegate: SBUCommonDelegate { }

public protocol SBUBaseChannelSettingsModuleListDataSource: AnyObject {
    /// Ask the data source to return the channel.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelSettingsModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `BaseChannel` object.
    func baseChannelSettingsModule(_ listComponent: SBUBaseChannelSettingsModule.List, channelForTableView tableView: UITableView) -> BaseChannel?
    
    /// Ask the data source to return the operator status
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelSettingsModule.List` object.
    /// - Returns: `true` when it's an operator
    func baseChannelSettingsModuleIsOperator(_ listComponent: SBUBaseChannelSettingsModule.List) -> Bool
}

extension SBUBaseChannelSettingsModule {
    
    /// A module component that represent the list of `SBUBaseChannelSettingsModule`.
    @objcMembers open class List: UIView {
        
        // MARK: - UI properties (Public)
        
        /// The table view that shows the items of the channel settings.
        public var tableView = UITableView()
        
        /// A view that shows channel information on the settings.
        public var channelInfoView: UIView? = SBUChannelSettingsChannelInfoView()
        
        /// The object that is used as the theme of the list component. The theme must adopt the `SBUChannelSettingsTheme` class.
        public var theme: SBUChannelSettingsTheme?
        
        // MARK: - Logic properties (Public)
        public weak var baseDelegate: SBUBaseChannelSettingsModuleListDelegate?
        public weak var baseDataSource: SBUBaseChannelSettingsModuleListDataSource?

        public var baseChannel: BaseChannel? {
            self.baseDataSource?.baseChannelSettingsModule(self, channelForTableView: self.tableView)
        }
        public var isOperator: Bool {
            self.baseDataSource?.baseChannelSettingsModuleIsOperator(self) ?? false
        }
        
        public var items: [SBUChannelSettingItem] = []
        
        // MARK: - LifeCycle
        open func setupViews() {
            // tableview
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.bounces = false
            self.tableView.alwaysBounceVertical = false
            self.tableView.separatorStyle = .none
            self.tableView.tableHeaderView = self.channelInfoView
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.sectionHeaderHeight = 0
            self.addSubview(self.tableView)
        }
        
        /// Sets up items for tableView cell configuration.
        open func setupItems() { }
        
        // MARK: - Style
        open func setupLayouts() {
            if let channelInfoView = self.channelInfoView as? SBUChannelSettingsChannelInfoView {
                channelInfoView
                    .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0)
                    .sbu_constraint(equalTo: self.tableView, centerX: 0)
            }

            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUChannelSettingsTheme` object
        open func setupStyles(theme: SBUChannelSettingsTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
            
            if let channelInfoView = self.channelInfoView as? SBUChannelSettingsChannelInfoView {
                channelInfoView.setupStyles()
            }
        }
        
        // MARK: - TableView: Cell
        
        /// Configures cell for a particular row.
        /// - Parameters:
        ///   - cell: `UITableViewCell` object
        ///   - indexPath: An index path representing the `channelCell`
        open func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {}
        
        // MARK: - ChannelInfo
        
        /// This function updates channeInfoView's cover image
        /// - Parameter coverImage: `UIImage` object
        open func updateChannelInfoView(coverImage: UIImage) {
            if let channelInfoView = self.channelInfoView as? SBUChannelSettingsChannelInfoView {
                channelInfoView.coverImage.setImage(withImage: coverImage)
            }
        }
        
        /// This function ends editing channelInfoView
        open func endEditingChannelInfoView() {
            if let channelInfoView = self.channelInfoView as? SBUChannelSettingsChannelInfoView {
                channelInfoView.endEditing(true)
            }
        }
        
        /// This function reloads channelInfoView.
        open func reloadChannelInfoView() {
            if let channelInfoView = self.channelInfoView as? SBUChannelSettingsChannelInfoView {
                channelInfoView.configure(channel: self.baseChannel)
            }
        }
        
        // MARK: - Common
        
        /// This function reloads the table view.
        public func reloadTableView() {
            self.setupItems()
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableView relations
extension SBUBaseChannelSettingsModule.List: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
