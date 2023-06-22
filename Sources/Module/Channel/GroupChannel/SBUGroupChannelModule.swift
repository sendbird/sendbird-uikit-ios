//
//  SBUGroupChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUGroupChannelModule

/// The class that represents the group channel module
open class SBUGroupChannelModule {
    /// The module component that contains ``SBUBaseChannelModule/Header/titleView``, ``SBUBaseChannelModule/Header/leftBarButton``, and ``SBUBaseChannelModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelModule.Header.Type = SBUGroupChannelModule.Header.self
    /// The module component that shows the list of message in the group channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelModule.List.Type = SBUGroupChannelModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUGroupChannelModule.Input.Type = SBUGroupChannelModule.Input.self
    
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - NOTE: The default function of each button is as below:
    ///     - `title`: Shows the group channel name
    ///     - `leftBarButton`: Goes back to the previous view.
    ///     - `rightBarButton`: Shows the group channel settings.
    @available(*, deprecated, message: "Use `SBUGroupChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUGroupChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the group channel.
    @available(*, deprecated, message: "Use `SBUGroupChannelModule.ListComponent` instead.")
    public var listComponent: SBUGroupChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    /// The module component that contains `messageInputView`.
    @available(*, deprecated, message: "Use `SBUGroupChannelModule.InputComponent` instead.")
    public var inputComponent: SBUGroupChannelModule.Input? {
        get { _inputComponent ?? Self.InputComponent.init() }
        set { _inputComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUGroupChannelModule.Header?
    private var _listComponent: SBUGroupChannelModule.List?
    private var _inputComponent: SBUGroupChannelModule.Input?
    
    // MARK: -
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupChannelModule`")
    public required init(
        headerComponent: SBUGroupChannelModule.Header? = nil,
        listComponent: SBUGroupChannelModule.List? = nil,
        inputComponent: SBUGroupChannelModule.Input? = nil
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
        self._inputComponent = inputComponent
    }
}
