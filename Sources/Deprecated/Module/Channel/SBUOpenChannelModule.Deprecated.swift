//
//  SBUOpenChannelModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the open channel module
open class SBUOpenChannelModule {
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - NOTE: The default function of each button is as below:
    ///     - `title`: Shows the channel name
    ///     - `leftBarButton`: Goes back to the previous view.
    ///     - `rightBarButton`: Shows the channel settings or the list of participants.
    @available(*, deprecated, message: "Use `SBUOpenChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUOpenChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the list of message in the open channel.
    @available(*, deprecated, message: "Use `SBUOpenChannelModule.ListComponent` instead.")
    public var listComponent: SBUOpenChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that contains `messageInputView`.
    @available(*, deprecated, message: "Use `SBUOpenChannelModule.InputComponent` instead.")
    public var inputComponent: SBUOpenChannelModule.Input? {
        get { _inputComponent ?? Self.InputComponent.init() }
        set {
            _inputComponent = newValue
            if let validNewValue = newValue {
                Self.InputComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that represents the media in the open channel such as photo or video.
    @available(*, deprecated, message: "Use `SBUOpenChannelModule.MediaComponent` instead.")
    public var mediaComponent: SBUOpenChannelModule.Media? {
        get { _mediaComponent ?? Self.MediaComponent.init() }
        set {
            _mediaComponent = newValue
            if let validNewValue = newValue {
                Self.MediaComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUOpenChannelModule.Header?
    private var _listComponent: SBUOpenChannelModule.List?
    private var _inputComponent: SBUOpenChannelModule.Input?
    private var _mediaComponent: SBUOpenChannelModule.Media?
    
    // MARK: -
    /// Default initializer
    public required init() {}
    
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelModule`")
    public required init(
        headerComponent: SBUOpenChannelModule.Header?
    ) {
        self._headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelModule`")
    public required init(
        listComponent: SBUOpenChannelModule.List?
    ) {
        self._listComponent = listComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelModule`")
    public required init(
        inputComponent: SBUOpenChannelModule.Input?
    ) {
        self._inputComponent = inputComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelModule`")
    public required init(
        mediaComponent: SBUOpenChannelModule.Media?
    ) {
        self._mediaComponent = mediaComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelModule`")
    public required init(
        headerComponent: SBUOpenChannelModule.Header?,
        listComponent: SBUOpenChannelModule.List?,
        inputComponent: SBUOpenChannelModule.Input?,
        mediaComponent: SBUOpenChannelModule.Media?
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
        self._inputComponent = inputComponent
        self._mediaComponent = mediaComponent
    }
    // swiftlint:enable missing_docs
}
