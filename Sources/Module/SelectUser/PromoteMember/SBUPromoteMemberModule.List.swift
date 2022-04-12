//
//  SBUPromoteMemberModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


public protocol SBUPromoteMemberModuleListDelegate: SBUBaseSelectUserModuleListDelegate {
    /// Called when the member cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUPromoteMemberModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func promoteMemberModule(_ listComponent: SBUPromoteMemberModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUPromoteMemberModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func promoteMemberModule(_ listComponent: SBUPromoteMemberModule.List, didDetectPreloadingPosition indexPath: IndexPath)

    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUPromoteMemberModule.List` object.
    func promoteMemberModuleDidSelectRetry(_ listComponent: SBUPromoteMemberModule.List)
}


public protocol SBUPromoteMemberModuleListDataSource: SBUBaseSelectUserModuleListDataSource { }


extension SBUPromoteMemberModule {
    
    /// A module component that represent the list of `SBUPromoteMemberModule`.
    @objc(SBUPromoteMemberModuleList)
    @objcMembers open class List: SBUBaseSelectUserModule.List {
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUPromoteMemberModuleListDelegate? {
            get { self.baseDelegate as? SBUPromoteMemberModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        public weak var dataSource: SBUPromoteMemberModuleListDataSource? {
            get { self.baseDataSource as? SBUPromoteMemberModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUPromoteMemberModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUPromoteMemberModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUPromoteMemberModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUPromoteMemberModuleListDataSource`
        ///   - theme: `SBUUserListTheme` object
        open func configure(delegate: SBUPromoteMemberModuleListDelegate,
                            dataSource: SBUPromoteMemberModuleListDataSource,
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
                type: .inviteUser,
                user: user,
                isChecked: self.isSelectedUser(user)
            )
        }
    }
}


// MARK: - SBUEmptyViewDelegate
extension SBUPromoteMemberModule.List {
    open override func didSelectRetry() {
        super.didSelectRetry()
        
        self.delegate?.promoteMemberModuleDidSelectRetry(self)
    }
}


// MARK: - UITableView relations
extension SBUPromoteMemberModule.List {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.promoteMemberModule(self, didSelectRowAt: indexPath)
        
        guard let user = self.userList?[indexPath.row],
              let defaultCell = self.tableView.cellForRow(at: indexPath)
                as? SBUUserCell else { return }

        let isSelected = self.isSelectedUser(user)
        defaultCell.selectUser(isSelected)
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        self.delegate?.promoteMemberModule(self, didDetectPreloadingPosition: indexPath)
    }
}
