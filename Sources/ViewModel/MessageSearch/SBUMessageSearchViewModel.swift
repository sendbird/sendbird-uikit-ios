//
//  SBUMessageSearchViewModel.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

public protocol SBUMessageSearchViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the search results has been changed.
    func searchViewModel(_ viewModel: SBUMessageSearchViewModel, didChangeSearchResults results: [BaseMessage], needsToReload: Bool)
}

open class SBUMessageSearchViewModel {
    // MARK: - Constants
    static let limit: UInt = 20
    
    // MARK: - Property (Public)
    public private(set) var channel: BaseChannel?

    @SBUAtomic public private(set) var searchResultList: [BaseMessage] = []

    /// This param will be used on entering a channel from selecting an item from the search results.
    public var messageListParams: MessageListParams?
    
    public private(set) var messageSearchQuery: MessageSearchQuery?
    
    // MARK: - Property (Private)
    weak var delegate: SBUMessageSearchViewModelDelegate?

    var customMessageSearchQueryParams: MessageSearchQueryParams?
    
    var keyword: String?
    
    // MARK: - Lifecycle
    public init(
        channel: BaseChannel,
        params: MessageSearchQueryParams? = nil,
        delegate: SBUMessageSearchViewModelDelegate? = nil
    ) {
        self.delegate = delegate
        self.customMessageSearchQueryParams = params
        self.channel = channel
    }
    
    /// Performs keyword search in the channel
    ///
    /// if you set the ``customMessageSearchQueryParams`` value, this method only use ``customMessageSearchQueryParams``.
    ///
    /// - Parameter keyword: keyword to search for.
    open func search(keyword: String) {
        guard let channel = self.channel else {
            let error = SBError(domain: "Requires a channel object for message search", code: -1, userInfo: nil)
            self.delegate?.didReceiveError(error)
            return
        }
        
        let params: MessageSearchQueryParams
        
        if let customMessageSearchQueryParams = customMessageSearchQueryParams {
            // Customized
            params = customMessageSearchQueryParams
        } else {
            // Defaults
            params = MessageSearchQueryParams { params in
                // Default search from ts.
                // Only search for messages after a user has joined.
                if let groupChannel = self.channel as? GroupChannel {
                    // FIXME: - Change to joinedTs when core SDK is ready
                    params.messageTimestampFrom = groupChannel.invitedAt
                }
                
                if params.limit <= 0 {
                    // Default limit
                    params.limit = SBUMessageSearchViewModel.limit
                }
                // Below are reserved params.
                params.order = .timestamp
            }
        }
        
        // Common settings
        params.channelURL = channel.channelURL
        params.keyword = keyword
        
        let query = SendbirdChat.createMessageSearchQuery(params: params)
        
        self.search(keyword: keyword, query: query)
    }
    
    /// Performs keyword search
    ///
    /// - Parameters:
    ///   - keyword: keyword to search for.
    ///   - query: ``messageSearchQuery`` object to search for
    public func search(keyword: String, query: MessageSearchQuery) {
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
              messageSearchQuery.hasNext &&
                !messageSearchQuery.isLoading
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
