//
//  SBUBaseChannelModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the base of the channel module
open class SBUBaseChannelModule {
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - The default function of each button is as below:
    ///   - `title`: Shows the channel name
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Shows the channel settings.
    @available(*, deprecated, message: "Use `SBUBaseChannelModule.HeaderComponent.init()` instead.")
    public var headerComponent: SBUBaseChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the list of message in the channel.
    @available(*, deprecated, message: "Use `SBUBaseChannelModule.ListComponent.init()` instead.")
    public var listComponent: SBUBaseChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that contains `messageInputView`.
    @available(*, deprecated, message: "Use `SBUBaseChannelModule.InputComponent.init()` instead.")
    public var inputComponent: SBUBaseChannelModule.Input? {
        get { _inputComponent ?? Self.InputComponent.init() }
        set {
            _inputComponent = newValue
            if let validNewValue = newValue {
                Self.InputComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUBaseChannelModule.Header?
    private var _listComponent: SBUBaseChannelModule.List?
    private var _inputComponent: SBUBaseChannelModule.Input?
    
    // MARK: -
    /// Default initializer
    public required init() {}
    
    // swiftlint:disable missing_docs
    @available(*, deprecated, message: "Use `SBUModuleSet.BaseChannelModule`")
    public required init(
        headerComponent: SBUBaseChannelModule.Header?
    ) {
        self._headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.BaseChannelModule`")
    public required init(
        listComponent: SBUBaseChannelModule.List?
    ) {
        self._listComponent = listComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.BaseChannelModule`")
    public required init(
        inputComponent: SBUBaseChannelModule.Input?
    ) {
        self._inputComponent = inputComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.BaseChannelModule`")
    public required init(
        headerComponent: SBUBaseChannelModule.Header?,
        listComponent: SBUBaseChannelModule.List?,
        inputComponent: SBUBaseChannelModule.Input?
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
        self._inputComponent = inputComponent
    }
    // swiftlint:enable missing_docs
}

