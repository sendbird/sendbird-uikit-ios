//
//  SBUGroupChannelSettingsModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
#if SWIFTUI
import SwiftUI
#endif

// swiftlint:disable type_name
public protocol SBUGroupChannelSettingsModuleListDelegate: SBUBaseChannelSettingsModuleListDelegate {
    /// Called when the setting item cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelSettingsModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func groupChannelSettingsModule(_ listComponent: SBUGroupChannelSettingsModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the moderations item cell was selected in the `listComponent`.
    /// - Parameter listComponent: `SBUGroupChannelSettingsModule.List` object.
    func groupChannelSettingsModuleDidSelectModerations(_ listComponent: SBUGroupChannelSettingsModule.List)
    
    /// Called when the notifications item cell was selected in the `listComponent`.
    /// - Parameter listComponent: `SBUGroupChannelSettingsModule.List` object.
    func groupChannelSettingsModuleDidSelectNotifications(_ listComponent: SBUGroupChannelSettingsModule.List)
    
    /// Called when the members item cell was selected in the `listComponent`.
    /// - Parameter listComponent: `SBUGroupChannelSettingsModule.List` object.
    func groupChannelSettingsModuleDidSelectMembers(_ listComponent: SBUGroupChannelSettingsModule.List)
    
    /// Called when the search item cell was selected in the `listComponent`.
    /// - Parameter listComponent: `SBUGroupChannelSettingsModule.List` object.
    func groupChannelSettingsModuleDidSelectSearch(_ listComponent: SBUGroupChannelSettingsModule.List)
    
    /// Called when the leave item cell was selected in the `listComponent`.
    /// - Parameter listComponent: `SBUGroupChannelSettingsModule.List` object.
    func groupChannelSettingsModuleDidSelectLeave(_ listComponent: SBUGroupChannelSettingsModule.List)
}

public protocol SBUGroupChannelSettingsModuleListDataSource: SBUBaseChannelSettingsModuleListDataSource { }
// swiftlint:enable type_name

extension SBUGroupChannelSettingsModule {
    
    /// A module component that represent the list of `SBUGroupChannelSettingsModule`.
    @objc(SBUGroupChannelSettingsModuleList)
    @objcMembers
    open class List: SBUBaseChannelSettingsModule.List {
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
        
        // MARK: - default view
        
        override func createDefaultChannelInfoView() -> SBUChannelSettingsChannelInfoView {
            Self.ChannelInfoView.init()
        }
        
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
            
            self.setupItems()
            
            self.setupViews()
            #if SWIFTUI
            applyViewConverter(.channelInfo)
            #endif
            
            self.setupLayouts()
            self.setupStyles()
        }
        
        open override func setupViews() {
            super.setupViews()
            
            self.tableView.register(
                Self.SettingCell,
                forCellReuseIdentifier: SBUGroupChannelSettingCell.sbu_className
            )
        }
        
        /// Sets up items for tableView cell configuration.
        open override func setupItems() {
            let moderationsItem = self.createModerationsItem()
            let notificationsItem = self.createNotificationItem()
            let membersItem = self.createMembersItem()
            let searchItem = self.createSearchItem()
            let leaveItem = self.createLeaveItem()

            var items = self.isOperator ? [moderationsItem] : []
            items += [notificationsItem, membersItem]
            if SBUAvailable.isSupportMessageSearch() {
                items += [searchItem]
            }
            items += [leaveItem]
            
            self.items = items
        }
        
        open func createModerationsItem() -> SBUChannelSettingItem {
            let moderationsItem = {
                #if SWIFTUI
                return SBUChannelSettingItem(
                    id: SBUChannelSettingItem.Identifier.moderation,
                    title: SBUStringSet.ChannelSettings_Moderations,
                    icon: SBUIconSetType.iconModerations.image(
                        with: theme?.cellTypeIconTintColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    ),
                    isRightButtonHidden: false) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectModerations(self)
                    }
                #else
                return SBUChannelSettingItem(
                    title: SBUStringSet.ChannelSettings_Moderations,
                    icon: SBUIconSetType.iconModerations.image(
                        with: theme?.cellTypeIconTintColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    ),
                    isRightButtonHidden: false) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectModerations(self)
                    }
                #endif
            }()

            return moderationsItem
        }

        open func createNotificationItem() -> SBUChannelSettingItem {
            let notificationSubTitle: String = {
                switch channel?.myPushTriggerOption {
                case .off:
                    return SBUStringSet.ChannelSettings_Notifications_Off
                case .mentionOnly:
                    return SBUStringSet.ChannelSettings_Notifications_Mentiones_Only
                default:
                    return SBUStringSet.ChannelSettings_Notifications_On
                }
            }()

            let notificationsItem = {
                #if SWIFTUI
                return SBUChannelSettingItem(
                    id: SBUChannelSettingItem.Identifier.notification,
                    title: SBUStringSet.ChannelSettings_Notifications,
                    subTitle: notificationSubTitle,
                    icon: SBUIconSetType.iconNotifications.image(
                        with: theme?.cellTypeIconTintColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    ),
                    isRightButtonHidden: false) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectNotifications(self)
                    }
                #else
                return SBUChannelSettingItem(
                    title: SBUStringSet.ChannelSettings_Notifications,
                    subTitle: notificationSubTitle,
                    icon: SBUIconSetType.iconNotifications.image(
                        with: theme?.cellTypeIconTintColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    ),
                    isRightButtonHidden: false) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectNotifications(self)
                    }
                #endif
            }()

            return notificationsItem
        }

        open func createMembersItem() -> SBUChannelSettingItem {
            let membersItem = {
                #if SWIFTUI
                return SBUChannelSettingItem(
                    id: SBUChannelSettingItem.Identifier.members,
                    title: SBUStringSet.ChannelSettings_Members_Title,
                    subTitle: channel?.memberCount.unitFormattedString,
                    icon: SBUIconSetType.iconMembers.image(
                        with: theme?.cellTypeIconTintColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    ),
                    isRightButtonHidden: false) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectMembers(self)
                    }
                #else
                return SBUChannelSettingItem(
                    title: SBUStringSet.ChannelSettings_Members_Title,
                    subTitle: channel?.memberCount.unitFormattedString,
                    icon: SBUIconSetType.iconMembers.image(
                        with: theme?.cellTypeIconTintColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    ),
                    isRightButtonHidden: false) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectMembers(self)
                    }
                #endif
            }()

            return membersItem
        }

        open func createSearchItem() -> SBUChannelSettingItem {
            let searchItem = {
                #if SWIFTUI
                return SBUChannelSettingItem(
                    id: SBUChannelSettingItem.Identifier.searchItem,
                    title: SBUStringSet.ChannelSettings_Search,
                    icon: SBUIconSetType.iconSearch.image(
                        with: theme?.cellTypeIconTintColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    )) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectSearch(self)
                    }
                #else
                return SBUChannelSettingItem(
                    title: SBUStringSet.ChannelSettings_Search,
                    icon: SBUIconSetType.iconSearch.image(
                        with: theme?.cellTypeIconTintColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    )) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectSearch(self)
                    }
                #endif
            }()

            return searchItem
        }

        open func createLeaveItem() -> SBUChannelSettingItem {
            let leaveItem = {
                #if SWIFTUI
                return SBUChannelSettingItem(
                    id: SBUChannelSettingItem.Identifier.leaveChannel,
                    title: SBUStringSet.ChannelSettings_Leave,
                    icon: SBUIconSetType.iconLeave.image(
                        with: theme?.cellLeaveIconColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    )) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectLeave(self)
                    }
                #else
                return SBUChannelSettingItem(
                    title: SBUStringSet.ChannelSettings_Leave,
                    icon: SBUIconSetType.iconLeave.image(
                        with: theme?.cellLeaveIconColor,
                        to: SBUIconSetType.Metric.defaultIconSize
                    )) { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.groupChannelSettingsModuleDidSelectLeave(self)
                    }
                #endif
            }()

            return leaveItem
        }
        
        // MARK: - TableView: Cell
        open override func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            guard let defaultCell = cell as? SBUGroupChannelSettingCell else { return }
            
            let item = self.items[indexPath.row]
            
            var didApplyCellConverter = false
            #if SWIFTUI
            switch item.id {
            case SBUChannelSettingItem.Identifier.moderation:
                didApplyCellConverter = defaultCell.applyViewConverter(.moderation, item: item)
            case SBUChannelSettingItem.Identifier.notification:
                didApplyCellConverter = defaultCell.applyViewConverter(.notification, item: item, channel: channel)
            case SBUChannelSettingItem.Identifier.members:
                didApplyCellConverter = defaultCell.applyViewConverter(.member, item: item, channel: channel)
            case SBUChannelSettingItem.Identifier.searchItem:
                didApplyCellConverter = defaultCell.applyViewConverter(.searchItem, item: item)
            case SBUChannelSettingItem.Identifier.leaveChannel:
                didApplyCellConverter = defaultCell.applyViewConverter(.leaveChannel, item: item)
            default:
                break
            }
            #endif
            
            if !didApplyCellConverter {
                defaultCell.configure(with: item)
            }
        }        
        
        open var headerWrapper: UIView?
        // Reload
        open override func reloadTableView() {
            var didApplyTableViewConverter = false
            #if SWIFTUI
            didApplyTableViewConverter = self.applyViewConverter(.entireContent)
            if didApplyTableViewConverter == false {
                _ = self.applyViewConverter(.channelInfo)
            }
            #endif
            // No need to update the table view,
            // as the table view is already removed from superview
            // if SwiftUI view builder is used.
            if didApplyTableViewConverter == false {
                super.reloadTableView()
                return
            }
        }
    }
}

// MARK: - UITableView relations
extension SBUGroupChannelSettingsModule.List {
    open override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: UITableViewCell? = tableView.dequeueReusableCell(
            withIdentifier: SBUGroupChannelSettingCell.sbu_className)
        
        cell?.selectionStyle = .none
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.endEditingChannelInfoView()
        
        self.delegate?.groupChannelSettingsModule(self, didSelectRowAt: indexPath)
        
        let item = self.items[indexPath.row]
        item.tapHandler?()
    }
}
