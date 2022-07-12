//
//  SBUGroupChannelSettingsModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


public protocol SBUGroupChannelSettingsModuleListDelegate: SBUBaseChannelSettingsModuleListDelegate {
    /// Called when the setting item cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelSettingsModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func groupChannelSettingsModule(_ listComponent: SBUGroupChannelSettingsModule.List, didSelectRowAt indexPath: IndexPath)
}


public protocol SBUGroupChannelSettingsModuleListDataSource: SBUBaseChannelSettingsModuleListDataSource { }


extension SBUGroupChannelSettingsModule {
    
    /// A module component that represent the list of `SBUGroupChannelSettingsModule`.
    @objc(SBUGroupChannelSettingsModuleList)
    @objcMembers open class List: SBUBaseChannelSettingsModule.List {
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUGroupChannelSettingsModuleListDelegate? {
            get { self.baseDelegate as? SBUGroupChannelSettingsModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        
        public weak var dataSource: SBUGroupChannelSettingsModuleListDataSource? {
            get { self.baseDataSource as? SBUGroupChannelSettingsModuleListDataSource }
            set { self.baseDataSource = newValue }
        }

        public weak var channel: GroupChannel? { self.baseChannel as? GroupChannel }

        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUGroupChannelSettingsModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUGroupChannelSettingsModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelSettingsModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUGroupChannelSettingsModuleListDataSource`
        ///   - theme: `SBUChannelSettingsTheme` object
        open func configure(delegate: SBUGroupChannelSettingsModuleListDelegate,
                            dataSource: SBUGroupChannelSettingsModuleListDataSource,
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
                type(of: SBUChannelSettingCell()),
                forCellReuseIdentifier: SBUChannelSettingCell.sbu_className
            )
        }
        
        
        // MARK: - TableView: Cell
        open override func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            guard let defaultCell = cell as? SBUChannelSettingCell else { return }
            
            let rowValue = indexPath.row + (self.isOperator ? 0 : 1)
            guard let type = ChannelSettingItemType.from(row: rowValue) else { return }
            
            if let channel = self.channel {
                defaultCell.configure(type: type, channel: channel)
            }
        }
    }
}


// MARK: - UITableView relations
extension SBUGroupChannelSettingsModule.List {
    open override func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell? = tableView.dequeueReusableCell(
            withIdentifier: SBUChannelSettingCell.sbu_className)
        
        cell?.selectionStyle = .none
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChannelSettingItemType.allTypes(isOperator: self.isOperator).count
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.endEditingChannelInfoView()
        
        self.delegate?.groupChannelSettingsModule(self, didSelectRowAt: indexPath)
    }
}
