//
//  SBUBaseChannelListViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUBaseChannelListViewModelDelegate: SBUCommonViewModelDelegate {}

open class SBUBaseChannelListViewModel: NSObject {
    
    // MARK: - Property (private)
    weak var baseDelegate: SBUBaseChannelListViewModelDelegate?
    var isLoading = false
    
    // MARK: - Life Cycle
    
    /// This function initializes the ViewModel.
    /// - Parameters:
    ///   - delegate: This is used to receive events that occur in the view model
    ///   - channelListQuery: This is used to use customized channelListQuery.
    public init(
        delegate: SBUBaseChannelListViewModelDelegate?
    ) {
        self.baseDelegate = delegate
        
        super.init()
        
        SendbirdChat.addConnectionDelegate(
            self,
            identifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
    }
    
    deinit {
        self.reset()
        SendbirdChat.removeConnectionDelegate(
            forIdentifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
    }
    
    // MARK: - List handling
    
    /// This function initialize the channel list. the channel list will reset.
    public func initChannelList() {
        SBULog.info("[Request] Next channel List")
        SendbirdUI.connectIfNeeded { [weak self] _, error in
            if let error = error {
                self?.baseDelegate?.didReceiveError(error, isBlocker: true)
                return
            }
            
            self?.baseDelegate?.connectionStateDidChange(true)
            
            self?.loadNextChannelList(reset: true)
        }
    }
    
    /// This function loads the channel list. If the reset value is `true`, the channel list will reset.
    /// - Parameter reset: To reset the channel list
    public func loadNextChannelList(reset: Bool) {
        SBULog.info("[Request] Next channel List")
    }
    
    /// This function resets channelList
    public func reset() {}
    
    // MARK: - SDK Relations
    
    // MARK: - Common
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    private func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        self.isLoading = loadingState
        
        self.baseDelegate?.shouldUpdateLoadingState(showIndicator)
    }
}

// MARK: ConnectionDelegate
extension SBUBaseChannelListViewModel: ConnectionDelegate {
    open func didSucceedReconnection() {
        SBULog.info("Did succeed reconnection")
        
        SendbirdUI.updateUserInfo { error in
            if let error = error {
                SBULog.error("[Failed] Update user info: \(error.localizedDescription)")
            }
        }
        
        self.baseDelegate?.connectionStateDidChange(true)
    }
}
