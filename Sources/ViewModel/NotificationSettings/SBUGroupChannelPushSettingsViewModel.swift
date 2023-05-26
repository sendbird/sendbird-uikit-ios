//
//  SBUGroupChannelPushSettingsViewModel.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUGroupChannelPushSettingsViewModelDelegate: SBUBaseChannelSettingsViewModelDelegate {
    /// Called when changed push notification option
    /// - Parameters:
    ///   - viewModel: `SBUGroupChannelPushSettingsViewModel` object.
    ///   - pushTriggerOption: `GroupChannelPushTriggerOption` object to change.
    func groupChannelPushSettingsViewModel(
        _ viewModel: SBUGroupChannelPushSettingsViewModel,
        didChangeNotification pushTriggerOption: GroupChannelPushTriggerOption
    )
}

open class SBUGroupChannelPushSettingsViewModel: SBUBaseChannelSettingsViewModel {
    public private(set) var currentTriggerOption: GroupChannelPushTriggerOption = .off

    public weak var delegate: SBUGroupChannelPushSettingsViewModelDelegate? {
        get { self.baseDelegate as? SBUGroupChannelPushSettingsViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    public init(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        delegate: SBUGroupChannelPushSettingsViewModelDelegate? = nil
    ) {
        super.init()

        self.delegate = delegate

        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        
        self.updateChannelPushTriggerOption()
    }
    
    open func changeNotification(_ pushTriggerOption: GroupChannelPushTriggerOption) {
        guard let groupChannel = self.channel as? GroupChannel else { return }
        guard self.currentTriggerOption != pushTriggerOption else { return }
        
        self.delegate?.shouldUpdateLoadingState(true)
        groupChannel.setMyPushTriggerOption(pushTriggerOption) { [weak self] error in
            guard let self = self else { return }
            self.delegate?.shouldUpdateLoadingState(false)
            
            if let error = error {
                self.delegate?.didReceiveError(error)
                return
            }
            
            if let channel = self.channel {
                let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                self.delegate?.baseChannelSettingsViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context
                )
                self.updateChannelPushTriggerOption()
            }
        }
    }
    
    public func updateChannelPushTriggerOption() {
        guard let channel = self.channel as? GroupChannel else { return }
        self.currentTriggerOption = channel.myPushTriggerOption
        self.delegate?.groupChannelPushSettingsViewModel(
            self,
            didChangeNotification: self.currentTriggerOption
        )
    }
}
