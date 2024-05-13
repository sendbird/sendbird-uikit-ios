//
//  SBUCreateOpenChannelModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the module for creating a new open channel.
open class SBUCreateOpenChannelModule {
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
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the body to create a new channel.
    @available(*, deprecated, message: "Use `SBUCreateOpenChannelModule.ProfileInputComponent` instead.")
    public var profileInputComponent: SBUCreateOpenChannelModule.ProfileInput? {
        get { _profileInputComponent ?? Self.ProfileInputComponent.init() }
        set {
            _profileInputComponent = newValue
            if let validNewValue = newValue {
                Self.ProfileInputComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUCreateOpenChannelModule.Header?
    private var _profileInputComponent: SBUCreateOpenChannelModule.ProfileInput?
    
    // swiftlint:disable missing_docs
    // MARK: -
    /// Default initializer
    public required init() {}
    
    @available(*, deprecated, message: "Use `SBUModuleSet.CreateOpenChannelModule`")
    public required init(
        headerComponent: SBUCreateOpenChannelModule.Header?
    ) {
        self.headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.CreateOpenChannelModule`")
    public required init(
        profileInputComponent: SBUCreateOpenChannelModule.ProfileInput?
    ) {
        self.profileInputComponent = profileInputComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.CreateOpenChannelModule`")
    public required init(
        headerComponent: SBUCreateOpenChannelModule.Header?,
        profileInputComponent: SBUCreateOpenChannelModule.ProfileInput?
    ) {
        self.headerComponent = headerComponent
        self.profileInputComponent = profileInputComponent
    }
    // swiftlint:enable missing_docs

}
