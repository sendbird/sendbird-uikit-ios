//
//  SBUGroupChannelPushSettingsViewModel.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// swiftlint:disable type_name
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
// swiftlint:enable type_name

open class SBUGroupChannelPushSettingsViewModel: SBUBaseChannelSettingsViewModel {
    public private(set) var currentTriggerOption: GroupChannelPushTriggerOption = .off

    public weak var delegate: SBUGroupChannelPushSettingsViewModelDelegate? {
        get { self.baseDelegate as? SBUGroupChannelPushSettingsViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    // MARK: SwiftUI (Internal)
    var delegates: WeakDelegateStorage<SBUGroupChannelPushSettingsViewModelDelegate> {
        let computedDelegates = WeakDelegateStorage<SBUGroupChannelPushSettingsViewModelDelegate>()
        self.baseDelegates.allKeyValuePairs().forEach { key, value in
            if let delegate = value as? SBUGroupChannelPushSettingsViewModelDelegate {
                computedDelegates.addDelegate(delegate, type: key)
            }
        }
        return computedDelegates
    }
    
    required public init(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        delegate: SBUGroupChannelPushSettingsViewModelDelegate? = nil
    ) {
        super.init()

        self.delegate = delegate
        self.baseDelegates.addDelegate(delegate, type: .uikit)

        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        
        guard let channelURL = self.channelURL else { return }
        self.initializeAndLoad(channelURL: channelURL)
    }
    
    func initializeAndLoad(channelURL: String) {
        self.channelURL = channelURL
        self.loadChannel(channelURL: channelURL)
    }
    
    // MARK: - Channel related
    public override func loadChannel(channelURL: String?) {
        guard let channelURL = channelURL else { return }
        self.loadChannel(channelURL: channelURL, type: .group)
    }
    
    open func changeNotification(_ pushTriggerOption: GroupChannelPushTriggerOption) {
        guard let groupChannel = self.channel as? GroupChannel else { return }
        guard self.currentTriggerOption != pushTriggerOption else { return }
        
        self.delegates.forEach {
            $0.shouldUpdateLoadingState(true)
        }
        groupChannel.setMyPushTriggerOption(pushTriggerOption) { [weak self] error in
            guard let self = self else { return }
            self.delegates.forEach {
                $0.shouldUpdateLoadingState(false)
            }
            
            if let error = error {
                self.delegates.forEach {
                    $0.didReceiveError(error)
                }
                return
            }
            
            if let channel = self.channel {
                let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                self.delegates.forEach {
                    $0.baseChannelSettingsViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
                }
                self.updateChannelPushTriggerOption()
            }
        }
    }
    
    public func updateChannelPushTriggerOption() {
        guard let channel = self.channel as? GroupChannel else { return }
        self.currentTriggerOption = channel.myPushTriggerOption
        self.delegates.forEach {
            $0.groupChannelPushSettingsViewModel(
                self,
                didChangeNotification: self.currentTriggerOption
            )
        }
    }
}
