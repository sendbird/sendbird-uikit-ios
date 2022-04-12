//
//  SBUBaseChannelSettingsViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/22.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

public protocol SBUBaseChannelSettingsViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the context of channel has been changed.
    func baseChannelSettingsViewModel(
        _ viewModel: SBUBaseChannelSettingsViewModel,
        didChangeChannel channel: SBDBaseChannel?,
        withContext context: SBDMessageContext
    )
}



open class SBUBaseChannelSettingsViewModel: NSObject {
    
    // MARK: - Logic properties (Public)
    public internal(set) var channel: SBDBaseChannel?
    public internal(set) var channelUrl: String?
    
    public var isOperator: Bool {
        if let groupChannel = self.channel as? SBDGroupChannel {
            return groupChannel.myRole == .operator
        } else if let openChannel = self.channel as? SBDOpenChannel {
            guard let userId = SBUGlobals.currentUser?.userId else { return false }
            return openChannel.isOperator(withUserId: userId)
        }
        return false
    }
    
    
    // MARK: - Logic properties (Private)
    weak var baseDelegate: SBUBaseChannelSettingsViewModelDelegate?
    
    
    // MARK: - LifeCycle
    public override init() {
        super.init()
        
        SBDMain.add(
            self as SBDChannelDelegate,
            identifier: "\(SBUConstant.channelDelegateIdentifier).\(self.description)"
        )
    }
    
    deinit {
        self.baseDelegate = nil
        SBDMain.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.channelDelegateIdentifier).\(self.description)"
        )
    }
    
    
    // MARK: - Channel related
    
    /// This function loads channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String) { }
    
    /// This function loads channel information.
    /// - Parameters:
    ///   - channelUrl: channel url
    ///   - type: channel type
    public func loadChannel(channelUrl: String, type: SBDChannelType) {
        self.baseDelegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] user, error in
            guard let self = self else { return }
            defer { self.baseDelegate?.shouldUpdateLoadingState(false) }
            
            if let error = error {
                self.baseDelegate?.didReceiveError(error, isBlocker: false)
            } else {
                let completionHandler: ((SBDBaseChannel?, SBDError?) -> Void) = {
                    [weak self] channel, error in
                    
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.baseDelegate?.didReceiveError(error, isBlocker: false)
                    } else if let channel = channel {
                        self.channel = channel
                        
                        let context = SBDMessageContext()
                        context.source = .eventChannelChanged
                        self.baseDelegate?.baseChannelSettingsViewModel(
                            self,
                            didChangeChannel: channel,
                            withContext: context
                        )
                    }
                }
                
                switch type {
                case .group:
                    SBDGroupChannel.getWithUrl(channelUrl, completionHandler: completionHandler)
                case .open:
                    SBDOpenChannel.getWithUrl(channelUrl, completionHandler: completionHandler)
                default:
                    break
                }
            }
        }
    }
    
    /// Used to update the channel name or cover image. `channelName` and` coverImage` are used for updating only the set values.
    /// - Parameters:
    ///   - channelName: Channel name to update
    ///   - coverImage: Cover image to update
    public func updateChannel(channelName: String? = nil, coverImage: UIImage? = nil) { }
}


// MARK: - SBDChannelDelegate
extension SBUBaseChannelSettingsViewModel: SBDChannelDelegate {
    open func channel(_ sender: SBDOpenChannel, userDidEnter user: SBDUser) {
        let context =  SBDMessageContext()
        context.source = .eventChannelChanged
        self.baseDelegate?.baseChannelSettingsViewModel(
            self,
            didChangeChannel: sender,
            withContext: context
        )
    }
    
    open func channel(_ sender: SBDOpenChannel, userDidExit user: SBDUser) {
        let context =  SBDMessageContext()
        context.source = .eventChannelChanged
        self.baseDelegate?.baseChannelSettingsViewModel(
            self,
            didChangeChannel: sender,
            withContext: context
        )
    }
    
    open func channel(_ sender: SBDGroupChannel, userDidJoin user: SBDUser) {
        let context =  SBDMessageContext()
        context.source = .eventUserJoined
        self.baseDelegate?.baseChannelSettingsViewModel(
            self,
            didChangeChannel: sender,
            withContext: context
        )
    }
    
    open func channel(_ sender: SBDGroupChannel, userDidLeave user: SBDUser) {
        let context =  SBDMessageContext()
        context.source = .eventUserLeft
        self.baseDelegate?.baseChannelSettingsViewModel(
            self,
            didChangeChannel: channel,
            withContext: context
        )
    }
}
