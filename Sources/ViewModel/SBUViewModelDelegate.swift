//
//  SBUViewModelDelegate.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol SBUViewModelDelegate: AnyObject {
    func dispose()
}

public protocol SBUCommonViewModelDelegate: SBUCommonDelegate {
    // Connection
    func connectionStateDidChange(_ isConnected: Bool)
    
    // Loading
    func shouldUpdateLoadingState(_ isLoading: Bool)
}

extension SBUCommonViewModelDelegate {
    public func connectionStateDidChange(_ isConnected: Bool) { }
    
    public func didReceiveError(_ error: SBError?) {
        self.didReceiveError(error, isBlocker: false)
    }
}
