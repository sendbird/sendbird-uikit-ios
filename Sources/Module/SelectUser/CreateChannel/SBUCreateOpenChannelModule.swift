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
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses `SBUStringSet.CreateOpenChannel_Header_Title`
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Creates a new channel and uses `SBUStringSet.CreateOpenChannel_Create` as its title.
    public var headerComponent: SBUCreateOpenChannelModule.Header? {
        get { _headerComponent ?? SBUCreateOpenChannelModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the body to create a new channel.
    public var profileInputComponent: SBUCreateOpenChannelModule.ProfileInput? {
        get { _profileInputComponent ?? SBUCreateOpenChannelModule.ProfileInput() }
        set { _profileInputComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUCreateOpenChannelModule.Header?
    private var _profileInputComponent: SBUCreateOpenChannelModule.ProfileInput?
    
    
    // MARK: -
    public init(headerComponent: SBUCreateOpenChannelModule.Header? = nil,
                profileInputComponent: SBUCreateOpenChannelModule.ProfileInput? = nil) {
        self.headerComponent = headerComponent
        self.profileInputComponent = profileInputComponent
    }

}
