//
//  SBUPermissionManager.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 12/15/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

public class SBUPermissionManager {
    public static let shared = SBUPermissionManager()
    
    public var currentStatus: SBUPhotoAccessibleStatus {
        var granted: PHAuthorizationStatus
        if #available(iOS 14, *) {
            granted = PHPhotoLibrary.authorizationStatus(
                for: SBUGlobals.photoLibraryAccessLevel.asPHAccessLevel
            )
        } else {
            granted = PHPhotoLibrary.authorizationStatus()
        }
        return SBUPhotoAccessibleStatus.from(granted)
    }
    
    private init() {}
    
    public func requestPhotoAccessIfNeeded(completion: @escaping (SBUPhotoAccessibleStatus) -> Void) {
        // authorizationStatus
        var granted: PHAuthorizationStatus
        if #available(iOS 14, *) {
            granted = PHPhotoLibrary.authorizationStatus(
                for: SBUGlobals.photoLibraryAccessLevel.asPHAccessLevel
            )
        } else {
            granted = PHPhotoLibrary.authorizationStatus()
        }
        
        
        switch granted {
        case .authorized:
            DispatchQueue.main.async {
                completion(.all)
            }
        default:
            // request authorization when not authorized
            let handler: (PHAuthorizationStatus) -> Void = { status in
                DispatchQueue.main.async {
                    let accessibleStatus = SBUPhotoAccessibleStatus.from(status)
                    completion(accessibleStatus)
                }
            }
            
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(
                    for: SBUGlobals.photoLibraryAccessLevel.asPHAccessLevel,
                    handler: handler
                )
            } else {
                PHPhotoLibrary.requestAuthorization(handler)
            }
        }
    }
    
    public func requestDeviceAccessIfNeeded(for type: AVMediaType, completion: @escaping (Bool) -> ()) {
        let granted = AVCaptureDevice.authorizationStatus(for: type)
        if (granted != .authorized) {
            AVCaptureDevice.requestAccess(for: type) { success in
                DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            completion(true)
        }
    }
}
