//
//  SBUMessageSearchViewController.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

/// ViewController handling a message search.
///
/// - Since: 2.1.0
@objcMembers
open class SBUMessageSearchViewController: SBUBaseViewController {
    
    private let defaultSearchLimit: UInt = 20
    
    // MARK: - Properties (Public)
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme.statusBarStyle
    }
    
    public var theme: SBUMessageSearchTheme = SBUTheme.messageSearchTheme

    public var channel: SBDBaseChannel? {
        didSet { self.createViewModel() }
    }
    
    /// This param will be used on entering a channel from selecting an item from the search results.
    public var messageListParams: SBDMessageListParams? = nil
    
    /// You can set custom query params for message search.
    /// `keyword`, `channelUrl`, `order` is reserved in SDK. (The SDK value will override the custom values)
    /// `messageFromTs` is set to user's channel joined ts as a default. You can set this value to `0` to search for all previous messages as well.
    /// `limit` will be set to default value of `defaultSearchLimit` in case if it's set to 0 or smaller value.
    public var customMessageSearchQueryBuilder: ((SBDMessageSearchQueryBuilder) -> Void)? = nil
    
    /// The search result list. Use this list to locate the `SBDBaseMessage` object from the `tableView`.
    public var searchResultList: [SBDBaseMessage] {
        return self.messageSearchViewModel?.searchResultList ?? []
    }
    
    // MARK: - Properties (View)
    
    /// Message search result's cell.
    public var messageSearchResultCell: SBUMessageSearchResultCell?
    
    public private(set) var searchBar: UIView! {
        didSet {
            self.navigationItem.titleView = self.searchBar
        }
    }
    
    public private(set) lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.keyboardDismissMode = .onDrag
        tableView.alwaysBounceVertical = false
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        
        return tableView
    }()
    
    public private(set) lazy var emptyView: UIView? = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        
        return emptyView
    }()
    
    // MARK: - Properties
    
    private lazy var defaultSearchBar: UISearchBar = {
        let searchBar = UISearchBar()
        
        searchBar.setPositionAdjustment(UIOffset(horizontal: 8, vertical: 0), for: .search)
        searchBar.setPositionAdjustment(UIOffset(horizontal: -4, vertical: 0), for: .clear)
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.layer.cornerRadius = 20
            searchBar.searchTextField.layer.masksToBounds = true
        } else {
            if let textfield = searchBar.value(forKey: "searchField") as? UITextField,
                let backgroundview = textfield.subviews.first {
                backgroundview.layer.cornerRadius = 20
                backgroundview.clipsToBounds = true
            }
        }
        
        self.setupSearchBarStyle(searchBar: searchBar)
        return searchBar
    }()
    
    private var messageSearchViewModel: SBUMessageSearchViewModel? {
        willSet { self.disposeViewModel() }
        didSet { self.bindViewModel() }
    }
    
    // MARK: - Constructor
    
    @available(*, unavailable, renamed: "SBUMessageSearchViewController(channel:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUMessageSearchViewController(channel:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }
    
    public init(channel: SBDBaseChannel) {
        self.channel = channel
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        self.createViewModel()
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableCancelButton()
        
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /// Note: To handle buggy background on view push
        self.navigationController?.view.setNeedsLayout() // force update layout
        self.navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }
    
    deinit {
        self.disposeViewModel()
    }
    
    open override func loadView() {
        super.loadView()
        
        if self.searchBar == nil {
            self.searchBar = self.defaultSearchBar
        }
        
        self.navigationItem.titleView = self.searchBar
        
        self.tableView.backgroundView = self.emptyView
        self.view.addSubview(self.tableView)
        
        if self.messageSearchResultCell == nil {
            self.register(messageSearchResultCell: SBUMessageSearchResultCell())
        }
        
        self.setupAutolayout()
        
        self.setupStyles()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }
    
    // MARK: - View Binding
    
    private func createViewModel() {
        guard let channel = self.channel else { return }
        self.messageSearchViewModel = SBUMessageSearchViewModel(channel: channel)
    }
    
    private func bindViewModel() {
        guard let messageSearchViewModel = self.messageSearchViewModel else { return }
        
        messageSearchViewModel.loadingObservable.observe { [weak self] loading in
            guard let self = self else { return }
            
            if loading {
                self.shouldShowLoadingIndicator()
                
                if let emptyView = self.emptyView as? SBUEmptyView {
                    emptyView.reloadData(.none)
                }
            } else {
                self.shouldDismissLoadingIndicator()
            }
        }
        
        messageSearchViewModel.errorObservable.observe { [weak self] error in
            guard let self = self else { return }
            
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(self.searchResultList.isEmpty ? .error : .none)
            }
            
            self.errorHandler(error)
        }
        
        messageSearchViewModel.resultListChangedObservable.observe { [weak self] _ in
            guard let self = self else { return }
            
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(self.searchResultList.isEmpty ? .noSearchResults : .none)
            }
            
            self.tableView.reloadData()
        }
    }
    
    private func disposeViewModel() {
        self.messageSearchViewModel?.dispose()
    }

    // MARK: - Error handling
    private func errorHandler(_ error: SBDError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    @available(*, deprecated, message: "deprecated in 2.1.12", renamed: "errorHandler")
    open func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
    
    
    // MARK: - Customization
    
    /// Used to register a custom cell as a search result cell based on `SBUMessageSearchResultCell`.
    ///
    /// - Parameters:
    ///   - messageSearchResultCell: Customized search result cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(messageSearchResultCell: SBUMessageSearchResultCell, nib: UINib? = nil) {
        self.messageSearchResultCell = messageSearchResultCell
        
        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: messageSearchResultCell.sbu_className)
        } else {
            self.tableView.register(type(of: messageSearchResultCell), forCellReuseIdentifier: messageSearchResultCell.sbu_className)
        }
    }

    /// Performs keyword search
    ///
    /// - Parameters: keyword: A keyword to search for.
    /// - Returns: A `SBDMessageSearchQuery` with the params set.
    public func search(keyword: String) {
        self.searchBar.resignFirstResponder()
        self.enableCancelButton()
        
        let query = SBDMessageSearchQuery.create { builder in
            guard let channel = self.channel else { fatalError("Requires a channel object for message search") }
            
            /// Default search from ts.
            /// Only search for messages after a user has joined.
            if let groupChannel = self.channel as? SBDGroupChannel {
                // FIXME: - Change to joinedTs when core SDK is ready
                builder.messageTimestampFrom = groupChannel.invitedAt
            }
            
            self.customMessageSearchQueryBuilder?(builder)
            
            if builder.limit <= 0 {
                /// Default limit
                builder.limit = self.defaultSearchLimit
            }
            
            /// Below are reserved params.
            builder.channelUrl = channel.channelUrl
            builder.keyword = keyword
            builder.order = .timeStamp
        }
        
        self.messageSearchViewModel?.search(keyword: keyword, query: query)
    }
    
    /// This is to pop or dismiss (depending on current view controller) the search view controller.
    public override func onClickBack() {
        self.searchBar.resignFirstResponder()
        super.onClickBack()
    }
    
    // MARK: - Style & Layout
    
    open override func setupStyles() {
        self.theme = SBUTheme.messageSearchTheme
        
        self.navigationController?.navigationBar.barStyle = self.theme.navigationBarStyle
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.from(color: theme.navigationBarTintColor),
                                                                    for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage.from(color: theme.navigationBarShadowColor)
        
        self.view.backgroundColor = self.theme.backgroundColor
        self.tableView.backgroundColor = self.theme.backgroundColor
        
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.setupStyles()
        }
        
        if let searchBar = self.searchBar as? UISearchBar {
            self.setupSearchBarStyle(searchBar: searchBar)
        }
    }
    
    open override func setupAutolayout() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                self.tableView.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 1.0)
            ])
        } else {
            NSLayoutConstraint.activate([
                self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor)
            ])
        }
    }
    
    public func setupSearchBarStyle(searchBar: UISearchBar) {
        searchBar.subviews.first?.backgroundColor = self.theme.navigationBarTintColor
        
        searchBar.setImage(
            SBUIconSetType.iconSearch.image(
                with: self.theme.searchIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .search,
            state: .normal
        )
        
        searchBar.setImage(
            SBUIconSetType.iconRemove.image(
                with: self.theme.clearIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSizeMedium
            ),
            for: .clear,
            state: .normal
        )
        
        searchBar.placeholder = SBUStringSet.Search
        searchBar.barTintColor = self.theme.cancelButtonTintColor
        
        // Note: https://stackoverflow.com/a/28499827
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.textColor = self.theme.searchTextColor
            searchBar.searchTextField.font = self.theme.searchTextFont
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
                string: SBUStringSet.Search,
                attributes: [.foregroundColor: self.theme.searchPlaceholderColor,
                             .font: self.theme.searchTextFont]
            )
            searchBar.searchTextField.backgroundColor = self.theme.searchTextBackgroundColor
        } else {
            if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = self.theme.searchTextColor
                textfield.font = self.theme.searchTextFont
                textfield.attributedPlaceholder = NSAttributedString(
                    string: SBUStringSet.Search,
                    attributes: [.foregroundColor: self.theme.searchPlaceholderColor,
                                 .font: self.theme.searchTextFont]
                )
                textfield.backgroundColor = self.theme.searchTextBackgroundColor
            }
        }
    }
    
    /// Retrives the `SBDBaseMessage` object from the given `IndexPath` of the tableView.
    /// - Parameter indexPath: `IndexPath` of which you want to retrieve the `SBDMessage` object.
    /// - Returns: `SBDBaseMessage` object of the corresponding `IndexPath`, or `nil` if the message can't be found.
    /// - Since: 2.1.5
    open func message(at indexPath: IndexPath) -> SBDBaseMessage? {
        let row = indexPath.row
        guard row >= 0 && row < self.searchResultList.count else { return nil }
        
        return self.searchResultList[row]
    }
    
    func keyboardDidHide(_ notification: Notification) {
        self.enableCancelButton()
    }
    
    private func enableCancelButton() {
        // Note: https://stackoverflow.com/a/43609059
        if let searchBar = self.searchBar as? UISearchBar,
           let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton{
            cancelButton.isEnabled = true
        }
    }
    
    // MARK: - Action
    
    
    /// Enters a `SBUChannelViewController` with the selected message.
    /// - Parameters:
    ///   - message: A `SBDBaseMessage` object to load channel from.
    ///   - highlightInfo: An  optional`SBUHighlightInfo` class to have message highlighted.
    ///   - messageListParams:An optional `SBDMessageListParams` params to be used in loading messages.
    public func enterChannel(with message: SBDBaseMessage,
                             highlightInfo: SBUHighlightMessageInfo?,
                             messageListParams: SBDMessageListParams? = nil) {
        // result only has group channel for now.
        guard message.channelType == CHANNEL_TYPE_GROUP else {
            SBULog.warning("Not a group channel.")
            return
        }
        
        let channelVc = SBUChannelViewController(channelUrl: message.channelUrl,
                                                 startingPoint: message.createdAt,
                                                 messageListParams: messageListParams)
        channelVc.highlightInfo = highlightInfo
        channelVc.useRightBarButtonItem = false
        
        self.navigationController?.pushViewController(channelVc, animated: true)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension SBUMessageSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultList.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = self.messageSearchResultCell?.sbu_className ?? SBUMessageSearchResultCell.sbu_className
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                as? SBUMessageSearchResultCell else { fatalError() }
        
        guard let baseMessage = self.message(at: indexPath) else { return cell }

        cell.configure(message: baseMessage)
        cell.setupStyles()
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let message = self.message(at: indexPath) else { return }
        
        let highlightInfo = SBUHighlightMessageInfo(messageId: message.messageId,
                                                    updatedAt: message.updatedAt)
        self.enterChannel(with: message,
                          highlightInfo: highlightInfo,
                          messageListParams: self.messageListParams)
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row >= self.searchResultList.count - 1 else { return }
        
        self.messageSearchViewModel?.loadMore()
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}

// MARK: - UISearchBarDelegate
extension SBUMessageSearchViewController: UISearchBarDelegate {
    open func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.enableCancelButton()
    }

    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.onClickBack()
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        self.search(keyword: keyword)
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBUMessageSearchViewController: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.none)
        }
        self.messageSearchViewModel?.searchAgain()
    }
}

extension SBUMessageSearchViewController: LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        SBULoading.start()
        return true
    }
    
    open func shouldDismissLoadingIndicator() {
        SBULoading.stop()
    }
}
