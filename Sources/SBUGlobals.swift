//
//  SBUGlobals.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 27/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

@objcMembers
public class SBUGlobals: NSObject {
    
    // Application Id
    public static var ApplicationId: String?
    
    // Access token
    public static var AccessToken: String?

    // Current User
    public static var CurrentUser: SBUUser?

    // MARK: - Message Grouping
    /// If this value is enabled, messages sent at similar times are grouped.
    /// - Since: 1.2.1
    public static var UsingMessageGrouping: Bool = true
    
    // MARK: - Reply Type
    /// If this value is enabled, replying features are activated.
    /// - Since: 2.2.0
    public static var ReplyTypeToUse: SBUReplyType = .none
    
    // MARK: - User Profile
    /// If this value is enabled, when you click on a user image, the user profile screen is displayed.
    /// - Since: 1.2.2
    public static var UsingUserProfile: Bool = false

    /// If this value is enabled, when you click on a user image in open channel, the user profile screen is displayed.
    /// - Since: 2.0.0
    public static var UsingUserProfileInOpenChannel: Bool = false

    /// if this value is enabled, image compression and resizing will be applied when sending a file message
    /// - Since: 2.0.1
    public static var UsingImageCompression: Bool = false
    
    /// Image compression rate value that will be used when sending image. Default value is 0.85.
    /// Typically this value will be used in `jpegData(compressionQuality:)`
    /// - Since: 2.0.0
    public static var imageCompressionRate: CGFloat = 0.25
    
    /// Image resizing size value that will be used when sending image. Default value is a device screen size.
    /// - Since: 2.0.0
    public static var imageResizingSize: CGSize = UIScreen.main.bounds.size;
    
}
