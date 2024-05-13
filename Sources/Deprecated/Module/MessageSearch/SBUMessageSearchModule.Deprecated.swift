//
//  SBUMessageSearchModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the message search module.
open class SBUMessageSearchModule {
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the search bar
    /// - `leftBarButton`: Not set.
    /// - `rightBarButton`: Not set.
    @available(*, deprecated, message: "Use `SBUMessageSearchModule.HeaderComponent` instead.")
    public var headerComponent: SBUMessageSearchModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the list of searched message in the channel.
    @available(*, deprecated, message: "Use `SBUMessageSearchModule.ListComponent` instead.")
    public var listComponent: SBUMessageSearchModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUMessageSearchModule.Header?
    private var _listComponent: SBUMessageSearchModule.List?
    
    // MARK: -
    /// Default initializer
    public required init() {}
    
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.MessageSearchModule")
    public required init(
        headerComponent: SBUMessageSearchModule.Header?
    ) {
        self.headerComponent = headerComponent
    }
    
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.MessageSearchModule")
    public required init(
        listComponent: SBUMessageSearchModule.List?
    ) {
        self.listComponent = listComponent
    }
    
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.MessageSearchModule")
    public required init(
        headerComponent: SBUMessageSearchModule.Header?,
        listComponent: SBUMessageSearchModule.List?
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
