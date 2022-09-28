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
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - The default function of each button is as below:
    ///   - `title`: Shows the channel name
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Shows the channel settings.
    public var headerComponent: SBUBaseChannelModule.Header? {
        get { _headerComponent ?? SBUBaseChannelModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the channel.
    public var listComponent: SBUBaseChannelModule.List? {
        get { _listComponent ?? SBUBaseChannelModule.List() }
        set { _listComponent = newValue }
    }
    
    /// The module component that contains `messageInputView`.
    public var inputComponent: SBUBaseChannelModule.Input? {
        get { _inputComponent ?? SBUBaseChannelModule.Input() }
        set { _inputComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUBaseChannelModule.Header?
    private var _listComponent: SBUBaseChannelModule.List?
    private var _inputComponent: SBUBaseChannelModule.Input?
    
    
    // MARK: -
    public init(
        headerComponent: SBUBaseChannelModule.Header? = nil,
        listComponent: SBUBaseChannelModule.List? = nil,
        inputComponent: SBUBaseChannelModule.Input? = nil
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
        self.inputComponent = inputComponent
    }
}
