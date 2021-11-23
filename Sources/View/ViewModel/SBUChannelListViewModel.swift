//
//  SBUChannelListViewModel.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/05/17.
//  Copyright © 2021 SendBird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

class SBUChannelListViewModel: SBULoadableViewModel {
    static let channelLoadLimit: UInt = 20
    
    let customizedChannelListQuery: SBDGroupChannelListQuery?
    let lastUpdatedTimestamp: Int64
    
    var channelCollection: SBDGroupChannelCollection?
    var channelListQuery: SBDGroupChannelListQuery?
    
    private(set) var isLoading = false
    private(set) var lastUpdatedToken: String? = nil
    
    var channelUpsertObservable = SBUObservable<[SBDGroupChannel]>()
    var channelDeleteObservable = SBUObservable<[String]>()
    
    init(customizedChannelListQuery: SBDGroupChannelListQuery?) {
        self.customizedChannelListQuery = customizedChannelListQuery
        self.lastUpdatedTimestamp = max(
            SBDMain.getLastConnectedAt(), Int64(Date().timeIntervalSince1970 * 1000)
        )
        super.init()
    }
    
    private func createCollectionIfNeeded() {
        guard self.channelCollection == nil else { return }
        
        if let query = self.customizedChannelListQuery?.copy() as? SBDGroupChannelListQuery {
            self.channelListQuery = query
        } else {
            self.channelListQuery = SBDGroupChannel.createMyGroupChannelListQuery()
            self.channelListQuery?.order = .latestLastMessage
            self.channelListQuery?.limit = SBUChannelListViewModel.channelLoadLimit
            self.channelListQuery?.includeEmptyChannel = false
        }
        
        if let query = self.channelListQuery {
            self.channelCollection = SBDGroupChannelCollection(query: query)
        }
        self.channelCollection?.delegate = self
    }
    
    func loadNextChannelList() {
        SBULog.info("[Request] Next channel List")
        
        guard !self.isLoading else { return }
        self.isLoading = true
        
        createCollectionIfNeeded()
        
        guard self.channelCollection?.hasMore == true else {
            SBULog.info("All channels have been loaded.")
            self.isLoading = false
            return
        }
        
        self.loadingObservable.post(value: true)
        self.channelCollection?.loadMore { [weak self] channels, error in
            guard let self = self else { return }
            defer {
                self.loadingObservable.set(value: false)
                self.isLoading = false
            }
            
            if let error = error {
                SBULog.error("""
                    [Failed]
                    Channel list request: \(String(describing: error.localizedDescription))
                    """)
                self.errorObservable.set(value: error)
                return
            }
            guard let channels = channels else { return }
            
            SBULog.info("[Response] \(channels.count) channels")
            
            self.channelUpsertObservable.set(value: channels)
        }
    }
    
    func reset() {
        self.channelListQuery = nil
        self.channelCollection?.dispose()
        self.lastUpdatedToken = nil
    }
    
    // MARK: - SBUViewModelDelegate
    
    override func dispose() {
        super.dispose()
        
        self.channelCollection?.dispose()

        self.channelUpsertObservable.dispose()
        self.channelDeleteObservable.dispose()
    }
}

extension SBUChannelListViewModel: SBDGroupChannelCollectionDelegate {
    func channelCollection(_ collection: SBDGroupChannelCollection, context: SBDChannelContext, deletedChannelUrls: [String]) {
        SBULog.info("source: \(context.source.rawValue), fromEvent: \(context.isFromEvent()), delete size : \(deletedChannelUrls.count)")
        self.channelDeleteObservable.set(value: deletedChannelUrls)
    }
    
    func channelCollection(_ collection: SBDGroupChannelCollection, context: SBDChannelContext, addedChannels channels: [SBDGroupChannel]) {
        SBULog.info("source: \(context.source.rawValue), fromEvent: \(context.isFromEvent()), channel size : \(channels.count)")
        self.channelUpsertObservable.set(value: channels)
    }
    
    func channelCollection(_ collection: SBDGroupChannelCollection, context: SBDChannelContext, updatedChannels channels: [SBDGroupChannel]) {
        SBULog.info("source: \(context.source.rawValue), fromEvent: \(context.isFromEvent()), channel size : \(channels.count)")
        self.channelUpsertObservable.set(value: channels)
    }
}
