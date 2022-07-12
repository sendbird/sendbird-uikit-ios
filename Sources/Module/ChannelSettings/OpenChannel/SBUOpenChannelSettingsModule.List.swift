//
//  SBUOpenChannelSettingsModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


public protocol SBUOpenChannelSettingsModuleListDelegate: SBUBaseChannelSettingsModuleListDelegate {
    /// Called when the setting item cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUOpenChannelSettingsModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func openChannelSettingsModule(_ listComponent: SBUOpenChannelSettingsModule.List, didSelectRowAt indexPath: IndexPath)
}


public protocol SBUOpenChannelSettingsModuleListDataSource: SBUBaseChannelSettingsModuleListDataSource { }


extension SBUOpenChannelSettingsModule {
    
    /// A module component that represent the list of `SBUOpenChannelSettingsModule`.
    @objc(SBUOpenChannelSettingsModuleList)
    @objcMembers open class List: SBUBaseChannelSettingsModule.List {
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUOpenChannelSettingsModuleListDelegate? {
            get { self.baseDelegate as? SBUOpenChannelSettingsModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        
        public weak var dataSource: SBUOpenChannelSettingsModuleListDataSource? {
            get { self.baseDataSource as? SBUOpenChannelSettingsModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        public weak var channel: OpenChannel? { self.baseChannel as? OpenChannel }


        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUOpenChannelSettingsModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUOpenChannelSettingsModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUOpenChannelSettingsModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUOpenChannelSettingsModuleListDataSource`
        ///   - channel: channel object
        ///   - isOperator: operator status
        ///   - theme: `SBUChannelSettingsTheme` object
        open func configure(delegate: SBUOpenChannelSettingsModuleListDelegate,
                            dataSource: SBUOpenChannelSettingsModuleListDataSource,
                            theme: SBUChannelSettingsTheme) {
            
            self.delegate = delegate
            self.dataSource = dataSource
            
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        open override func setupViews() {
            super.setupViews()
            
            self.tableView.register(
                type(of: SBUOpenChannelSettingCell()),
                forCellReuseIdentifier: SBUOpenChannelSettingCell.sbu_className
            )
        }
        
        
        // MARK: - TableView: Cell
        open override func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            guard let defaultCell = cell as? SBUOpenChannelSettingCell else { return }
            
            let rowValue = indexPath.row + (self.isOperator ? 0 : 1)
            if let type = OpenChannelSettingItemType(rawValue: rowValue) {
                defaultCell.configure(type: type, channel: self.channel)
            }
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension SBUOpenChannelSettingsModule.List {
    open override func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell? = tableView.dequeueReusableCell(
            withIdentifier: SBUOpenChannelSettingCell.sbu_className)
        
        cell?.selectionStyle = .none
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OpenChannelSettingItemType.allTypes(isOperator: self.isOperator).count
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.endEditingChannelInfoView()
        
        self.delegate?.openChannelSettingsModule(self, didSelectRowAt: indexPath)
    }
}
