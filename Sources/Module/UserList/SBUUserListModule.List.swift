//
//  SBUUserListModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUUserListModuleListDelegate: SBUCommonDelegate {
    /// Called when the user cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUUserListModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func userListModule(_ listComponent: SBUUserListModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUUserListModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func userListModule(_ listComponent: SBUUserListModule.List, didDetectPreloadingPosition indexPath: IndexPath)

    /// Called when the more menu was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUUserListModule.List` object.
    ///    - user: The `SBUUser` of more menu that was tapped.
    func userListModule(_ listComponent: SBUUserListModule.List, didTapMoreMenuFor user: SBUUser)
    
    /// Called when the user profile was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUUserListModule.List` object.
    ///    - user: The `SBUUser` of user profile that was tapped.
    func userListModule(_ listComponent: SBUUserListModule.List, didTapUserProfileFor user: SBUUser)
    
    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUUserListModule.List` object.
    func userListModuleDidSelectRetry(_ listComponent: SBUUserListModule.List)
}

public protocol SBUUserListModuleListDataSource: AnyObject {
    /// Ask the data source to return the `BaseChannel` object.
    /// - Parameters:
    ///    - listComponent: `SBUUserListModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `BaseChannel` object.
    func userListModule(_ listComponent: SBUUserListModule.List, channelForTableView tableView: UITableView) -> BaseChannel?
    
    /// Ask the data source to return the user list.
    /// - Parameters:
    ///    - listComponent: `SBUUserListModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `SBUUser` object.
    func userListModule(_ listComponent: SBUUserListModule.List, usersInTableView tableView: UITableView) -> [SBUUser]
}

extension SBUUserListModule {
    
    /// A module component that represent the list of `SBUUserListModule`.
    @objc(SBUUserListModuleList)
    @objcMembers open class List: UIView {
        
        // MARK: - UI properties (Public)
        /// The table view that shows the list of the users.
        public var tableView = UITableView()
        
        /// A view that displays when the table view is empty.
        public var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        
        /// The user cell for `UITableViewCell` object. Use `register(userCell:nib:)` to update.
        public var userCell: UITableViewCell?
        
        public var theme: SBUUserListTheme?
        public var componentTheme: SBUComponentTheme?
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUUserListModuleListDelegate?
        public weak var dataSource: SBUUserListModuleListDataSource?

        public var channel: BaseChannel? {
            self.dataSource?.userListModule(self, channelForTableView: self.tableView)
        }
        public var userList: [SBUUser] {
            self.dataSource?.userListModule(self, usersInTableView: self.tableView) ?? []
        }
        public var userListType: ChannelUserListType = .none
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUUserListModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUUserListModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUUserListModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUUserListModuleListDataSource`
        ///   - userListType: `ChannelUserListType` Type
        ///   - theme: `SBUUserListTheme` object
        ///   - componentTheme: `SBUComponentTheme` object
        open func configure(delegate: SBUUserListModuleListDelegate,
                            dataSource: SBUUserListModuleListDataSource,
                            userListType: ChannelUserListType,
                            theme: SBUUserListTheme,
                            componentTheme: SBUComponentTheme) {
            self.delegate = delegate
            self.dataSource = dataSource

            self.userListType = userListType
            
            self.theme = theme
            self.componentTheme = componentTheme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles(theme: theme, componentTheme: componentTheme)
        }
        
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
        
        open func setupLayouts() {
            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameters:
        ///   - theme: `SBUUserListTheme` object
        ///   - componentTheme: `SBUComponentTheme` object
        open func setupStyles(theme: SBUUserListTheme? = nil,
                              componentTheme: SBUComponentTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            if let componentTheme = componentTheme {
                self.componentTheme = componentTheme
            }
            
            self.tableView.backgroundColor = self.theme?.backgroundColor
            
            (self.emptyView as? SBUEmptyView)?.setupStyles()
        }
        
        // MARK: - TableView
        
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            if self.userListType == .muted ||
                self.userListType == .banned {
                
                if !self.userList.isEmpty {
                    self.updateEmptyView(type: .none)
                } else {
                    self.updateEmptyView(
                        type: self.userListType == .muted
                        ? (self.channel is GroupChannel) ? .noMutedMembers : .noMutedParticipants
                        : .noBannedUsers
                    )
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }

        // MARK: - TableView: Cell
        
        /// Registers a custom cell as a user cell based on `UITableViewCell`.
        /// - Parameters:
        ///   - channelCell: Customized user cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom user cell, please use this function before calling `configure(delegate:dataSource:userListType:theme:componentTheme:)`
        /// ```swift
        /// listComponent.register(userCell: MyUserCell)
        /// listComponent.configure(delegate: self, dataSource: self, userListType: .type, theme: theme, componentTheme: componentTheme)
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
        ///   - indexPath: An index path representing the `cell`
        open func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            var userListType: UserListType = .none
            
            switch self.userListType {
            case .members:
                userListType = .members
            case .operators:
                userListType = .operators
            case .muted:
                userListType = .muted
            case .banned:
                userListType = .banned
            case .participants:
                userListType = .participants
            default:
                break
            }
            
            let user = self.userList[indexPath.row]
            
            var operatorMode = false
            if let channel = self.channel as? GroupChannel {
                operatorMode = channel.myRole == .operator
            } else if let channel = self.channel as? OpenChannel {
                let currentUserId = SBUGlobals.currentUser?.userId ?? ""
                operatorMode = channel.isOperator(userId: currentUserId)
            }
            
            if let defaultCell = cell as? SBUUserCell {
                defaultCell.configure(
                    type: userListType,
                    user: user,
                    operatorMode: operatorMode
                )
                
                defaultCell.moreMenuHandler = { [weak self] in
                    guard let self = self else { return }
                    self.setMoreMenuTapAction(user)
                }
                
                defaultCell.userProfileTapHandler = { [weak self] in
                    guard let self = self else { return }
                    self.setUserProfileTapAction(user)
                }
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
        
        // MARK: - Actions
        
        /// Sets up the cell's more menu button action.
        /// - IMPORTANT: Only for the group channel
        /// - Parameter user: `SBUUser` obejct
        open func setMoreMenuTapAction(_ user: SBUUser) {
            self.delegate?.userListModule(self, didTapMoreMenuFor: user)
        }
        
        /// Sets up the user profile tap action.
        /// If you do not want to use the user profile function, override this function and leave it empty.
        /// - Parameter user: `SBUUser` object used for user profile configuration
        open func setUserProfileTapAction(_ user: SBUUser) {
            self.delegate?.userListModule(self, didTapUserProfileFor: user)
        }
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBUUserListModule.List: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noMembers)
        }
        
        SBULog.info("[Request] Retry load user list")
        self.delegate?.userListModuleDidSelectRetry(self)
    }
}

// MARK: - UITableView relations
extension SBUUserListModule.List: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
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
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        self.delegate?.userListModule(self, didDetectPreloadingPosition: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.userListModule(self, didSelectRowAt: indexPath)
    }
}
