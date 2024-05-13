//
//  SBUOpenChannelListModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the list of the open channel module
open class SBUOpenChannelListModule {
    /// The module component that contains ``SBUBaseChannelListModule/Header/titleView``, ``SBUBaseChannelListModule/Header/leftBarButton``, and ``SBUBaseChannelListModule/Header/rightBarButton``.
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses ``SBUStringSet/ChannelList_Header_Title`` in ``SBUStringSet``
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Shows a view controller creating a new open channel.
    @available(*, deprecated, message: "Use `SBUOpenChannelListModule.HeaderComponent` instead.")
    public var headerComponent: SBUOpenChannelListModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the list of message in the channel.
    @available(*, deprecated, message: "Use `SBUOpenChannelListModule.ListComponent` instead.")
    public var listComponent: SBUOpenChannelListModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
                    
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUOpenChannelListModule.Header?
    private var _listComponent: SBUOpenChannelListModule.List?
    
    // MARK: -
    /// Default initializer for `SBUOpenChannelListModule`.
    ///
    /// This initializer creates an instance of `SBUOpenChannelListModule` without any pre-configured components.
    public required init() {}
    
    // swiftlint:disable missing_docs
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelListModule`")
    public required init(
        headerComponent: SBUOpenChannelListModule.Header?
    ) {
        self._headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelListModule`")
    public required init(
        listComponent: SBUOpenChannelListModule.List?
    ) {
        self._listComponent = listComponent
    }

    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelListModule`")
    public required init(
        headerComponent: SBUOpenChannelListModule.Header?,
        listComponent: SBUOpenChannelListModule.List?
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
    }
    // swiftlint:enable missing_docs
}
