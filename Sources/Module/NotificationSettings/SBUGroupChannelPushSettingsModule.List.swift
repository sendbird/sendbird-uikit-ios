//
//  SBUGroupChannelPushSettingsModule.List.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the list component in the channel push settings.
public protocol SBUGroupChannelPushSettingsModuleListDelegate: SBUCommonDelegate {
    /// Called when changed push notification option
    /// - Parameters:
    ///   - listComponent: `SBUGroupChannelPushSettingsModule.List` object.
    ///   - pushTriggerOption: `GroupChannelPushTriggerOption` object to change.
    func groupChannelPushSettingsModule(
        _ listComponent: SBUGroupChannelPushSettingsModule.List,
        didChangeNotification pushTriggerOption: GroupChannelPushTriggerOption
    )
}

/// Methods to get data source for the list component in the channel push settings.
public protocol SBUGroupChannelPushSettingsModuleListDataSource: AnyObject {
    /// Ask the data source to return the pushTriggerOption
    /// - Parameters:
    ///   - listComponent: `SBUGroupChannelPushSettingsModule.List` object.
    ///   - tableView: `UITableView` object from list component.
    /// - Returns: The object of `GroupChannelPushTriggerOption` object
    func groupChannelPushSettingsModule(
        _ listComponent: SBUGroupChannelPushSettingsModule.List,
        pushTriggerOptionForTableView tableView: UITableView
    ) -> GroupChannelPushTriggerOption?
}

extension SBUGroupChannelPushSettingsModule {
    
    /// A module component that represent the list of `SBUGroupChannelPushSettingsModule`.
    @objc(SBUGroupChannelPushSettingsModuleList)
    open class List: UIView {
        
        // MARK: - UI properties (Public)
        /// The table view that shows the items of the notification settings.
        public var tableView = UITableView()
        
        /// The object that is used as the theme of the list component. The theme must adopt the `SBUChannelSettingsTheme` class.
        public var theme: SBUChannelSettingsTheme?
        
        // MARK: - Logic properties (Public)
        /// The object that is group channel's push trigger option. If the value is nil, the default value set to off.
        public var pushTriggerOption: GroupChannelPushTriggerOption {
            self.dataSource?.groupChannelPushSettingsModule(
                self,
                pushTriggerOptionForTableView: self.tableView
            ) ?? .off
        }
        
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUGroupChannelPushSettingsModuleListDelegate`.
        public weak var delegate: SBUGroupChannelPushSettingsModuleListDelegate?
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUGroupChannelPushSettingsModuleListDataSource`.
        public weak var dataSource: SBUGroupChannelPushSettingsModuleListDataSource?
        
        // MARK: Lifecycle
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelPushSettingsModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUGroupChannelPushSettingsModuleListDataSource`
        ///   - theme: `SBUChannelSettingsTheme` object
        open func configure(
            delegate: SBUGroupChannelPushSettingsModuleListDelegate?,
            dataSource: SBUGroupChannelPushSettingsModuleListDataSource?,
            theme: SBUChannelSettingsTheme
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupLayouts()
        }
        
        open func setupViews() {
            // tableView
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.bounces = false
            self.tableView.alwaysBounceVertical = false
            self.tableView.separatorStyle = .none
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.sectionHeaderHeight = 0
            self.addSubview(self.tableView)
            
            self.tableView.register(
                type(of: SBUChannelPushSettingCell()),
                forCellReuseIdentifier: SBUChannelPushSettingCell.sbu_className
            )
        }
        
        // MARK: - Style
        open func setupLayouts() {
            self.tableView
                .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        open func setupStyles(theme: SBUChannelSettingsTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
        }
        
        // MARK: - TableView
        
        /// This function configures cell
        /// - Parameters:
        ///   - cell:UITableViewCell
        ///   - indexPath: indexPath
        open func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            guard let defaultCell = cell as? SBUChannelPushSettingCell else { return }
            switch indexPath.row {
            case 0:
                defaultCell.configure(pushTriggerOption: self.pushTriggerOption)
                defaultCell.switchAction = { [weak self] isOn in
                    guard let self = self else { return }
                    self.delegate?.groupChannelPushSettingsModule(
                        self,
                        didChangeNotification: isOn ? .all : .off
                    )
                }
            case 1:
                defaultCell.configure(pushTriggerOption: self.pushTriggerOption, subType: .all)
                defaultCell.radioButtonAction = { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.groupChannelPushSettingsModule(
                        self,
                        didChangeNotification: .all
                    )
                }
            case 2:
                defaultCell.configure(pushTriggerOption: self.pushTriggerOption, subType: .mention)
                defaultCell.radioButtonAction = { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.groupChannelPushSettingsModule(
                        self,
                        didChangeNotification: .mentionOnly
                    )
                }
            default:
                break
            }
        }
        
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableView relations
extension SBUGroupChannelPushSettingsModule.List: UITableViewDelegate, UITableViewDataSource {
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell? = tableView.dequeueReusableCell(
            withIdentifier: SBUChannelPushSettingCell.sbu_className
        )
        cell?.selectionStyle = .none
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // on/off toggle + subTypes
        var rowCount = 1
        
        if self.pushTriggerOption != .off {
            rowCount += ChannelPushSettingsSubType.allCases.count
        }
        
        return rowCount
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SBUChannelPushSettingCell else {
            return
        }
        
        if indexPath.row != 0 {
            cell.radioButtonAction?()
        }
    }
}
