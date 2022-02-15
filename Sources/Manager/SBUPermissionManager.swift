//
//  SBUPermissionManager.swift
//  SendBirdUIKit
//
//  Created by Wooyoung Chung on 12/15/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

class SBUPermissionManager {
    static let shared = SBUPermissionManager()
    private init() {}
    
    func requestPhotoAccessIfNeeded(completion: @escaping (Bool) -> ()) {
        var granted: PHAuthorizationStatus
        if #available(iOS 14, *) {
            granted = PHPhotoLibrary.authorizationStatus(for: SBUGlobals.photoLibraryAccessLevel)
        } else {
            granted = PHPhotoLibrary.authorizationStatus()
        }
        switch granted {
            case .authorized, .limited:
                completion(true)
            default:
                PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
                    DispatchQueue.main.async {
                        var isAccessible: Bool
                        
                        if #available(iOS 14, *) {
                            isAccessible = status == .authorized || status == .limited
                        } else {
                            isAccessible = status == .authorized
                        }
                        completion(isAccessible)
                    }
                    
                }
        }
    }
    
    func requestDeviceAccessIfNeeded(for type: AVMediaType, completion: @escaping (Bool) -> ()) {
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
