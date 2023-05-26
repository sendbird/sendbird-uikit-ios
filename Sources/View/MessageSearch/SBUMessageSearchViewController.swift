//
//  SBUMessageSearchViewController.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// ViewController handling a message search.
///
/// - Since: 2.1.0
@objcMembers
open class SBUMessageSearchViewController: SBUBaseViewController, SBUMessageSearchModuleHeaderDelegate, SBUMessageSearchModuleListDelegate, SBUMessageSearchModuleListDataSource, SBUCommonViewModelDelegate, SBUEmptyViewDelegate, SBUMessageSearchViewModelDelegate {
    
    // MARK: - UI properties (Public)
    public var headerComponent: SBUMessageSearchModule.Header?
    public var listComponent: SBUMessageSearchModule.List?
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.messageSearchTheme)
    public var theme: SBUMessageSearchTheme
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUMessageSearchViewModel?
    public var channel: BaseChannel? { self.viewModel?.channel }
    public var searchResultList: [BaseMessage] { self.viewModel?.searchResultList ?? [] }
    
    /// You can set custom query params for message search.
    public var customMessageSearchQueryParams: MessageSearchQueryParams?
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUMessageSearchViewController(channel:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUMessageSearchViewController(channel:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// Initializer
    /// - Parameter channel: The object of the channel to search for
    required public init(channel: BaseChannel) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channel: channel)
        self.headerComponent = SBUModuleSet.messageSearchModule.headerComponent
        self.listComponent = SBUModuleSet.messageSearchModule.listComponent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.headerComponent?.registerKeyboardNotifications()
        
        self.updateStyles()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// Note: To handle buggy background on view push
        self.navigationController?.view.setNeedsLayout() // force update layout
        self.navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
        
        self.headerComponent?.unregisterKeyboardNotifications()
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        self.theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.viewModel = nil
        self.headerComponent = nil
        self.listComponent = nil
    }
    
    // MARK: - ViewModel
    open func createViewModel(channel: BaseChannel) {
        self.viewModel = SBUMessageSearchViewModel(
            channel: channel,
            params: self.customMessageSearchQueryParams,
            delegate: self
        )
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(delegate: self, theme: self.theme)
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        
        // List component
        self.listComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        if let listComponent = self.listComponent {
            self.view.addSubview(listComponent)
        }
        
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    open override func setupLayouts() {
        listComponent?.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        self.navigationController?.navigationBar.barStyle = self.theme.navigationBarStyle
        
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationBarShadowColor
        )
        
        self.headerComponent?.setupStyles(theme: self.theme)
        self.listComponent?.setupStyles(theme: self.theme)
        
        self.view.backgroundColor = self.theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        if let searchBar = self.headerComponent?.titleView as? UISearchBar {
            self.headerComponent?.updateSearchBarStyle(with: searchBar)
        }
        
        self.listComponent?.reloadTableView()
    }
    
    // MARK: - Search
    /// Performs keyword search
    ///
    /// - Parameters: keyword: A keyword to search for.
    /// - Returns: A `MessageSearchQuery` with the params set.
    public func search(keyword: String) {
        self.viewModel?.search(keyword: keyword)
    }
    
    // MARK: - Action
    
    /// Enters a `SBUGroupChannelViewController` with the selected message.
    /// - Parameters:
    ///   - message: A `BaseMessage` object to load channel from.
    ///   - highlightInfo: An  optional`SBUHighlightInfo` class to have message highlighted.
    ///   - messageListParams:An optional `MessageListParams` params to be used in loading messages.
    public func enterChannel(with message: BaseMessage,
                             highlightInfo: SBUHighlightMessageInfo?,
                             messageListParams: MessageListParams? = nil) {
        // result only has group channel for now.
        guard message.channelType == .group else {
            SBULog.warning("Not a group channel.")
            return
        }
        
        let channelVC = SBUViewControllerSet.GroupChannelViewController.init(
            channelURL: message.channelURL,
            startingPoint: message.createdAt,
            messageListParams: messageListParams
        )
        channelVC.highlightInfo = highlightInfo
        channelVC.useRightBarButtonItem = false
        
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - SBUMessageSearchModuleHeaderDelegate
    open func messageSearchModule(_ headerComponent: SBUMessageSearchModule.Header,
                                  didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func messageSearchModule(_ headerComponent: SBUMessageSearchModule.Header,
                                  didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func messageSearchModule(_ headerComponent: SBUMessageSearchModule.Header,
                                  didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func messageSearchModule(_ headerComponent: SBUMessageSearchModule.Header,
                                  didTapSearch keyword: String) {
        self.search(keyword: keyword)
    }
    
    open func messageSearchModuleDidTapCancel(_ headerComponent: SBUMessageSearchModule.Header) {
        self.onClickBack()
    }
    
    // MARK: - SBUMessageSearchModuleListDelegate
    open func messageSearchModule(_ listComponent: SBUMessageSearchModule.List,
                                  didSelectRowAt indexPath: IndexPath) {
        guard let message = self.listComponent?.message(at: indexPath) else { return }
        // 220523: removed highlightInfo in search result.
//        let keyword = (self.headerComponent?.titleView as? UISearchBar)?.text ?? nil
        let highlightInfo = SBUHighlightMessageInfo(
            keyword: nil,
            messageId: message.messageId,
            updatedAt: message.updatedAt,
            animated: true
        )
        
        self.enterChannel(
            with: message,
            highlightInfo: highlightInfo
        )
    }
    
    open func messageSearchModule(_ listComponent: SBUMessageSearchModule.List,
                                  didDetectPreloadingPosition index: IndexPath) {
        self.viewModel?.loadMore()
    }
    
    open func messageSearchModuleDidSelectRetry(_ listComponent: SBUMessageSearchModule.List) {
        self.viewModel?.loadMore()
    }
    
    // MARK: - SBUMessageSearchModuleListDataSource
    open func messageSearchModule(_ listComponent: SBUMessageSearchModule.List,
                                    searchResultsInTableView tableView: UITableView) -> [BaseMessage] {
        return self.searchResultList
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.description ?? "")
        
        if isBlocker {
            self.listComponent?.updateEmptyView(type: self.searchResultList.isEmpty ? .error : .none)
            self.listComponent?.reloadTableView()
        }
    }
    
    // MARK: - SBUEmptyViewDelegate
    open func didSelectRetry() {
        self.listComponent?.updateEmptyView(type: .none)
        self.viewModel?.loadMore()
    }
    
    // MARK: - SBUMessageSearchViewModelDelegate
    open func searchViewModel(_ viewModel: SBUMessageSearchViewModel,
                              didChangeSearchResults results: [BaseMessage],
                              needsToReload: Bool) {
        let emptyType: EmptyViewType = results.isEmpty ? .noSearchResults : .none
        self.listComponent?.updateEmptyView(type: emptyType)
        guard needsToReload else { return }
        self.listComponent?.reloadTableView()
    }
}
