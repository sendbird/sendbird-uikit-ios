//
//  SBUBaseViewModel.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 10/20/25.
//

import Foundation
import SendbirdChatSDK

/// The base class for all View Models.
/// - Since: 3.32.4
open class SBUBaseViewModel: NSObject {
    weak var commonDelegate: SBUCommonViewModelDelegate?
    
    override public init() { // (commonDelegate: SBUCommonViewModelDelegate? = nil) {
//        self.commonDelegate = commonDelegate
        super.init()
        
        SendbirdChat.addConnectionDelegate(
            self,
            identifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
    }
    
//    @available(*, deprecated, message: "Use init(commonDelegate:) instead.")
//    public override convenience init() {
////        self.init(commonDelegate: nil)
//        self.init()
//    }
    
    deinit {
        SendbirdChat.removeConnectionDelegate(
            forIdentifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
    }
}

extension SBUBaseViewModel: ConnectionDelegate {
    open func didDelayConnection(retryAfter: UInt) {
        SBULog.info("retryAfter=\(retryAfter)")
        
        // show the busy server alert view
        self.commonDelegate?.baseViewModelDidDelayConnection(self, retryAfter: retryAfter)
    }
    
    open func didSucceedReconnection() {
        SBULog.info("")
        
        // dismiss the busy server alert view
        self.commonDelegate?.baseViewModelDidSucceedReconnection(self)
    }
    
    open func didFailReconnection() {
        SBULog.info("")
        
        // dismiss the busy server alert view
        self.commonDelegate?.baseViewModelDidFailReconnection(self)
    }
}
