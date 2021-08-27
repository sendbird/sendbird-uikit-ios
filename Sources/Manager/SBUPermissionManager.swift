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
    
//    @available(iOS 14, *)
//    func requestPhotoAccessIfNeeded(level: PHAccessLevel, completion: @escaping (Bool) -> ()) {
//        let granted = PHPhotoLibrary.authorizationStatus(for: level)
//        if (granted != .authorized) {
//            PHPhotoLibrary.requestAuthorization(for: level) { (status: PHAuthorizationStatus) -> Void in
//                completion(status != .authorized)
//            }
//        } else {
//            completion(true)
//        }
//    }
    
    func requestPhotoAccessIfNeeded(completion: @escaping (Bool) -> ()) {
        let granted = PHPhotoLibrary.authorizationStatus()
        if (granted != .authorized) {
            PHPhotoLibrary.requestAuthorization { (status: PHAuthorizationStatus) -> Void in
                DispatchQueue.main.async {
                    completion(status == .authorized)
                }
                
            }
        } else {
            completion(true)
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
