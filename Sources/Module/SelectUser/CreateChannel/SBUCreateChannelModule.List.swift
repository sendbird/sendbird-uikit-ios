//
//  SBUCreateChannelModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUCreateChannelModuleListDelegate: SBUBaseSelectUserModuleListDelegate {
    /// Called when the user cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUCreateChannelModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func createChannelModule(_ listComponent: SBUCreateChannelModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUCreateChannelModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func createChannelModule(_ listComponent: SBUCreateChannelModule.List, didDetectPreloadingPosition indexPath: IndexPath)

    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUCreateChannelModule.List` object.
    func createChannelModuleDidSelectRetry(_ listComponent: SBUCreateChannelModule.List)
}

/// Methods to get data source for list component in a channel creating.
public protocol SBUCreateChannelModuleListDataSource: SBUBaseSelectUserModuleListDataSource { }

extension SBUCreateChannelModule {
    
    /// A module component that represent the list of `SBUCreateChannelModule`.
    @objc(SBUCreateChannelModuleList)
    @objcMembers open class List: SBUBaseSelectUserModule.List {
       
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUCreateChannelModuleListDelegate`.
        public weak var delegate: SBUCreateChannelModuleListDelegate? {
            get { self.baseDelegate as? SBUCreateChannelModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUGroupChannelModuleListDataSource`.
        public weak var dataSource: SBUCreateChannelModuleListDataSource? {
            get { self.baseDataSource as? SBUCreateChannelModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUCreateChannelModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUCreateChannelModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        open func configure(delegate: SBUCreateChannelModuleListDelegate,
                            dataSource: SBUCreateChannelModuleListDataSource,
                            theme: SBUUserListTheme) {
            
            self.delegate = delegate
            self.dataSource = dataSource
            
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - TableView: Cell
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUCreateChannelModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUCreateChannelModuleListDataSource`
        ///   - theme: `SBUUserListTheme` object
        open override func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            guard let user = self.userList?[indexPath.row],
                  let defaultCell = cell as? SBUUserCell else { return }
            defaultCell.configure(
                type: .createChannel,
                user: user,
                isChecked: self.isSelectedUser(user)
            )
        }
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBUCreateChannelModule.List {
    /// Called when the retry button on the empty view was tapped.
    open override func didSelectRetry() {
        super.didSelectRetry()
        
        self.delegate?.createChannelModuleDidSelectRetry(self)
    }
}

// MARK: - UITableView relations
extension SBUCreateChannelModule.List {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.createChannelModule(self, didSelectRowAt: indexPath)
        
        guard let user = self.userList?[indexPath.row],
              let defaultCell = self.tableView.cellForRow(at: indexPath)
                as? SBUUserCell else { return }

        let isSelected = self.isSelectedUser(user)
        defaultCell.selectUser(isSelected)
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        self.delegate?.createChannelModule(self, didDetectPreloadingPosition: indexPath)
    }
}
