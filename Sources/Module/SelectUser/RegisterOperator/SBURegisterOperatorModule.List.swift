//
//  SBURegisterOperatorModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBURegisterOperatorModuleListDelegate: SBUBaseSelectUserModuleListDelegate {
    /// Called when the member cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBURegisterOperatorModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func registerOperatorModule(_ listComponent: SBURegisterOperatorModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBURegisterOperatorModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func registerOperatorModule(_ listComponent: SBURegisterOperatorModule.List, didDetectPreloadingPosition indexPath: IndexPath)

    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBURegisterOperatorModule.List` object.
    func registerOperatorModuleDidSelectRetry(_ listComponent: SBURegisterOperatorModule.List)
}

public protocol SBURegisterOperatorModuleListDataSource: SBUBaseSelectUserModuleListDataSource { }

extension SBURegisterOperatorModule {
    
    /// A module component that represent the list of `SBURegisterOperatorModule`.
    @objc(SBURegisterOperatorModuleList)
    @objcMembers open class List: SBUBaseSelectUserModule.List {
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBURegisterOperatorModuleListDelegate? {
            get { self.baseDelegate as? SBURegisterOperatorModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        public weak var dataSource: SBURegisterOperatorModuleListDataSource? {
            get { self.baseDataSource as? SBURegisterOperatorModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBURegisterOperatorModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBURegisterOperatorModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBURegisterOperatorModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBURegisterOperatorModuleListDataSource`
        ///   - theme: `SBUUserListTheme` object
        open func configure(delegate: SBURegisterOperatorModuleListDelegate,
                            dataSource: SBURegisterOperatorModuleListDataSource,
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
            
            if user.isOperator {
                defaultCell.operatorLabel.isHidden = false
                defaultCell.checkboxButton.isEnabled = false
                defaultCell.isUserInteractionEnabled = false
            }
        }
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBURegisterOperatorModule.List {
    open override func didSelectRetry() {
        super.didSelectRetry()
        
        self.delegate?.registerOperatorModuleDidSelectRetry(self)
    }
}

// MARK: - UITableView relations
extension SBURegisterOperatorModule.List {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.registerOperatorModule(self, didSelectRowAt: indexPath)
        
        guard let user = self.userList?[indexPath.row],
              let defaultCell = self.tableView.cellForRow(at: indexPath)
                as? SBUUserCell else { return }

        let isSelected = self.isSelectedUser(user)
        defaultCell.selectUser(isSelected)
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        self.delegate?.registerOperatorModule(self, didDetectPreloadingPosition: indexPath)
    }
}
