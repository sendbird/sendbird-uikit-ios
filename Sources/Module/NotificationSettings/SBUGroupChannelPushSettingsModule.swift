//
//  SBUGroupChannelPushSettingsModule.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUGroupChannelPushSettingsModule {
    // MARK: Properties (Public)
    
    public var headerComponent: SBUGroupChannelPushSettingsModule.Header? {
        get { _headerComponent ?? SBUGroupChannelPushSettingsModule.Header() }
        set { _headerComponent = newValue }
    }
    
    public var listComponent: SBUGroupChannelPushSettingsModule.List? {
        get { _listComponent ?? SBUGroupChannelPushSettingsModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Private)
    private var _headerComponent: SBUGroupChannelPushSettingsModule.Header?
    private var _listComponent: SBUGroupChannelPushSettingsModule.List?
    
    public init(
        headerComponent: SBUGroupChannelPushSettingsModule.Header? = nil,
        listComponent: SBUGroupChannelPushSettingsModule.List? = nil
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
