//
//  SBUGlobals.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 27/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objcMembers
public class SBUGlobals: NSObject {
    
    // Application Id
    public static var ApplicationId: String?
    
    // Access token
    public static var AccessToken: String?

    // Current User
    public static var CurrentUser: SBUUser? {
        set(newCurrentUser){ _currentUser = newCurrentUser }
        get{ return _currentUser }
    }

    
    // MARK: - Message Grouping
    /// If this value is enabled, messages sent at similar times are grouped.
    /// - Since: 1.2.1
    public static var UsingMessageGrouping: Bool = true
    
    
    // MARK: - User Profile
    /// If this value is enabled, when you click on a user image, the user profile screen is displayed.
    /// - Since: 1.2.2
    public static var UsingUserProfile: Bool = false

    
    // MARK: - Private
    private static var _currentUser: SBUUser?
}
