//
//  SBUCreateChannelModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the module for creating a new channel.
open class SBUCreateChannelModule {
    // MARK: Properties (Public)
    
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton``, and ``SBUBaseSelectUserModule/Header/rightBarButton``.
    ///
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses ``SBUStringSet/CreateChannel_Header_Select_Members`` in ``SBUStringSet``
    ///   - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Creates a new channel and uses  ``SBUStringSet/CreateChannel_Create`` in ``SBUStringSet`` as its title.
    @available(*, deprecated, message: "Use `SBUCreateChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUCreateChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the list of users to create a new channel.
    @available(*, deprecated, message: "Use `SBUCreateChannelModule.ListComponent` instead.")
    public var listComponent: SBUCreateChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUCreateChannelModule.Header?
    private var _listComponent: SBUCreateChannelModule.List?
    
    // swiftlint:disable missing_docs
    // MARK: -
    /// Default initializer
    public required init() {}
    
    @available(*, deprecated, message: "Use `SBUModuleSet.CreateGroupChannelModule`")
    public required init(
        headerComponent: SBUCreateChannelModule.Header?
    ) {
        self.headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.CreateGroupChannelModule`")
    public required init(
        listComponent: SBUCreateChannelModule.List?
    ) {
        self.listComponent = listComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.CreateGroupChannelModule`")
    public required init(
        headerComponent: SBUCreateChannelModule.Header?,
        listComponent: SBUCreateChannelModule.List?
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
    // swiftlint:enable missing_docs
}
