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
    // MARK: - Public
    
    // Application Id
    public static var ApplicationId: String?
    
    // Access token
    public static var AccessToken: String?

    // Current User
    public static var CurrentUser: SBUUser? {
        set(newCurrentUser){ _currentUser = newCurrentUser }
        get{ return _currentUser }
    }
    
    public static var UsingMessageGrouping: Bool = true
    
    
    // MARK: - Private
    private static var _currentUser: SBUUser?
}
