//
//  SBUMessageSearchModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in message search module.
public protocol SBUMessageSearchModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUMessageSearchModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func messageSearchModule(_ headerComponent: SBUMessageSearchModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUMessageSearchModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func messageSearchModule(_ headerComponent: SBUMessageSearchModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUMessageSearchModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func messageSearchModule(_ headerComponent: SBUMessageSearchModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// This function calls when did click search button.
    /// - Parameters:
    ///   - headerComponent: `SBUMessageSearchModule.Header` object
    ///   - keyword: search keyword
    func messageSearchModule(_ headerComponent: SBUMessageSearchModule.Header, didTapSearch keyword: String)
    
    /// This function calls when did click cancel button.
    /// - Parameters:
    ///   - headerComponent: `SBUMessageSearchModule.Header` object
    func messageSearchModuleDidTapCancel(_ headerComponent: SBUMessageSearchModule.Header)
}

extension SBUMessageSearchModule {
    
    /// A module component that represent the header of `SBUMessageSearchModule`.
    /// - This class consists of titleView, leftBarButton, and rightBarButton.
    @objcMembers open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        ///
        /// The default value for this object is set with `UISearchBar`.
        /// - NOTE: When the value is updated, `messageSearchModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet { self.delegate?.messageSearchModule(self, didUpdateTitleView: self.titleView) }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        ///
        /// The default value for this object is not set. If you want to set this object, you need to override `setupViews` function and implement.
        /// - NOTE: When the value is updated, `messageSearchModule(_:didUpdateLeftItem:)` delegate function is called
        public var leftBarButton: UIBarButtonItem? {
            didSet { self.delegate?.messageSearchModule(self, didUpdateLeftItem: self.leftBarButton) }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        ///
        /// The default value for this object is not set. If you want to set this object, you need to override `setupViews` function and implement.
        /// - NOTE: When the value is updated, `messageSearchModule(_:didUpdateRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet { self.delegate?.messageSearchModule(self, didUpdateRightItem: self.rightBarButton) }
        }
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUMessageSearchTheme` class.
        public var theme: SBUMessageSearchTheme?
        
        // MARK: - UI properties (Private)
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
            
            self.updateSearchBarStyle(with: searchBar)
            return searchBar
        }()
        
        // MARK: - Logic properties (Public)
        
        /// The object that acts as the delegate of the header component.
        /// 
        /// The delegate must adopt the `SBUMessageSearchModuleHeaderDelegate`.
        public weak var delegate: SBUMessageSearchModuleHeaderDelegate?
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUMessageSearchModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUMessageSearchModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
            unregisterKeyboardNotifications()
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUMessageSearchModuleHeaderDelegate` type listener
        ///   - theme: `SBUMessageSearchTheme` object
        open func configure(delegate: SBUMessageSearchModuleHeaderDelegate,
                            theme: SBUMessageSearchTheme) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the header component when it needs.
        open func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultSearchBar
            }
        }
        
        /// Sets layouts of the views in the header component.
        open func setupLayouts() { }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUMessageSearchTheme` class.
        open func setupStyles(theme: SBUMessageSearchTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            if let titleView = self.titleView as? SBUNavigationTitleView {
                titleView.setupStyles()
            }
            
            self.enableCancelButton()
        }
        
        /// Updates style of the searchBar in the header component with the `searchBar`.
        /// - Parameter searchBar: The object that is used as the searchBar of the header component.
        open func updateSearchBarStyle(with searchBar: UISearchBar) {
            searchBar.subviews.first?.backgroundColor = self.theme?.navigationBarTintColor
            
            searchBar.setImage(
                SBUIconSetType.iconSearch.image(
                    with: self.theme?.searchIconTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .search,
                state: .normal
            )
            
            searchBar.setImage(
                SBUIconSetType.iconRemove.image(
                    with: self.theme?.clearIconTintColor,
                    to: SBUIconSetType.Metric.defaultIconSizeMedium
                ),
                for: .clear,
                state: .normal
            )
            
            searchBar.placeholder = SBUStringSet.Search
            searchBar.barTintColor = self.theme?.cancelButtonTintColor
            
            // Note: https://stackoverflow.com/a/28499827
            if let theme = self.theme {
                if #available(iOS 13.0, *) {
                    searchBar.searchTextField.textColor = theme.searchTextColor
                    searchBar.searchTextField.font = theme.searchTextFont
                    searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
                        string: SBUStringSet.Search,
                        attributes: [.foregroundColor: theme.searchPlaceholderColor,
                                     .font: theme.searchTextFont]
                    )
                    searchBar.searchTextField.backgroundColor = theme.searchTextBackgroundColor
                } else {
                    if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                        textfield.textColor = theme.searchTextColor
                        textfield.font = theme.searchTextFont
                        textfield.attributedPlaceholder = NSAttributedString(
                            string: SBUStringSet.Search,
                            attributes: [.foregroundColor: theme.searchPlaceholderColor,
                                         .font: theme.searchTextFont]
                        )
                        textfield.backgroundColor = theme.searchTextBackgroundColor
                    }
                }
            }
        }
        
        // MARK: - Common
        
        /// Chages enable status of the cancel button.
        public func enableCancelButton() {
            // Note: https://stackoverflow.com/a/43609059
            if let searchBar = self.titleView as? UISearchBar,
               let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
        
        // MARK: - Keyboard
        
        /// Registers keyboard notification when the keyboard did hide.
        public func registerKeyboardNotifications() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(enableCancelButton),
                name: UIResponder.keyboardDidHideNotification,
                object: nil
            )
        }
        
        /// Unregisters keyboard notification.
        public func unregisterKeyboardNotifications() {
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// MARK: - UISearchBarDelegate
extension SBUMessageSearchModule.Header: UISearchBarDelegate {
    open func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.enableCancelButton()
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        self.delegate?.messageSearchModuleDidTapCancel(self)
    }
    
    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let keyword = searchBar.text else { return }
        
        self.titleView?.resignFirstResponder()
        self.enableCancelButton()
        
        self.delegate?.messageSearchModule(self, didTapSearch: keyword)
    }
}
