//
//  ChannelVC_Overriding.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/09.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class ChannelVC_Overriding: SBUChannelViewController {
    // MARK: - Show relations
    override func showChannelSettings() {
        // If you want to use your own ChannelSettingsViewController, you can override and customize it here.
        AlertManager.showCustomInfo(#function)
    }

    
    // MARK: - Cell TapHandler
    /// This function sets the cell's tap gesture handling.
    override func setTapGestureHandler(_ cell: SBUBaseMessageCell, message: SBDBaseMessage) {
        AlertManager.showCustomInfo(#function)
    }
    
    /// This function sets the cell's long tap gesture handling.
    override func setLongTapGestureHandler(_ cell: SBUBaseMessageCell, message: SBDBaseMessage, indexPath: IndexPath) {
        AlertManager.showCustomInfo(#function)
    }
    
    
    // MARK: - SBUMessageInputViewDelegate
    override func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String) {
        AlertManager.showCustomInfo(#function)
    }
    
    override func messageInputView(_ messageInputView: SBUMessageInputView, didSelectResource type: MediaResourceType) {
        AlertManager.showCustomInfo(#function)
    }
    
    override func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String) {
        AlertManager.showCustomInfo(#function)
    }
    
    override func messageInputViewDidStartTyping() {
        
    }
    
    override func messageInputViewDidEndTyping() {
        
    }
    

    // MARK: - SBUFileViewerDelegate
    override func didSelectDeleteImage(message: SBDFileMessage) {
        AlertManager.showCustomInfo(#function)
    }
    
    
    // MARK: SBDConnectionDelegate
    override func didSucceedReconnection() {
        // If you override and customize this function, you can handle it when reconnected.
        super.didSucceedReconnection()
    }
    
    
    // MARK: - Error handling
    override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        // If you override and customize this function, you can handle it when error received.
        print(message as Any);
    }
}
