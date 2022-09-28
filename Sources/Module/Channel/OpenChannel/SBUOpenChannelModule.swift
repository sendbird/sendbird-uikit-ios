//
//  SBUOpenChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUOpenChannelModule

/// The class that represents the open channel module
open class SBUOpenChannelModule {
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - NOTE: The default function of each button is as below:
    ///     - `title`: Shows the channel name
    ///     - `leftBarButton`: Goes back to the previous view.
    ///     - `rightBarButton`: Shows the channel settings or the list of participants.
    public var headerComponent: SBUOpenChannelModule.Header? {
        get { _headerComponent ?? SBUOpenChannelModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the open channel.
    public var listComponent: SBUOpenChannelModule.List? {
        get { _listComponent ?? SBUOpenChannelModule.List() }
        set { _listComponent = newValue }
    }
    
    /// The module component that contains `messageInputView`.
    public var inputComponent: SBUOpenChannelModule.Input? {
        get { _inputComponent ?? SBUOpenChannelModule.Input() }
        set { _inputComponent = newValue }
    }
    
    /// The module component that represents the media in the open channel such as photo or video.
    public var mediaComponent: SBUOpenChannelModule.Media? {
        get { _mediaComponent ?? SBUOpenChannelModule.Media() }
        set { _mediaComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUOpenChannelModule.Header?
    private var _listComponent: SBUOpenChannelModule.List?
    private var _inputComponent: SBUOpenChannelModule.Input?
    private var _mediaComponent: SBUOpenChannelModule.Media?
    
    
    // MARK: -
    public init(
        headerComponent: SBUOpenChannelModule.Header? = nil,
        listComponent: SBUOpenChannelModule.List? = nil,
        inputComponent: SBUOpenChannelModule.Input? = nil,
        mediaComponent: SBUOpenChannelModule.Media? = nil
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
        self.inputComponent = inputComponent
        self.mediaComponent = mediaComponent
    }
}

