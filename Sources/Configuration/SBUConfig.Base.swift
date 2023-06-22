//
//  SBUConfig.Base.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/06/02.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: - SBUConfig.BaseInput
extension SBUConfig {
    public class BaseInput: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// Use the menu to load files (such as pdf, mp3, etc.) for sending fileMessage.
        @SBUPrioritizedConfig public var isDocumentEnabled: Bool = true
        
        /// Camera configuration set of Input
        public var camera: Camera = Camera()
        
        /// Gallery configuration set of Input
        public var gallery: Gallery = Gallery()

        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ input: BaseInput) {
            self._isDocumentEnabled.setDashboardValue(input.isDocumentEnabled)
            
            self.camera.updateWithDashboardData(input.camera)
            self.gallery.updateWithDashboardData(input.gallery)
        }
    }
}

// MARK: - SBUConfig.BaseInput.Camera
extension SBUConfig.BaseInput {
    public class Camera: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// Use the camera menu to shoot Image for sending file message
        @SBUPrioritizedConfig public var isPhotoEnabled: Bool = true
        
        /// Use the video menu to shoot Image for sending file message
        @SBUPrioritizedConfig public var isVideoEnabled: Bool = true
        
        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ camera: Camera) {
            self._isPhotoEnabled.setDashboardValue(camera.isPhotoEnabled)
            self._isVideoEnabled.setDashboardValue(camera.isVideoEnabled)
        }
    }
}

// MARK: - SBUConfig.BaseInput.Gallery
extension SBUConfig.BaseInput {
    public class Gallery: NSObject, Codable, SBUUpdatableConfigProtocol {
        // MARK: Property
        
        /// Use the gallery option to select Image for sending file message
        @SBUPrioritizedConfig public var isPhotoEnabled: Bool = true
        
        /// Use the gallery option to select video for sending file message
        @SBUPrioritizedConfig public var isVideoEnabled: Bool = true
        
        // MARK: Logic
        override init() {}
        
        func updateWithDashboardData(_ gallery: Gallery) {
            self._isPhotoEnabled.setDashboardValue(gallery.isPhotoEnabled)
            self._isVideoEnabled.setDashboardValue(gallery.isVideoEnabled)
        }
    }
}
