//
//  SBUMessageSearchViewModel.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK


public protocol SBUMessageSearchViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the search results has been changed.
    func searchViewModel(_ viewModel: SBUMessageSearchViewModel, didChangeSearchResults results: [SBDBaseMessage], needsToReload: Bool)
}


open class SBUMessageSearchViewModel {
    // MARK: - Constants
    static let limit: UInt = 20
    
    
    // MARK: - Property (Public)
    public private(set) var channel: SBDBaseChannel?

    @SBUAtomic public private(set) var searchResultList: [SBDBaseMessage] = []

    public var messageSearchQueryBuilder: ((SBDMessageSearchQueryBuilder) -> Void)? = nil

    /// This param will be used on entering a channel from selecting an item from the search results.
    public var messageListParams: SBDMessageListParams? = nil
    
    
    // MARK: - Property (Private)
    weak var delegate: SBUMessageSearchViewModelDelegate?

    private var messageSearchQuery: SBDMessageSearchQuery?
    
    private(set) var keyword: String? = nil
    
    
    // MARK: - Lifecycle
    public init(
        channel: SBDBaseChannel,
        messageSearchQueryBuilder: ((SBDMessageSearchQueryBuilder) -> Void)? = nil,
        delegate:SBUMessageSearchViewModelDelegate? = nil
    ) {
        
        self.messageSearchQueryBuilder = messageSearchQueryBuilder
        
        self.delegate = delegate
        
        self.channel = channel
        
    }
    
    /// Performs keyword search
    ///
    /// - Parameter keyword: keyword to search for.
    public func search(keyword: String) {
        let query = SBDMessageSearchQuery.create { builder in
            guard let channel = self.channel else {
                let error = SBDError(domain: "Requires a channel object for message search", code: -1, userInfo: nil)
                self.delegate?.didReceiveError(error)
                return
            }
            
            /// Default search from ts.
            /// Only search for messages after a user has joined.
            if let groupChannel = self.channel as? SBDGroupChannel {
                // FIXME: - Change to joinedTs when core SDK is ready
                builder.messageTimestampFrom = groupChannel.invitedAt
            }
            
            self.messageSearchQueryBuilder?(builder)
            
            if builder.limit <= 0 {
                /// Default limit
                builder.limit = SBUMessageSearchViewModel.limit
            }
            
            /// Below are reserved params.
            builder.channelUrl = channel.channelUrl
            builder.keyword = keyword
            builder.order = .timeStamp
        }
        
        self.search(keyword: keyword, query: query)
    }
    
    /// Performs keyword search
    ///
    /// - Parameters:
    ///   - keyword: keyword to search for.
    ///   - query: `SBDMessageSearchQuery` object to search for
    public func search(keyword: String, query: SBDMessageSearchQuery) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedKeyword.isEmpty else {
            SBULog.info("Keyword shouldn't be empty.")
            return
        }
        guard trimmedKeyword != self.keyword else {
            SBULog.info("Same keyword.")
            return
        }
        
        SBULog.info("new search keyword : [\(trimmedKeyword)]")
        
        self.searchResultList.removeAll()
        
        self.keyword = trimmedKeyword
        self.messageSearchQuery = query
        
        self.delegate?.shouldUpdateLoadingState(true)
        self.loadMore()
    }
    
    /// Loads the following list
    public func loadMore() {
        SBULog.info("query : \(String(describing: self.messageSearchQuery))")
        guard let messageSearchQuery = self.messageSearchQuery,
              messageSearchQuery.hasNext() &&
                !messageSearchQuery.isLoading()
        else {
            self.delegate?.shouldUpdateLoadingState(false)
            return
        }
        
        SBULog.info("loading next page.")
        messageSearchQuery.loadNextPage { [weak self] messageList, error in
            guard let self = self else { return }
            
            self.delegate?.shouldUpdateLoadingState(false)
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: true)
            } else {
                guard let messageList = messageList else { return }

                let filteredList = messageList.filter { message in
                    return SBUUtils.findIndex(of: message, in: self.searchResultList) == nil
                }
                
                self.searchResultList.append(contentsOf: filteredList)
                self.delegate?.searchViewModel(
                    self,
                    didChangeSearchResults: self.searchResultList,
                    needsToReload: true
                )
            }
        }
    }
}
