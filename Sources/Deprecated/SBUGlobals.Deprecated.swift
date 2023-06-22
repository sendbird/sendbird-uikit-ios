//
//  SBUGlobals.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/02/16.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUGlobals {
    // Application Id
    @available(*, deprecated, renamed: "applicationId") // 3.0.0
    public static var ApplicationId: String? {
        get { SBUGlobals.applicationId }
        set { SBUGlobals.applicationId = newValue }
    }
    
    // Access token
    @available(*, deprecated, renamed: "accessToken")   // 3.0.0
    public static var AccessToken: String? {
        get { SBUGlobals.accessToken }
        set { SBUGlobals.accessToken = newValue }
    }

    // Current User
    @available(*, deprecated, renamed: "currentUser")   // 3.0.0
    public static var CurrentUser: SBUUser? {
        get { SBUGlobals.currentUser }
        set { SBUGlobals.currentUser = newValue }
    }
    
    @available(*, deprecated, renamed: "isMessageGroupingEnabled")   // 3.0.0
    public static var UsingMessageGrouping: Bool {
        get { SBUGlobals.isMessageGroupingEnabled }
        set { SBUGlobals.isMessageGroupingEnabled = newValue }
    }
    
    @available(*, deprecated, renamed: "replyType")   // 3.0.0
    public static var ReplyTypeToUse: SBUReplyType {
        get { SBUGlobals.replyType }
        set { SBUGlobals.replyType = newValue }
    }
    
    @available(*, deprecated, renamed: "SendbirdUI.config.groupChannel.channel.replyType")   // 3.3.0
    public static var replyType: SBUReplyType {
        get { SendbirdUI.config.groupChannel.channel.replyType }
        set { SendbirdUI.config.groupChannel.channel.replyType = newValue }
    }
    
    @available(*, deprecated, renamed: "isPHPickerEnabled")   // 3.0.0
    public static var UsingPHPicker: Bool {
        get {
            if #available(iOS 14, *) {
                return SBUGlobals.isPHPickerEnabled
            } else {
                return false
            }
        }
        set {
            if #available(iOS 14, *) {
                SBUGlobals.isPHPickerEnabled = newValue
            }
        }
    }
    
    @available(*, deprecated, renamed: "SendbirdUI.config.common.isUsingDefaultUserProfileEnabled")   // 3.0.0
    public static var UsingUserProfile: Bool {
        get { SendbirdUI.config.common.isUsingDefaultUserProfileEnabled }
        set { SendbirdUI.config.common.isUsingDefaultUserProfileEnabled = newValue }
    }
    
    @available(*, deprecated, renamed: "SendbirdUI.config.common.isUsingDefaultUserProfileEnabled")   // 3.0.0
    public static var UsingUserProfileInOpenChannel: Bool {
        get { SendbirdUI.config.common.isUsingDefaultUserProfileEnabled }
        set { SendbirdUI.config.common.isUsingDefaultUserProfileEnabled = newValue }
    }
    
    @available(*, deprecated, renamed: "isImageCompressionEnabled")   // 3.0.0
    public static var UsingImageCompression: Bool {
        get { SBUGlobals.isImageCompressionEnabled }
        set { SBUGlobals.isImageCompressionEnabled = newValue }
    }
}
