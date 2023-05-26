//
//  SBUPermissionManager.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 12/15/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public class SBUPermissionManager {
    /// The enumeration tha represents the permissions supported by Sendbird UIKit
    public enum PermissionType {
        case camera
        case photoLibrary
        case record
    }
    public static let shared = SBUPermissionManager()
        
    /// ``SBUPhotoAccessibleStatus`` value that indicaates the current status of photo library acess.
    /// - Since: 3.4.0
    public var currentPhotoAccessStatus: SBUPhotoAccessibleStatus {
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
    
    /// `AVAuthorizationStatus` value that indicaates the current status of camera acess.
    /// - Since: 3.4.0
    public var currentCameraAccessStatus: AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    /// `AVAudioSession.RecordPermission` value that indicaates the current status of record permission.
    /// - Since: 3.4.0
    public var currentRecordAccessStatus: AVAudioSession.RecordPermission {
        AVAudioSession.sharedInstance().recordPermission
    }
    
    private init() {}
    
    /// Present alert to ask for permission.
    /// - Parameters:
    ///    - permissionType: ``SBUPermissionManager/PermissionType`` value..
    ///    - alertViewDelegate: The object that conforms to ``SBUAlertViewDelegate``..
    ///    - onDismiss: Called when the alert is dismissed. Refer to ``AlertButtonHandler``.
    /// - Since: 3.4.0
    public func showPermissionAlert(forType permissionType: SBUPermissionManager.PermissionType, alertViewDelegate: SBUAlertViewDelegate? = nil, onDismiss: AlertButtonHandler? = nil) {
        let settingButton = SBUAlertButtonItem(title: SBUStringSet.Settings) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
        
        let cancelButton: SBUAlertButtonItem
        let title: String
        let message: String?
        
        switch permissionType {
        case .camera:
            cancelButton = SBUAlertButtonItem(
                title: SBUStringSet.Cancel,
                completionHandler: { onDismiss?($0) }
            )
            title = SBUStringSet.Alert_Allow_Camera_Access
            message = nil
        case .photoLibrary:
            cancelButton = SBUAlertButtonItem(
                title: SBUStringSet.Cancel,
                completionHandler: { onDismiss?($0) }
            )
            title = SBUStringSet.Alert_Allow_PhotoLibrary_Access
            message = SBUStringSet.Alert_Allow_PhotoLibrary_Access_Message
        case .record:
            cancelButton = SBUAlertButtonItem(
                title: SBUStringSet.Cancel,
                completionHandler: { onDismiss?($0) }
            )
            title = SBUStringSet.Alert_Allow_Microphone_Access
            message = nil
        }
        
        DispatchQueue.main.async { [title, message, cancelButton, alertViewDelegate] in
            SBUAlertView.show(
                title: title,
                message: message,
                oneTimetheme: SBUTheme.componentTheme,
                confirmButtonItem: settingButton,
                cancelButtonItem: cancelButton,
                delegate: alertViewDelegate
            )
        }
    }
    
    /// Checks audio record permission. When you call this method, if the user previously granted or denied recording permission, the block executes *immediately* without displaying a recording permission alert.
    /// - Note: The blocks executes in the *main* thread.
    /// - Parameters:
    ///    - onGranted: Called when the user granted.
    ///    - onDenied: Called when the user did not grant.
    /// - Since: 3.4.0
    public func requestRecordAcess(
        onGranted: (() -> Void)? = nil,
        onDenied: (() -> Void)? = nil
    ) {
        if self.currentRecordAccessStatus == .granted {
            if Thread.isMainThread {
                onGranted?()
            } else {
                DispatchQueue.main.async {
                    onGranted?()
                }
            }
            return
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    onGranted?()
                }
            } else {
                DispatchQueue.main.async {
                    onDenied?()
                }
            }
        }
    }
    
    /// Checks photo library permission. When you call this method, if the user previously granted or denied photo library usage permission, the block executes *immediately* without displaying a photo library permission alert.
    /// - Note: The blocks executes in the *main* thread.
    /// - Since: 3.4.0
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
    
    /// Checks camera permission. When you call this method, if the user previously granted or denied camera usage permission, the block executes *immediately* without displaying a camera permission alert.
    /// - Note: The blocks executes in the *main* thread.
    /// - Parameters:
    ///    - onGranted: Called when the user granted.
    ///    - onDenied: Called when the user did not grant.
    /// - Since: 3.4.0
    public func requestCameraAccess(
        for type: AVMediaType,
        onGranted: (() -> Void)? = nil,
        onDenied: (() -> Void)? = nil
    ) {
        let granted = self.currentCameraAccessStatus
        switch granted {
        case .authorized:
            if Thread.isMainThread {
                onGranted?()
            } else {
                DispatchQueue.main.async {
                    onGranted?()
                }
            }
        default:
            AVCaptureDevice.requestAccess(for: type) { success in
                DispatchQueue.main.async {
                    if success {
                        onGranted?()
                    } else {
                        onDenied?()
                    }
                }
            }
        }
    }
}

extension SBUPermissionManager {
    
    @available(*, deprecated, renamed: "currentPhotoAccessStatus")
    public var currentStatus: SBUPhotoAccessibleStatus {
        currentPhotoAccessStatus
    }
    
    @available(*, deprecated, renamed: "requestCameraAccessIfNeeded(for:onGranted:onDenied:)")
    public func requestDeviceAccessIfNeeded(for type: AVMediaType, completion: @escaping (Bool) -> Void) {
        self.requestCameraAccess(for: type) {
            completion(true)
        } onDenied: {
            completion(false)
        }
    }
    
}
