//
//  SBUMessageSearchViewModel.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

class SBUMessageSearchViewModel: SBULoadableViewModel {
    
    private(set) var searchResultList: [SBDBaseMessage] = [] {
        didSet {
            self.resultListChangedObservable.set(value: searchResultList)
        }
    }
    
    private let channel: SBDBaseChannel
    private var query: SBDMessageSearchQuery?
    
    let resultListChangedObservable = SBUObservable<[SBDBaseMessage]>()
    
    init(channel: SBDBaseChannel) {
        self.channel = channel
    }
    
    private(set) var keyword: String? = nil {
        didSet {
            self.query = nil
            self.searchResultList.removeAll()
        }
    }
    
    func search(keyword: String, query: SBDMessageSearchQuery) {
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
        
        self.keyword = trimmedKeyword
        self.query = query
        
        self.loadingObservable.post(value: true)
        self.loadMore()
    }
    
    func searchAgain() {
        self.loadingObservable.post(value: true)
        self.loadMore()
    }
    
    func loadMore() {
        SBULog.info("query : \(String(describing: self.query))")
        guard let query = self.query,
              query.hasNext() &&
                !query.isLoading() else { return }
        
        SBULog.info("loading next page.")
        query.loadNextPage { [weak self] messageList, error in
            guard let self = self else { return }
            
            self.loadingObservable.set(value: false)
            
            if let error = error {
                self.errorObservable.set(value: error)
            } else {
                guard let messageList = messageList else { return }

                let filteredList = messageList.filter { message in
                    return SBUUtils.findIndex(of: message, in: self.searchResultList) == nil
                }
                
                self.searchResultList.append(contentsOf: filteredList)
            }
        }
    }
    
    // MARK: - SBUViewModelDelegate
    
    override func dispose() {
        super.dispose()
        
        self.resultListChangedObservable.dispose()
    }
}
