//
//  SBUMessageSearchModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the list component in the message search.
public protocol SBUMessageSearchModuleListDelegate: SBUCommonDelegate {
    /// Called when the search result cell was selected in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUMessageSearchModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func messageSearchModule(_ listComponent: SBUMessageSearchModule.List, didSelectRowAt indexPath: IndexPath)
    
    /// Called when the tableView detected preloading position in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUMessageSearchModule.List` object.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func messageSearchModule(_ listComponent: SBUMessageSearchModule.List, didDetectPreloadingPosition index: IndexPath)

    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUMessageSearchModule.List` object.
    func messageSearchModuleDidSelectRetry(_ listComponent: SBUMessageSearchModule.List)
}

/// Methods to get data source for the list component in the message search.
public protocol SBUMessageSearchModuleListDataSource: AnyObject {
    /// Ask the data source to return the search result list.
    /// - Parameters:
    ///    - listComponent: `SBUMessageSearchModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `BaseMessage` object.
    func messageSearchModule(_ listComponent: SBUMessageSearchModule.List, searchResultsInTableView tableView: UITableView) -> [BaseMessage]
}

extension SBUMessageSearchModule {
    
    /// A module component that represent the list of `SBUMessageSearchModule`.
    @objc(SBUMessageSearchModuleList)
    @objcMembers open class List: UIView {
        
        // MARK: - UI properties (Public)
        
        /// The table view to show the list of searched messages.
        public var tableView = UITableView()
        
        /// A view that shows when there is no searched messages.
        public var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        
        /// The search result cell for `SBUMessageSearchResultCell` object. Use `register(resultCell:nib:)` to update.
        public var resultCell: SBUMessageSearchResultCell?

        /// The object that is used as the theme of the list component. The theme must adopt the `SBUMessageSearchTheme` class.
        public var theme: SBUMessageSearchTheme?
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        private let searchCellHeight: CGFloat = 76.0
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUMessageSearchModuleListDelegate`.
        public weak var delegate: SBUMessageSearchModuleListDelegate?
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUMessageSearchModuleListDataSource`.
        public weak var dataSource: SBUMessageSearchModuleListDataSource?
        
        /// The search result list object from `messageSearchModule(_:searchResultsInTableView:)` data source method.
        public var resultList: [BaseMessage] {
            self.dataSource?.messageSearchModule(self, searchResultsInTableView: self.tableView) ?? []
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUMessageSearchModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUMessageSearchModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// This function configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUMessageSearchModuleListDelegate` type listener
        ///   - dataSource: `SBUMessageSearchModuleListDataSource` type
        ///   - theme: `SBUMessageSearchTheme` object
        open func configure(delegate: SBUMessageSearchModuleListDelegate,
                            dataSource: SBUMessageSearchModuleListDataSource,
                            theme: SBUMessageSearchTheme) {
            
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            // empty view
            if self.emptyView == nil {
                self.emptyView = self.defaultEmptyView
            }
            
            // tableview
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.bounces = false
            self.tableView.alwaysBounceVertical = false
            self.tableView.separatorStyle = .none
            self.tableView.backgroundView = self.emptyView
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.sectionHeaderHeight = 0
            self.addSubview(self.tableView)
            
            // register cell
            if self.resultCell == nil {
                self.register(resultCell: SBUMessageSearchResultCell())
            }
        }
        
        /// Sets layouts of the views in the list component.
        open func setupLayouts() {
            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUMessageSearchTheme` object
        open func setupStyles(theme: SBUMessageSearchTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
            
            (self.emptyView as? SBUEmptyView)?.setupStyles()
        }

        // MARK: - TableView: Cell
        
        /// Registers a custom cell as a search result cell based on `SBUMessageSearchResultCell`.
        /// - Parameters:
        ///   - channelCell: Customized search result cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom search result cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(resultCell: MyResultCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        public func register(resultCell: SBUMessageSearchResultCell, nib: UINib? = nil) {
            self.resultCell = resultCell
            
            if let nib = nib {
                self.tableView.register(
                    nib,
                    forCellReuseIdentifier: resultCell.sbu_className
                )
            } else {
                self.tableView.register(
                    type(of: resultCell),
                    forCellReuseIdentifier: resultCell.sbu_className
                )
            }
        }
        
        /// Configures cell for a particular row.
        /// - Parameters:
        ///   - cell: `UITableViewCell` object
        ///   - indexPath: An index path representing the `searchResultCell`
        open func configureCell(_ cell: UITableViewCell?, indexPath: IndexPath) {
            guard let defaultCell = cell as? SBUMessageSearchResultCell,
            let baseMessage = self.message(at: indexPath) else { return }
            
            defaultCell.configure(message: baseMessage)
            defaultCell.setupStyles()
        }
        
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        // MARK: - EmptyView
        public func updateEmptyView(type: EmptyViewType) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(type)
            }
        }
        
        // MARK: - Common
        
        /// Retrives the `BaseMessage` object from the given `IndexPath` of the tableView.
        /// - Parameter indexPath: `IndexPath` of which you want to retrieve the `Message` object.
        /// - Returns: `BaseMessage` object of the corresponding `IndexPath`, or `nil` if the message can't be found.
        open func message(at indexPath: IndexPath) -> BaseMessage? {
            let row = indexPath.row
            guard row >= 0 && row < self.resultList.count else { return nil }
            
            return self.resultList[row]
        }
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBUMessageSearchModule.List: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noSearchResults)
        }
        
        SBULog.info("[Request] Retry load channel list")
        self.delegate?.messageSearchModuleDidSelectRetry(self)
    }
}

// MARK: - UITableView relations
extension SBUMessageSearchModule.List: UITableViewDataSource, UITableViewDelegate {
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultList.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if let resultCell = self.resultCell {
            cell = tableView.dequeueReusableCell(withIdentifier: resultCell.sbu_className)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: SBUMessageSearchResultCell.sbu_className)
        }
        
        cell?.selectionStyle = .none
        
        self.configureCell(cell, indexPath: indexPath)
        
        return cell ?? UITableViewCell()
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.messageSearchModule(self, didSelectRowAt: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row >= self.resultList.count - 1 else { return }
        
        self.delegate?.messageSearchModule(self, didDetectPreloadingPosition: indexPath)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.searchCellHeight
    }
}
