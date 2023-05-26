//
//  SBUInviteUserModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUInviteUserModuleListDelegate: SBUBaseSelectUserModuleListDelegate {
    /// Called when the user cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUInviteUserModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func inviteUserModule(_ listComponent: SBUInviteUserModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUInviteUserModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func inviteUserModule(_ listComponent: SBUInviteUserModule.List, didDetectPreloadingPosition indexPath: IndexPath)

    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUInviteUserModule.List` object.
    func inviteUserModuleDidSelectRetry(_ listComponent: SBUInviteUserModule.List)
}

public protocol SBUInviteUserModuleListDataSource: SBUBaseSelectUserModuleListDataSource { }

extension SBUInviteUserModule {
    
    /// A module component that represent the list of `SBUInviteUserModule`.
    @objc(SBUInviteUserModuleList)
    @objcMembers open class List: SBUBaseSelectUserModule.List {
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUInviteUserModuleListDelegate? {
            get { self.baseDelegate as? SBUInviteUserModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        public weak var dataSource: SBUInviteUserModuleListDataSource? {
            get { self.baseDataSource as? SBUInviteUserModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUInviteUserModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUInviteUserModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUInviteUserModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUInviteUserModuleListDataSource`
        ///   - theme: `SBUUserListTheme` object
        open func configure(delegate: SBUInviteUserModuleListDelegate,
                            dataSource: SBUInviteUserModuleListDataSource,
                            theme: SBUUserListTheme) {
            
            self.delegate = delegate
            self.dataSource = dataSource
            
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - TableView: Cell
        open override func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            guard let user = self.userList?[indexPath.row],
                  let defaultCell = cell as? SBUUserCell else { return }
            defaultCell.configure(
                type: .invite,
                user: user,
                isChecked: self.isSelectedUser(user)
            )
        }
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBUInviteUserModule.List {
    open override func didSelectRetry() {
        super.didSelectRetry()
        
        self.delegate?.inviteUserModuleDidSelectRetry(self)
    }
}

// MARK: - UITableView relations
extension SBUInviteUserModule.List {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.inviteUserModule(self, didSelectRowAt: indexPath)
        
        guard let user = self.userList?[indexPath.row],
              let defaultCell = self.tableView.cellForRow(at: indexPath)
                as? SBUUserCell else { return }

        let isSelected = self.isSelectedUser(user)
        defaultCell.selectUser(isSelected)
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        self.delegate?.inviteUserModule(self, didDetectPreloadingPosition: indexPath)
    }
}
