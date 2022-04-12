//
//  SBUMemberListModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


public protocol SBUMemberListModuleListDelegate: SBUCommonDelegate {
    /// Called when the member cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUMemberListModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func memberListModule(_ listComponent: SBUMemberListModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUMemberListModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func memberListModule(_ listComponent: SBUMemberListModule.List, didDetectPreloadingPosition indexPath: IndexPath)

    /// Called when the more menu was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUMemberListModule.List` object.
    ///    - user: The `SBUUser` of more menu that was tapped.
    func memberListModule(_ listComponent: SBUMemberListModule.List, didTapMoreMenuFor member: SBUUser)
    
    /// Called when the user profile was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUMemberListModule.List` object.
    ///    - user: The `SBUUser` of user profile that was tapped.
    func memberListModule(_ listComponent: SBUMemberListModule.List, didTapUserProfileFor member: SBUUser)
    
    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUMemberListModule.List` object.
    func memberListModuleDidSelectRetry(_ listComponent: SBUMemberListModule.List)
}


public protocol SBUMemberListModuleListDataSource: AnyObject {
    /// Ask the data source to return the `SBDBaseChannel` object.
    /// - Parameters:
    ///    - listComponent: `SBUMemberListModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `SBDBaseChannel` object.
    func memberListModule(_ listComponent: SBUMemberListModule.List, channelForTableView tableView: UITableView) -> SBDBaseChannel?
    
    /// Ask the data source to return the member list.
    /// - Parameters:
    ///    - listComponent: `SBUMemberListModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `SBUUser` object.
    func memberListModule(_ listComponent: SBUMemberListModule.List, membersInTableView tableView: UITableView) -> [SBUUser]    
}


extension SBUMemberListModule {
    
    /// A module component that represent the list of `SBUMemberListModule`.
    @objc(SBUMemberListModuleList)
    @objcMembers open class List: UIView {
        
        // MARK: - UI properties (Public)
        /// The table view that shows the list of the members.
        public var tableView = UITableView()
        
        /// A view that displays when the table view is empty.
        public var emptyView: UIView? = nil {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        
        /// The member cell for `UITableViewCell` object. Use `register(memberCell:nib:)` to update.
        public var memberCell: UITableViewCell? = nil
        
        public var theme: SBUUserListTheme? = nil
        public var componentTheme: SBUComponentTheme? = nil
        
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUMemberListModuleListDelegate? = nil
        public weak var dataSource: SBUMemberListModuleListDataSource? = nil

        public var channel: SBDBaseChannel? {
            self.dataSource?.memberListModule(self, channelForTableView: self.tableView)
        }
        public var memberList: [SBUUser] {
            self.dataSource?.memberListModule(self, membersInTableView: self.tableView) ?? []
        }
        public var memberListType: ChannelMemberListType = .none
        
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUMemberListModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUMemberListModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUMemberListModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUMemberListModuleListDataSource`
        ///   - memberListType: `ChannelMemberListType` Type
        ///   - theme: `SBUUserListTheme` object
        ///   - componentTheme: `SBUComponentTheme` object
        open func configure(delegate: SBUMemberListModuleListDelegate,
                            dataSource: SBUMemberListModuleListDataSource,
                            memberListType: ChannelMemberListType,
                            theme: SBUUserListTheme,
                            componentTheme: SBUComponentTheme) {
            self.delegate = delegate
            self.dataSource = dataSource

            self.memberListType = memberListType
            
            self.theme = theme
            self.componentTheme = componentTheme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
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
            self.addSubview(self.tableView)
            
            // register cell
            if self.memberCell == nil {
                self.register(memberCell: SBUUserCell())
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
        }
        
        
        // MARK: - TableView
        
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            if self.memberListType == .mutedMembers ||
                self.memberListType == .bannedMembers {
                
                if !self.memberList.isEmpty {
                    self.updateEmptyView(type: .none)
                } else {
                    self.updateEmptyView(
                        type: self.memberListType == .mutedMembers
                        ? .noMutedMembers
                        : .noBannedMembers
                    )
                }
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }

        // MARK: - TableView: Cell
        
        /// Registers a custom cell as a member cell based on `UITableViewCell`.
        /// - Parameters:
        ///   - channelCell: Customized member cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom member cell, please use this function before calling `configure(delegate:dataSource:memberListType:theme:componentTheme:)`
        /// ```swift
        /// listComponent.register(memberCell: MyMemberCell)
        /// listComponent.configure(delegate: self, dataSource: self, memberListType: .type, theme: theme, componentTheme: componentTheme)
        /// ```
        public func register(memberCell: UITableViewCell, nib: UINib? = nil) {
            self.memberCell = memberCell
            if let nib = nib {
                self.tableView.register(
                    nib,
                    forCellReuseIdentifier: memberCell.sbu_className
                )
            } else {
                self.tableView.register(
                    type(of: memberCell),
                    forCellReuseIdentifier: memberCell.sbu_className
                )
            }
        }
        
        /// Configures cell for a particular row.
        /// - Parameters:
        ///   - cell: `UITableViewCell` object
        ///   - indexPath: An index path representing the `cell`
        open func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            var userListType: UserListType = .none
            
            switch self.memberListType {
            case .channelMembers:
                userListType = .channelMembers
            case .operators:
                userListType = .operators
            case .mutedMembers:
                userListType = .mutedMembers
            case .bannedMembers:
                userListType = .bannedMembers
            case .participants:
                userListType = .participants
            default:
                break
            }
            
            var operatorMode = false
            if let channel = self.channel as? SBDGroupChannel {
                operatorMode = channel.myRole == .operator
            }
            
            let member = self.memberList[indexPath.row]
            if let defaultCell = cell as? SBUUserCell {
                defaultCell.configure(
                    type: userListType,
                    user: member,
                    operatorMode: operatorMode
                )
                
                if self.channel is SBDGroupChannel {
                    defaultCell.moreMenuHandler = { [weak self] in
                        guard let self = self else { return }
                        self.setMoreMenuTapAction(member)
                    }
                }
                defaultCell.userProfileTapHandler = { [weak self] in
                    guard let self = self else { return }
                    self.setUserProfileTapAction(member)
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
        /// - Parameter member: `SBUUser` obejct
        open func setMoreMenuTapAction(_ member: SBUUser) {
            self.delegate?.memberListModule(self, didTapMoreMenuFor: member)
        }
        
        /// Sets up the user profile tap action.
        /// If you do not want to use the user profile function, override this function and leave it empty.
        /// - Parameter user: `SBUUser` object used for user profile configuration
        open func setUserProfileTapAction(_ user: SBUUser) {
            self.delegate?.memberListModule(self, didTapUserProfileFor: user)
        }
    }
}


// MARK: - SBUEmptyViewDelegate
extension SBUMemberListModule.List: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noMembers)
        }
        
        SBULog.info("[Request] Retry load member list")
        self.delegate?.memberListModuleDidSelectRetry(self)
    }
}


// MARK: - UITableView relations
extension SBUMemberListModule.List: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberList.count
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = nil
        if let memberCell = self.memberCell {
            cell = tableView.dequeueReusableCell(withIdentifier: memberCell.sbu_className)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SBUUserCell.sbu_className)
        }

        cell?.selectionStyle = .none
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        self.delegate?.memberListModule(self, didDetectPreloadingPosition: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.memberListModule(self, didSelectRowAt: indexPath)
    }
}
