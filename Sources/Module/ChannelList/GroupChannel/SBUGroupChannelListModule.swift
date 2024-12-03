//
//  SBUGroupChannelListComponent.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/01.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: GroupChannelListModule
/// The class that represents the list of the group channel module
extension SBUGroupChannelListModule {
    /// The module component that contains ``SBUBaseChannelListModule/Header/titleView``, ``SBUBaseChannelListModule/Header/leftBarButton``, and ``SBUBaseChannelListModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelListModule.Header.Type = SBUGroupChannelListModule.Header.self
    /// The module component that shows the list of message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelListModule.List.Type = SBUGroupChannelListModule.List.self
    
    /// The module component that shows the common of message in the channel.
    /// - Since: 3.28.0
    public static var CommonComponent: SBUGroupChannelListModule.Common.Type = SBUGroupChannelListModule.Common.self
}

// MARK: Header
extension SBUGroupChannelListModule.Header {
    /// Represents the type of left bar button on the group channel list module.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of right bar button on the group channel list module.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of title view on the group channel list module.
    /// - Since: 3.28.0
    public static var TitleView: SBUNavigationTitleView.Type = SBUNavigationTitleView.self
}

// MARK: List
extension SBUGroupChannelListModule.List {
    /// Represents the type of empty view on the group channel list module.
    /// - Since: 3.28.0
    public static var EmptyView: SBUEmptyView.Type = SBUEmptyView.self
    
    /// Represents the type of channel cell on the group channel list module.
    /// - Since: 3.28.0
    public static var ChannelCell: SBUBaseChannelCell.Type = SBUGroupChannelCell.self
}

// MARK: Common
extension SBUGroupChannelListModule.Common {
    
    /// Represents the type selector for creating a new channel.
    ///
    /// Example of customization:
    /// ```
    /// SBUModuleSet.GroupChannelList.Common.CreateChannelTypeSelector = CustomTypeSelector.self
    /// ```
    /// - Note: To apply the custom type selector, assign your subclass of ``SBUCreateChannelTypeSelector`` to this property.
    /// - Since: 3.28.0
    public static var CreateChannelTypeSelector: SBUCreateChannelTypeSelector.Type = SBUCreateChannelTypeSelector.self
}

// MARK: typealias
extension SBUModuleSet {
    // Module
    /// The class that represents the list of the group channel module
    /// - Since: 3.28.0
    public typealias GroupChannelList = SBUGroupChannelListModule
    
    // Components
    /// The module component that shows the header in the channel.
    /// - Since: 3.28.0
    public typealias Header = SBUGroupChannelListModule.Header
    
    /// The module component that shows the list of message in the channel.
    /// - Since: 3.28.0
    public typealias List = SBUGroupChannelListModule.List
    
    /// The module component that shows the common view in the channel.
    /// - Since: 3.28.0
    public typealias Common = SBUGroupChannelListModule.Common
}
