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
    
    func baseViewModelDidDelayConnection(
        _ viewModel: SBUBaseViewModel,
        retryAfter: UInt
    )
    
    func baseViewModelDidSucceedReconnection(_ viewModel: SBUBaseViewModel)
    
    func baseViewModelDidFailReconnection(_ viewModel: SBUBaseViewModel)
}

extension SBUCommonViewModelDelegate {
    /// This method is called when the connection state changes.
    public func connectionStateDidChange(_ isConnected: Bool) { }
    
    /// This method is called when an error is received.
    public func didReceiveError(_ error: SBError?) {
        self.didReceiveError(error, isBlocker: false)
    }
    
    /// This method is called when connection is delayed due to server overload.
    /// - Since: 3.32.4
    public func baseViewModelDidDelayConnection(
        _ viewModel: SBUBaseViewModel,
        retryAfter: UInt
    ) { }
    
    /// This method is called when reconnection is successful.
    /// - Since: 3.32.4
    public func baseViewModelDidSucceedReconnection(_ viewModel: SBUBaseViewModel) { }
    
    /// This method is called when reconnection is failed.
    /// - Since: 3.32.4
    public func baseViewModelDidFailReconnection(_ viewModel: SBUBaseViewModel) { }
}
