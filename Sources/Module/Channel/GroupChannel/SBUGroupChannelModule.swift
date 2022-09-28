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
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - NOTE: The default function of each button is as below:
    ///     - `title`: Shows the group channel name
    ///     - `leftBarButton`: Goes back to the previous view.
    ///     - `rightBarButton`: Shows the group channel settings.
    public var headerComponent: (SBUGroupChannelModule.Header)? {
        get { _headerComponent ?? SBUGroupChannelModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the group channel.
    public var listComponent: (SBUGroupChannelModule.List)? {
        get { _listComponent ?? SBUGroupChannelModule.List() }
        set { _listComponent = newValue }
    }
    
    /// The module component that contains `messageInputView`.
    public var inputComponent: (SBUGroupChannelModule.Input)? {
        get { _inputComponent ?? SBUGroupChannelModule.Input() }
        set { _inputComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: (SBUGroupChannelModule.Header)?
    private var _listComponent: (SBUGroupChannelModule.List)?
    private var _inputComponent: (SBUGroupChannelModule.Input)?
    
    // MARK: -
    public init(
        headerComponent: (SBUGroupChannelModule.Header)? = nil,
        listComponent: (SBUGroupChannelModule.List)? = nil,
        inputComponent: (SBUGroupChannelModule.Input)? = nil
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
        self.inputComponent = inputComponent
    }
}

