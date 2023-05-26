//
//  SBUGroupChannelListViewModel.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/05/17.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

public protocol SBUGroupChannelListViewModelDelegate: SBUBaseChannelListViewModelDelegate {
    /// Called when the channe list has been changed.
    /// - Parameters:
    ///    - viewModel: `SBUGroupChannelListViewModel` object.
    ///    - channels: The changed channels.
    ///    - needsToReload: If it's `true`, it needs to reload the view.
    func groupChannelListViewModel(
        _ viewModel: SBUGroupChannelListViewModel,
        didChangeChannelList channels: [GroupChannel]?,
        needsToReload: Bool
    )
    
    /// Called when a specific channel has been updated.
    /// - Parameters:
    ///    - viewModel: `SBUGroupChannelListViewModel` object.
    ///    - channel: The updated channel.
    func groupChannelListViewModel(
        _ viewModel: SBUGroupChannelListViewModel,
        didUpdateChannel channel: GroupChannel
    )
    
    /// Called when the current user has left a channel.
    /// - Parameters:
    ///    - viewModel: `SBUGroupChannelListViewModel` object.
    ///    - channel: The channel that the current user has been left.
    func groupChannelListViewModel(
        _ viewModel: SBUGroupChannelListViewModel,
        didLeaveChannel channel: GroupChannel
    )
}

open class SBUGroupChannelListViewModel: SBUBaseChannelListViewModel {
    // MARK: - Constants
    static let channelLoadLimit: UInt = 20
    static let notificationChannelLoadLimit: UInt = 100
    
    // MARK: - Property (Public)
    public var channelList: [GroupChannel] { self.channelCollection?.channelList ?? [] }
    
    public private(set) var channelCollection: GroupChannelCollection?

    /// This is a query used to get a list of channels. Only getter is provided, please use initialization function to set query directly.
    /// - note: For query properties, see `GroupChannelListQuery` class.
    /// - Since: 1.0.11
    public private(set) var channelListQuery: GroupChannelListQuery?
    
    // MARK: - Property (private)
    weak var delegate: SBUGroupChannelListViewModelDelegate? {
        get { self.baseDelegate as? SBUGroupChannelListViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    private var customizedChannelListQuery: GroupChannelListQuery?
    
    // MARK: - Life Cycle
    
    /// This function initializes the ViewModel.
    /// - Parameters:
    ///   - delegate: This is used to receive events that occur in the view model
    ///   - channelListQuery: This is used to use customized channelListQuery.
    public init(
        delegate: SBUGroupChannelListViewModelDelegate? = nil,
        channelListQuery: GroupChannelListQuery? = nil
    ) {
        super.init(delegate: delegate)

        self.customizedChannelListQuery = channelListQuery
        
        self.initChannelList()
    }
    
    deinit {
        self.reset()
    }
    
    private func createCollectionIfNeeded() {
        guard self.channelCollection == nil else { return }
        
        if let query = self.customizedChannelListQuery?.copy() as? GroupChannelListQuery {
            self.channelListQuery = query
        } else {
            let params = GroupChannelListQueryParams()
            params.order = .latestLastMessage
            
            if SBUAvailable.isNotificationChannelEnabled {
                params.limit = SBUGroupChannelListViewModel.notificationChannelLoadLimit
                params.includeChatNotification = true
            } else {
                params.limit = SBUGroupChannelListViewModel.channelLoadLimit
            }
            params.includeEmptyChannel = false
            params.includeMetaData = true
            
            self.channelListQuery = GroupChannel.createMyGroupChannelListQuery(params: params)
        }
        
        if let query = self.channelListQuery {
            self.channelCollection = SendbirdChat.createGroupChannelCollection(query: query)
        }
        self.channelCollection?.delegate = self
    }
    
    // MARK: - List handling
    
    /// This function initialize the channel list. the channel list will reset.
    public override func initChannelList() {
        super.initChannelList()
    }
    
    /// This function loads the channel list. If the reset value is `true`, the channel list will reset.
    /// - Parameter reset: To reset the channel list
    public override func loadNextChannelList(reset: Bool) {
        super.loadNextChannelList(reset: reset)
        
        guard !self.isLoading else { return }
        
        if reset {
            self.reset()
        }
        
        self.createCollectionIfNeeded()
        
        guard self.channelCollection?.hasNext == true else {
            SBULog.info("All channels have been loaded.")
            return
        }

        self.setLoading(true, false)
        
        self.channelCollection?.loadMore { [weak self] channels, error in
            guard let self = self else { return }
            defer { self.setLoading(false, false) }
            
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didReceiveError(error, isBlocker: true)
                }
                return
            }
            
            SBULog.info("[Response] \(channels?.count ?? 0) channels")
            
            self.delegate?.groupChannelListViewModel(
                self,
                didChangeChannelList: self.channelList,
                needsToReload: true
            )
        }
    }
    
    /// This function resets channelList
    public override func reset() {
        super.reset()
        
        self.channelListQuery = nil
        self.channelCollection?.dispose()
        self.channelCollection = nil
    }
    
    // MARK: - SDK Relations
    
    /// Leaves the channel.
    /// - Parameters:
    ///   - channel: Channel to leave
    ///   - completionHandler: Completion handler
    public func leaveChannel(_ channel: GroupChannel) {
        SBULog.info("[Request] Leave channel, ChannelURL: \(channel.channelURL)")
        
        self.setLoading(true, true)
        
        channel.leave { [weak self] error in
            guard let self = self else { return }
            defer { self.setLoading(false, false) }

            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didReceiveError(error, isBlocker: false)
                }
                return
            }

            // Final handling in `GroupChannelCollectionDelegate`
            SBULog.info("[Succeed] Leave channel request, ChannelURL: \(channel.channelURL)")
            
            self.delegate?.groupChannelListViewModel(self, didLeaveChannel: channel)
        }
    }
    
    /// Changes push trigger option on a channel.
    /// - Parameters:
    ///   - option: Push trigger option to change
    ///   - channel: Channel to change option
    public func changePushTriggerOption(option: GroupChannelPushTriggerOption,
                                        channel: GroupChannel) {
        SBULog.info("""
            [Request]
            Channel push status: \(option == .off ? "on" : "off"),
            ChannelURL: \(channel.channelURL)
            """)
        self.setLoading(true, true)
        
        channel.setMyPushTriggerOption(option) { [weak self] error in
            guard let self = self else { return }
            defer { self.setLoading(false, false) }
            
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didReceiveError(error, isBlocker: false)
                }
                return
            }
            
            // Final handling in `GroupChannelCollectionDelegate`
            SBULog.info("[Succeed] Channel push status, ChannelURL: \(channel.channelURL)")
            
            self.delegate?.groupChannelListViewModel(self, didUpdateChannel: channel)
        }
    }
    
    // MARK: - Common
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    private func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        self.isLoading = loadingState
        
        self.delegate?.shouldUpdateLoadingState(showIndicator)
    }
}

// MARK: - GroupChannelCollectionDelegate
extension SBUGroupChannelListViewModel: GroupChannelCollectionDelegate {
    open func channelCollection(_ collection: GroupChannelCollection,
                                context: ChannelContext,
                                deletedChannelURLs: [String]) {
        SBULog.info("""
            source: \(context.source.rawValue),
            fromEvent: \(context.fromEvent),
            delete size : \(deletedChannelURLs.count)
            """)
        
        self.delegate?.groupChannelListViewModel(
            self,
            didChangeChannelList: self.channelList,
            needsToReload: true
        )
    }
    
    open func channelCollection(_ collection: GroupChannelCollection,
                                context: ChannelContext,
                                addedChannels channels: [GroupChannel]) {
        SBULog.info("""
            source: \(context.source.rawValue),
            fromEvent: \(context.fromEvent),
            channel size : \(channels.count)
            """)
        self.delegate?.groupChannelListViewModel(
            self,
            didChangeChannelList: self.channelList,
            needsToReload: true
        )
    }
    
    open func channelCollection(_ collection: GroupChannelCollection,
                                context: ChannelContext,
                                updatedChannels channels: [GroupChannel]) {
        SBULog.info("""
            source: \(context.source.rawValue),
            fromEvent: \(context.fromEvent),
            channel size : \(channels.count)
            """)
        self.delegate?.groupChannelListViewModel(
            self,
            didChangeChannelList: self.channelList,
            needsToReload: true
        )
    }
}

// MARK: - ChannelDelegate : Please do not use it.
extension SBUGroupChannelListViewModel: GroupChannelDelegate {
    open func channel(_ channel: GroupChannel, userDidJoin user: User) {}
    open func channel(_ channel: GroupChannel, userDidLeave user: User) {}
    open func channelWasChanged(_ channel: BaseChannel) {}
    open func channel(_ channel: BaseChannel, messageWasDeleted messageId: Int64) {}
    open func channelWasFrozen(_ channel: BaseChannel) {}
    open func channelWasUnfrozen(_ channel: BaseChannel) {}
    open func channel(_ channel: BaseChannel, userWasBanned user: RestrictedUser) {}
}
