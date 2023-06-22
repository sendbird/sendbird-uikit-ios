//
//  SBUMessageThreadModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/01.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUMessageThreadModule

/// The class that represents the message thread module.
open class SBUMessageThreadModule {
    // MARK: Properties (Public)
    /// The module component that contains ``SBUBaseChannelModule/Header/title``, ``SBUBaseChannelModule/Header/leftBarButton``, and ``SBUBaseChannelModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUMessageThreadModule.Header.Type = SBUMessageThreadModule.Header.self
    /// The module component that shows the list of thread message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUMessageThreadModule.List.Type = SBUMessageThreadModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUMessageThreadModule.Input.Type = SBUMessageThreadModule.Input.self
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the channel name. It uses ``SBUMessageThreadTitleView`` as a default.
    /// - `leftBarButton`: Not set.
    /// - `rightBarButton`: Not set.
    @available(*, deprecated, message: "Use `SBUMessageThreadModule.HeaderComponent` instead.")
    public var headerComponent: SBUMessageThreadModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of thread message in the channel.
    @available(*, deprecated, message: "Use `SBUMessageThreadModule.ListComponent` instead.")
    public var listComponent: SBUMessageThreadModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    /// The module component that contains `messageInputView`.
    @available(*, deprecated, message: "Use `SBUMessageThreadModule.InputComponent` instead.")
    public var inputComponent: (SBUMessageThreadModule.Input)? {
        get { _inputComponent ?? Self.InputComponent.init() }
        set { _inputComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUMessageThreadModule.Header?
    private var _listComponent: SBUMessageThreadModule.List?
    private var _inputComponent: (SBUMessageThreadModule.Input)?
    
    // MARK: -
    
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.MessageThreadModule")
    public required init(headerComponent: SBUMessageThreadModule.Header? = nil,
                listComponent: SBUMessageThreadModule.List? = nil,
                inputComponent: (SBUMessageThreadModule.Input)? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
        self.inputComponent = inputComponent
    }
}
