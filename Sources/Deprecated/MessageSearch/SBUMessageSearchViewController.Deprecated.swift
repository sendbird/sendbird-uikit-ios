//
//  SBUMessageSearchViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/19.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUMessageSearchViewController {
    // MARK: - 3.0.0
    @available(*, unavailable, message: "This property has been moved to the `SBUMessageSearchModule.Header`. And renamed to `titleView`.", renamed: "headerComponent.titleView")
    public var searchBar: UIView? { get { headerComponent?.titleView } set { } }
    
    @available(*, unavailable, message: "This property has been moved to the `SBUMessageSearchModule.List`.", renamed: "listComponent.tableView")
    public var tableView: UITableView? { listComponent?.tableView }
    
    @available(*, unavailable, message: "This property has been moved to the `SBUMessageSearchModule.List`.", renamed: "listComponent.messageSearchResultCell")
    public var messageSearchResultCell: SBUMessageSearchResultCell? { get { nil } set { } }
    
    @available(*, unavailable, message: "This property has been moved to the `SBUMessageSearchModule.List`.", renamed: "listComponent.emptyView")
    public var emptyView: UIView? { get { nil } set { } }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMessageSearchViewModel`.", renamed: "viewModel.messageListParams")
    public var messageListParams: MessageListParams? { get { self.viewModel?.messageListParams } set {} }
    
    @available(*, unavailable, message: "This property has been removed. If you want to customization, you can use `customMessageSearchQueryParams`.")
    public var customMessageSearchQueryBuilder: ((MessageSearchQueryBuilder) -> Void)? { get { nil } set {} }

    @available(*, deprecated, message: "This function has been moved to the `SBUMessageSearchModule.Header`.", renamed: "headerComponent.updateSearchBarStyle(with:)")
    public func setupSearchBarStyle(searchBar: UISearchBar) { self.headerComponent?.updateSearchBarStyle(with: searchBar)
    }
    
    @available(*, deprecated, message: "This property has been moved to the `SBUMessageSearchViewModel`.", renamed: "listComponent.message(at:)")
    open func message(at indexPath: IndexPath) -> BaseMessage? {
        return self.listComponent?.message(at: indexPath)
    }
    
    @available(*, deprecated, message: "This function has been moved to the `SBUMessageSearchModule.List`.`", renamed: "listComponent.register(resultCell:nib:)")
    public func register(messageSearchResultCell: SBUMessageSearchResultCell, nib: UINib? = nil) {
        self.listComponent?.register(resultCell: messageSearchResultCell, nib: nib)
    }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, renamed: "shouldUpdateLoadingState(_:)")
    open func shouldDismissLoadingIndicator() {}
    
    // MARK: - ~2.2.0
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    public func didReceiveError(_ message: String?, _ code: NSInteger?) {
        self.errorHandler(message, code)
    }
}

public class MessageSearchQueryBuilder {}
