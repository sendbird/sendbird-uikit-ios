//
//  UserDefaults+Ext.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UserDefaults {
    static func loadUserID() -> String? {
        return UserDefaults.standard.string(forKey: "user_id")
    }
    static func saveUserID(_ userID: String) {
        UserDefaults.standard.set(userID, forKey: "user_id")
    }
    
    static func loadNickname() -> String? {
        return UserDefaults.standard.string(forKey: "nickname")
    }
    static func saveNickname(_ nickname: String) {
        UserDefaults.standard.set(nickname, forKey: "nickname")
    }
    
    static func loadIsLightTheme() -> Bool {
        return UserDefaults.standard.bool(forKey: "is_light_theme")
    }
    static func saveIsLightTheme(_ isLight: Bool) {
        UserDefaults.standard.set(isLight, forKey: "is_light_theme")
    }
}
