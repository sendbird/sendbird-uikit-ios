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
    
    
    // MARK: - Property (Public)
    @SBUAtomic public private(set) var channelList: [GroupChannel] = []
    
    public private(set) var channelCollection: GroupChannelCollection?

    /// This is a query used to get a list of channels. Only getter is provided, please use initialization function to set query directly.
    /// - note: For query properties, see `GroupChannelListQuery` class.
    /// - Since: 1.0.11
    public private(set) var channelListQuery: GroupChannelListQuery?
    
    
    // MARK: - Property (private)
    private weak var delegate: SBUGroupChannelListViewModelDelegate? {
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
            params.limit = SBUGroupChannelListViewModel.channelLoadLimit
            params.includeEmptyChannel = false
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
            
            guard let channels = channels else { return }
            SBULog.info("[Response] \(channels.count) channels")
            guard !channels.isEmpty else { return }
            
            self.upsertChannels(channels, needReload: true)
        }
    }
    
    /// This function updates the channels.
    ///
    /// It is updated only if the channels already exist in the list, and if not, it is ignored.
    /// And, after updating the channels, a function to sort the channel list is called.
    /// - Parameters:
    ///   - channels: Channel array to update
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    public func updateChannels(_ channels: [GroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
            guard self.channelListQuery?.belongsTo(channel: channel) == true else { continue }
            guard let index = self.channelList.firstIndex(of: channel) else { continue }
            self.channelList.append(self.channelList.remove(at: index))
        }
        
        self.sortChannelList(needReload: needReload)
    }
    
    /// This function upserts the channels.
    ///
    /// If the channels are already in the list, it is updated, otherwise it is inserted.
    /// And, after upserting the channels, a function to sort the channel list is called.
    /// - Parameters:
    ///   - channels: Channel array to upsert
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    public func upsertChannels(_ channels: [GroupChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        let includeEmptyChannel = self.channelListQuery?.includeEmptyChannel ?? false
        for channel in channels {
            guard self.channelListQuery?.belongsTo(channel: channel) == true else { continue }
            guard (channel.lastMessage != nil || includeEmptyChannel) else { continue }
            guard let index = self.channelList.firstIndex(
                    where: { $0.channelURL == channel.channelURL }
            ) else {
                self.channelList.append(channel)
                continue
            }
            
            self.channelList.append(self.channelList.remove(at: index))
        }
        
        self.sortChannelList(needReload: needReload)
    }
    
    /// This function deletes the channels using the channel urls.
    /// - Parameters:
    ///   - channelURLs: Channel url array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    public func deleteChannels(channelURLs: [String]?, needReload: Bool) {
        guard let channelURLs = channelURLs else { return }
        
        var toBeDeleteIndexes: [Int] = []
        
        for channelURL in channelURLs {
            if let index = self.channelList.firstIndex(where: { $0.channelURL == channelURL }) {
                toBeDeleteIndexes.append(index)
            }
        }
        
        // for remove from last
        let sortedIndexes = toBeDeleteIndexes.sorted().reversed()
        
        for toBeDeleteIdx in sortedIndexes {
            self.channelList.remove(at: toBeDeleteIdx)
        }
        
        self.sortChannelList(needReload: needReload)
    }
    
    /// This function sorts the channel lists.
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData.
    public func sortChannelList(needReload: Bool) {
        let sortedChannelList = self.channelList
            .sorted(by: { (lhs: GroupChannel, rhs: GroupChannel) -> Bool in
                return GroupChannel.compare(
                    channelA: lhs,
                    channelB: rhs,
                    order: channelListQuery?.order ?? .latestLastMessage
                )
            })
        
        self.channelList = sortedChannelList.sbu_unique()
        
        self.delegate?.groupChannelListViewModel(
            self,
            didChangeChannelList: self.channelList,
            needsToReload: needReload
        )
    }
    
    /// This function resets channelList
    public override func reset() {
        super.reset()
        
        self.channelList = []
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
        self.deleteChannels(channelURLs: deletedChannelURLs, needReload: true)
    }
    
    open func channelCollection(_ collection: GroupChannelCollection,
                                context: ChannelContext,
                                addedChannels channels: [GroupChannel]) {
        SBULog.info("""
            source: \(context.source.rawValue),
            fromEvent: \(context.fromEvent),
            channel size : \(channels.count)
            """)
        self.upsertChannels(channels, needReload: true)
    }
    
    
    open func channelCollection(_ collection: GroupChannelCollection,
                                context: ChannelContext,
                                updatedChannels channels: [GroupChannel]) {
        SBULog.info("""
            source: \(context.source.rawValue),
            fromEvent: \(context.fromEvent),
            channel size : \(channels.count)
            """)
        self.upsertChannels(channels, needReload: true)
    }
}




// MARK: - ChannelDelegate : Please do not use it.
extension SBUGroupChannelListViewModel: BaseChannelDelegate {
    open func channel(_ channel: GroupChannel, userDidJoin user: User) {}
    open func channel(_ channel: GroupChannel, userDidLeave user: User) {}
    open func channelWasChanged(_ channel: BaseChannel) {}
    open func channel(_ channel: BaseChannel, messageWasDeleted messageId: Int64) {}
    open func channelWasFrozen(_ channel: BaseChannel) {}
    open func channelWasUnfrozen(_ channel: BaseChannel) {}
    open func channel(_ channel: BaseChannel, userWasBanned user: RestrictedUser) {}
}
