//
//  SBUBaseChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUBaseChannelModule

/// The class that represents the base of the channel module
open class SBUBaseChannelModule {
    // MARK: Properties (Public)
    /// The module component that contains ``SBUBaseChannelModule/Header/titleView``, ``SBUBaseChannelModule/Header/leftBarButton`` and ``SBUBaseChannelModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUBaseChannelModule.Header.Type = SBUBaseChannelModule.Header.self
    /// The module component that shows the list of message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUBaseChannelModule.List.Type = SBUBaseChannelModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUBaseChannelModule.Input.Type = SBUBaseChannelModule.Input.self
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - The default function of each button is as below:
    ///   - `title`: Shows the channel name
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Shows the channel settings.
    @available(*, deprecated, message: "Use `SBUBaseChannelModule.HeaderComponent.init()` instead.")
    public var headerComponent: SBUBaseChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the channel.
    @available(*, deprecated, message: "Use `SBUBaseChannelModule.ListComponent.init()` instead.")
    public var listComponent: SBUBaseChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    /// The module component that contains `messageInputView`.
    @available(*, deprecated, message: "Use `SBUBaseChannelModule.InputComponent.init()` instead.")
    public var inputComponent: SBUBaseChannelModule.Input? {
        get { _inputComponent ?? Self.InputComponent.init() }
        set { _inputComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUBaseChannelModule.Header?
    private var _listComponent: SBUBaseChannelModule.List?
    private var _inputComponent: SBUBaseChannelModule.Input?
    
    // MARK: -
    @available(*, deprecated, message: "Use `SBUModuleSet.BaseChannelModule`")
    public required init(
        headerComponent: SBUBaseChannelModule.Header? = nil,
        listComponent: SBUBaseChannelModule.List? = nil,
        inputComponent: SBUBaseChannelModule.Input? = nil
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
        self._inputComponent = inputComponent
    }
}
