//
//  SBUModerationsModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/04.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUModerationsModuleListDelegate: SBUCommonDelegate {
    /// Called when the moderation cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUModerationsModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func moderationsModule(_ listComponent: SBUModerationsModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when changed freeze mode.
    /// - Parameters:
    ///    - listComponent: `SBUModerationsModule.List` object.
    ///    - channel: The freeze mode state.
    func moderationsModule(_ listComponent: SBUModerationsModule.List, didChangeFreezeMode state: Bool)
}

public protocol SBUModerationsModuleListDataSource: AnyObject {
    /// Ask the data source to return the `BaseChannel` object.
    /// - Parameters:
    ///    - listComponent: `SBUModerationsModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `BaseChannel` object.
    func moderationsModule(_ listComponent: SBUModerationsModule.List, channelForTableView tableView: UITableView) -> BaseChannel?
}

extension SBUModerationsModule {
    
    /// A module component that represent the list of `SBUModerationsModuleList`.
    @objc(SBUModerationsModuleList)
    @objcMembers open class List: UIView {
        
        // MARK: - UI properties (Public)
        /// The table view that shows the moderation menu items as list.
        public var tableView = UITableView()
        
        /// The channel cell for `UITableViewCell` object. Use `register(moderationCell:nib:)` to update.
        public var moderationCell: UITableViewCell?
        
        public var theme: SBUChannelSettingsTheme?
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUModerationsModuleListDelegate?
        public weak var dataSource: SBUModerationsModuleListDataSource?
        
        public var channel: BaseChannel? {
            self.dataSource?.moderationsModule(self, channelForTableView: self.tableView)
        }
        
        // MARK: - LifeCycle
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUModerationsModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUModerationsModuleListDataSource`
        ///   - theme: `SBUChannelSettingsTheme` object
        open func configure(delegate: SBUModerationsModuleListDelegate,
                            dataSource: SBUModerationsModuleListDataSource,
                            theme: SBUChannelSettingsTheme) {
            
            self.delegate = delegate
            self.dataSource = dataSource
            
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }

        open func setupViews() {
            // tableview
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.bounces = false
            self.tableView.alwaysBounceVertical = false
            self.tableView.separatorStyle = .none
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.sectionHeaderHeight = 0
            self.addSubview(self.tableView)
            
            if self.moderationCell == nil {
                self.register(moderationCell: SBUModerationCell())
            }
        }
        
        deinit {
            SBULog.info("")
        }
        
        // MARK: - Style
        open func setupLayouts() {
            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUChannelSettingsTheme` object
        open func setupStyles(theme: SBUChannelSettingsTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
        }
        
        // MARK: - TableView: Cell
        
        /// Registers a custom cell as a moderation menu cell based on `UITableViewCell`.
        /// - Parameters:
        ///   - moderationCell: Customized moderation menu cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom moderation menu cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(moderationCell: MyModerationCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        public func register(moderationCell: UITableViewCell, nib: UINib? = nil) {
            self.moderationCell = moderationCell
            if let nib = nib {
                self.tableView.register(
                    nib,
                    forCellReuseIdentifier: moderationCell.sbu_className
                )
            } else {
                self.tableView.register(
                    type(of: moderationCell),
                    forCellReuseIdentifier: moderationCell.sbu_className
                )
            }
        }
        
        /// This function configures cell
        /// - Parameters:
        ///   - cell:UITableViewCell
        ///   - indexPath: indexPath
        open func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            guard let defaultCell = cell as? SBUModerationCell,
                  let channel = self.channel else { return }
            
            let type = ModerationItemType.allTypes(channel: channel)[indexPath.row]
            defaultCell.configure(type: type, channel: channel)
            
            if type == .freezeChannel {
                defaultCell.switchAction = { [weak self] isOn in
                    guard let self = self else { return }
                    self.delegate?.moderationsModule(self, didChangeFreezeMode: isOn)
                }
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
extension SBUModerationsModule.List: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let channel = self.channel else { return 0 }
        return ModerationItemType.allTypes(channel: channel).count
    }
    
    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if let moderationCell = self.moderationCell {
            cell = tableView.dequeueReusableCell(withIdentifier: moderationCell.sbu_className)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SBUModerationCell.sbu_className)
        }
        
        cell?.selectionStyle = .none
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.moderationsModule(self, didSelectRowAt: indexPath)
    }
}
