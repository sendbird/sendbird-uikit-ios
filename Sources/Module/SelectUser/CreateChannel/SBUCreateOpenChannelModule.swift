//
//  SBUCreateOpenChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/24.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUCreateOpenChannelModul

/// The class that represents the module for creating a new open channel.
open class SBUCreateOpenChannelModule {
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton``, and ``SBUBaseSelectUserModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUCreateOpenChannelModule.Header.Type = SBUCreateOpenChannelModule.Header.self
    /// The module component that shows the body to create a new channel.
    /// - Since: 3.6.0
    public static var ProfileInputComponent: SBUCreateOpenChannelModule.ProfileInput.Type = SBUCreateOpenChannelModule.ProfileInput.self
    
    // MARK: Properties (Public)
    
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton``, and ``SBUBaseSelectUserModule/Header/rightBarButton``.
    ///
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses ``SBUStringSet/CreateOpenChannel_Header_Title`` in ``SBUStringSet``
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Creates a new channel and uses ``SBUStringSet/CreateOpenChannel_Create`` in ``SBUStringSet`` as its title.
    @available(*, deprecated, message: "Use `SBUCreateOpenChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUCreateOpenChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the body to create a new channel.
    @available(*, deprecated, message: "Use `SBUCreateOpenChannelModule.ProfileInputComponent` instead.")
    public var profileInputComponent: SBUCreateOpenChannelModule.ProfileInput? {
        get { _profileInputComponent ?? Self.ProfileInputComponent.init() }
        set { _profileInputComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUCreateOpenChannelModule.Header?
    private var _profileInputComponent: SBUCreateOpenChannelModule.ProfileInput?
    
    // MARK: -
    @available(*, deprecated, message: "Use `SBUModuleSet.CreateOpenChannelModule`")
    public required init(headerComponent: SBUCreateOpenChannelModule.Header? = nil,
                profileInputComponent: SBUCreateOpenChannelModule.ProfileInput? = nil) {
        self.headerComponent = headerComponent
        self.profileInputComponent = profileInputComponent
    }

}
