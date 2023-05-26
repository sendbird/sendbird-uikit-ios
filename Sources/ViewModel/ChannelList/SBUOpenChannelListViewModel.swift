//
//  SBUOpenChannelListViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUOpenChannelListViewModelDelegate: SBUBaseChannelListViewModelDelegate {
    /// Called when the channe list has been changed.
    /// - Parameters:
    ///    - viewModel: `SBUOpenChannelListViewModel` object.
    ///    - channels: The changed channels.
    ///    - needsToReload: If it's `true`, it needs to reload the view.
    func openChannelListViewModel(
        _ viewModel: SBUOpenChannelListViewModel,
        didChangeChannelList channels: [OpenChannel]?,
        needsToReload: Bool
    )
    
    /// Called when a specific channel has been updated.
    /// - Parameters:
    ///    - viewModel: `SBUOpenChannelListViewModel` object.
    ///    - channel: The updated channel.
    func openChannelListViewModel(
        _ viewModel: SBUOpenChannelListViewModel,
        didUpdateChannel channel: OpenChannel
    )
}

open class SBUOpenChannelListViewModel: SBUBaseChannelListViewModel {
    // MARK: - Constants
    static let channelLoadLimit: UInt = 20
    
    // MARK: - Property (Public)
    @SBUAtomic public private(set) var channelList: [OpenChannel] = []
    
    /// This is a query used to get a list of channels. Only getter is provided, please use initialization function to set query directly.
    /// - note: For query properties, see `OpenChannelListQuery` class.
    /// - Since: 1.0.11
    public private(set) var channelListQuery: OpenChannelListQuery?
    
    // MARK: - Property (private)
    private weak var delegate: SBUOpenChannelListViewModelDelegate? {
        get { self.baseDelegate as? SBUOpenChannelListViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    private var customizedChannelListQuery: OpenChannelListQuery?
    
    // MARK: - Life Cycle
    
    /// This function initializes the ViewModel.
    /// - Parameters:
    ///   - delegate: This is used to receive events that occur in the view model
    ///   - channelListQuery: This is used to use customized channelListQuery.
    public init(
        delegate: SBUOpenChannelListViewModelDelegate?,
        channelListQuery: OpenChannelListQuery?
    ) {
        super.init(delegate: delegate)

        self.customizedChannelListQuery = channelListQuery
        
        SendbirdChat.addChannelDelegate(
            self,
            identifier: "\(SBUConstant.openChannelDelegateIdentifier).\(self.description)"
        )
        
        self.initChannelList()
    }
    
    deinit {
        self.reset()
        
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.openChannelDelegateIdentifier).\(self.description)"
        )
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
        self.setLoading(true, false)
        
        if reset {
            self.reset()
        }
        
        if self.channelListQuery == nil {
            if let query = self.customizedChannelListQuery?.copy() as? OpenChannelListQuery {
                self.channelListQuery = query
            } else {
                let params = OpenChannelListQueryParams()
                params.limit = SBUOpenChannelListViewModel.channelLoadLimit
                self.channelListQuery = OpenChannel.createOpenChannelListQuery(params: params)
            }
        }
        guard self.channelListQuery?.hasNext == true else {
            self.setLoading(false, false)
            return
        }
        
        self.channelListQuery?.loadNextPage(completionHandler: { [weak self] channels, error in
            guard let self = self else { return }
            defer { self.setLoading(false, false) }
            
            if let error = error {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didReceiveError(error, isBlocker: true)
                }
                return
            }
            
            SBULog.info("[Response] \(channels?.count ?? 0) channels")
            
            self.upsertChannels(channels, needReload: true)
        })
    }
    
    /// This function updates the channels.
    ///
    /// It is updated only if the channels already exist in the list, and if not, it is ignored.
    /// And, after updating the channels, a function to sort the channel list is called.
    /// - Parameters:
    ///   - channels: Channel array to update
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    public func updateChannels(_ channels: [OpenChannel]?, needReload: Bool) {
        guard let channels = channels else { return }
        
        for channel in channels {
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
    public func upsertChannels(_ channels: [OpenChannel]?, needReload: Bool) {
        channels?.forEach { channel in
            guard let index = self.channelList.firstIndex(
                where: { $0.channelURL == channel.channelURL }
            ) else {
                self.channelList.append(channel)
                return
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
            .sorted(by: { (lhs: OpenChannel, rhs: OpenChannel) -> Bool in
                return lhs.createdAt > rhs.createdAt
            })
        
        self.channelList = sortedChannelList.sbu_unique()
        
        self.delegate?.openChannelListViewModel(
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

// MARK: - ChannelDelegate : Please do not use it.
extension SBUOpenChannelListViewModel: OpenChannelDelegate {
    open func channelWasChanged(_ channel: BaseChannel) {
        guard let openChannel = channel as? OpenChannel else { return }
        self.upsertChannels([openChannel], needReload: true)
    }
    
    open func channel(_ channel: BaseChannel, didUpdate message: BaseMessage) {
        guard let openChannel = channel as? OpenChannel else { return }
        self.upsertChannels([openChannel], needReload: true)
    }
    
    open func channelWasFrozen(_ channel: BaseChannel) {
        guard let openChannel = channel as? OpenChannel else { return }
        self.upsertChannels([openChannel], needReload: true)
    }
    
    open func channelWasUnfrozen(_ channel: BaseChannel) {
        guard let openChannel = channel as? OpenChannel else { return }
        self.upsertChannels([openChannel], needReload: true)
    }

    open func channel(_ sender: OpenChannel, userDidExit user: User) {
        self.upsertChannels([sender], needReload: true)
    }
    
    open func channel(_ sender: OpenChannel, userDidEnter user: User) {
        self.upsertChannels([sender], needReload: true)
    }
    
    open func channelWasDeleted(_ channelURL: String, channelType: ChannelType) {
        guard channelType == .open else { return }
        SBULog.info("Channel was deleted")
        self.deleteChannels(channelURLs: [channelURL], needReload: true)
    }
}
