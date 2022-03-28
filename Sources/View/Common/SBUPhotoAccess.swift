//
//  SBUPhotoAccess.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2022/03/23.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation
import Photos

/// The level of accessing photo library
@objc(SBUPhotoAccessLevel)
public enum SBUPhotoAccessLevel: Int, Hashable {
    /// Only able to add a new photo to the library
    case addOnly
    /// Get photo from the library as well as add a new photo.
    case readWrite
    
    /// Returns corresponding `PHAccessLevel` value.
    @available(iOS 14, *)
    public var asPHAccessLevel: PHAccessLevel {
        switch self {
        case .addOnly: return .addOnly
        case .readWrite: return .readWrite
        }
    }
}

@objc(SBUPhotoAccessibleStatus)
public enum SBUPhotoAccessibleStatus: Int, Hashable {
    case all
    case limited
    case notDetermined
    case restricted
    case denied
    case none
    
    static func from(_ authorization: PHAuthorizationStatus) -> Self {
        switch authorization {
        case .notDetermined: return .notDetermined
        case .restricted: return .restricted
        case .denied: return .denied
        case .authorized: return .all
        case .limited: return .limited
        default: return .none
        }
    }
}
