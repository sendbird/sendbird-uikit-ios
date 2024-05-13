//
//  SBUOpenChannelSettingsModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the open channel setting module.
open class SBUOpenChannelSettingsModule {
    /// The module component that contains ``SBUBaseChannelSettingsModule/Header/titleView``, ``SBUBaseChannelSettingsModule/Header/leftBarButton``, and ``SBUBaseChannelSettingsModule/Header/rightBarButton``.
    ///
    /// The default function of each button is as below:
    ///   - `title`: Shows the title that uses ``SBUStringSet/ChannelSettings_Header_Title`` in ``SBUStringSet``
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Shows the channel edits menu and uses ``SBUStringSet/Edit`` in ``SBUStringSet`` as its title.
    @available(*, deprecated, message: "Use `SBUOpenChannelSettingsModule.HeaderComponent` instead.")
    public var headerComponent: SBUOpenChannelSettingsModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the list of setting menus in the channel.
    @available(*, deprecated, message: "Use `SBUOpenChannelSettingsModule.ListComponent` instead.")
    public var listComponent: SBUOpenChannelSettingsModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUOpenChannelSettingsModule.Header?
    private var _listComponent: SBUOpenChannelSettingsModule.List?
    
    // MARK: -
    /// Default initializer
    public required init() {}
    
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelSettingsModule`")
    public required init(
        headerComponent: SBUOpenChannelSettingsModule.Header?
    ) {
        self.headerComponent = headerComponent
    }
    
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelSettingsModule`")
    public required init(
        listComponent: SBUOpenChannelSettingsModule.List?
    ) {
        self.listComponent = listComponent
    }
    
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelSettingsModule`")
    public required init(
        headerComponent: SBUOpenChannelSettingsModule.Header?,
        listComponent: SBUOpenChannelSettingsModule.List?
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
