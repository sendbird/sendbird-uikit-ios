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
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the channel name. It uses ``SBUMessageThreadTitleView`` as a default.
    /// - `leftBarButton`: Not set.
    /// - `rightBarButton`: Not set.
    public var headerComponent: SBUMessageThreadModule.Header? {
        get { _headerComponent ?? SBUMessageThreadModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of thread message in the channel.
    public var listComponent: SBUMessageThreadModule.List? {
        get { _listComponent ?? SBUMessageThreadModule.List() }
        set { _listComponent = newValue }
    }
    
    
    /// The module component that contains `messageInputView`.
    public var inputComponent: (SBUMessageThreadModule.Input)? {
        get { _inputComponent ?? SBUMessageThreadModule.Input() }
        set { _inputComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUMessageThreadModule.Header?
    private var _listComponent: SBUMessageThreadModule.List?
    private var _inputComponent: (SBUMessageThreadModule.Input)?
    
    
    // MARK: -
    
    /// Initializes module with components.
    public init(headerComponent: SBUMessageThreadModule.Header? = nil,
                listComponent: SBUMessageThreadModule.List? = nil,
                inputComponent: (SBUMessageThreadModule.Input)? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
        self.inputComponent = inputComponent
    }
}
