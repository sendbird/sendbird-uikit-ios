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
    
    // Private properties
    private static var _currentUser: SBUUser?
}
