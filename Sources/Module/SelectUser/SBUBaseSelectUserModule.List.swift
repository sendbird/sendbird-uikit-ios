//
//  SBUBaseSelectUserModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the list component.
public protocol SBUBaseSelectUserModuleListDelegate: SBUCommonDelegate { }

/// Methods to get data source for the list component.
public protocol SBUBaseSelectUserModuleListDataSource: AnyObject {
    /// Ask the data source to return the user list.
    /// - Parameters:
    ///    - listComponent: `SBUBaseSelectUserModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `SBUUser` array object.
    func baseSelectUserModule(_ listComponent: SBUBaseSelectUserModule.List, usersInTableView tableView: UITableView) -> [SBUUser]?
    
    /// Ask the data source to return the selected user list.
    /// - Parameters:
    ///    - listComponent: `SBUBaseSelectUserModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `SBUUser` array object.
    func baseSelectUserModule(_ listComponent: SBUBaseSelectUserModule.List, selectedUsersInTableView tableView: UITableView) -> Set<SBUUser>?
}

extension SBUBaseSelectUserModule {
    
    /// A module component that represent the list of `SBUBaseSelectUserModule`.
    @objc(SBUBaseChannelSettingsModuleList)
    @objcMembers open class List: UIView {
        
        // MARK: - UI properties (Public)
        
        /// The table view to show user list in the channel.
        public var tableView = UITableView()
        
        /// A view that shows when there is no message in the channel.
        public var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        
        /// The user cell for `UITableViewCell` object. Use `register(userCell:nib:)` to update.
        public var userCell: UITableViewCell?
        
        /// The object that is used as the theme of the list component. The theme must adopt the `SBUUserListTheme` class.
        public var theme: SBUUserListTheme?
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the base delegate of the list component. The base delegate must adopt the `SBUBaseSelectUserModuleListDelegate`.
        public weak var baseDelegate: SBUBaseSelectUserModuleListDelegate?
        
        /// The object that acts as the base data source of the list component. The base data source must adopt the `SBUBaseSelectUserModuleListDataSource`.
        public weak var baseDataSource: SBUBaseSelectUserModuleListDataSource?
        
        /// The list of all users shown
        public var userList: [SBUUser]? {
            self.baseDataSource?.baseSelectUserModule(self, usersInTableView: self.tableView)
        }
        
        /// The list of the selected users
        public var selectedUserList: Set<SBUUser>? {
            self.baseDataSource?.baseSelectUserModule(self, selectedUsersInTableView: self.tableView)
        }
        
        // MARK: - LifeCycle
        deinit {
            SBULog.info("")
            self.baseDelegate = nil
            self.baseDataSource = nil
        }
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            // empty view
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
            self.tableView.sectionHeaderHeight = 0
            self.addSubview(self.tableView)
            
            // register cell
            if self.userCell == nil {
                self.register(userCell: SBUUserCell())
            }
        }
        
        /// Sets layouts of the views in the list component.
        open func setupLayouts() {
            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUUserListTheme` object
        open func setupStyles(theme: SBUUserListTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            self.tableView.backgroundColor = self.theme?.backgroundColor
            
            (self.emptyView as? SBUEmptyView)?.setupStyles()
        }
        
        // MARK: - Common
        
        /// Checks user is selected status.
        /// - Parameter user: `SBUUser` object
        /// - Returns: `true`: selected
        public func isSelectedUser(_ user: SBUUser) -> Bool {
            return self.selectedUserList?.contains(where: { $0.userId == user.userId }) ?? false
//            return self.selectedUserList?.contains(user) ?? false
        }
        
        // MARK: - TableView: Cell
        
        /// Registers a custom cell as a channel cell based on `UITableViewCell`.
        /// - Parameters:
        ///   - userCell: Customized user cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom user cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(userCell: MyUserCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
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
        
        /// Configures cell for a particular row.
        /// - Parameters:
        ///   - cell: `UITableViewCell` object
        ///   - indexPath: An index path representing the `userCell`
        open func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {}
        
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        // MARK: - EmptyView
        
        /// This function updates emptyView.
        /// - Parameter type: `EmptyViewType`
        public func updateEmptyView(type: EmptyViewType) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(type)
            }
        }
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBUBaseSelectUserModule.List: SBUEmptyViewDelegate {
    @objc open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noMembers)
        }
        
        SBULog.info("[Request] Retry load channel list")
    }
}

// MARK: - UITableView relations
extension SBUBaseSelectUserModule.List: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList?.count ?? 0
    }

    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell?
        if let userCell = self.userCell {
            cell = tableView.dequeueReusableCell(withIdentifier: userCell.sbu_className)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className)
        }
        
        if let theme = (self.userCell as? SBUUserCell)?.theme {
            (cell as? SBUUserCell)?.theme = theme
        }
        
        cell?.selectionStyle = .none

        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
}
