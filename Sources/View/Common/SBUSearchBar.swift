//
//  SBUSearchBar.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 5/17/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

/// A class that displays a search bar in SendbirdUIKit.
/// - Since: 3.28.0
open class SBUSearchBar: UISearchBar, SBUViewLifeCycle {
    var theme: SBUMessageSearchTheme?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required public init() {
        super.init(frame: .zero)
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
    
    // MARK: SBUView lifecycle
    open func setupViews() {
        self.showsCancelButton = true
    }
    
    open func setupLayouts() {
        self.setPositionAdjustment(UIOffset(horizontal: 8, vertical: 0), for: .search)
        self.setPositionAdjustment(UIOffset(horizontal: -4, vertical: 0), for: .clear)
    }
    
    open func setupStyles() {
        if #available(iOS 13.0, *) {
            self.searchTextField.layer.cornerRadius = 20
            self.searchTextField.layer.masksToBounds = true
        } else {
            if let textfield = self.value(forKey: "searchField") as? UITextField,
               let backgroundview = textfield.subviews.first {
                backgroundview.layer.cornerRadius = 20
                backgroundview.clipsToBounds = true
            }
        }
    }
    
    open func updateLayouts() { }
    
    open func updateStyles() { }
    
    open func setupActions() { }
    
    open func configure(delegate: UISearchBarDelegate, theme: SBUMessageSearchTheme?) {
        self.delegate = delegate
        self.theme = theme
        
        // MOD TODO: must remove `updateSearchBarStyle(with:)` before enabling the below code.
//        self.subviews.first?.backgroundColor = self.theme?.navigationBarTintColor
//        
//        self.setImage(
//            SBUIconSetType.iconSearch.image(
//                with: self.theme?.searchIconTintColor,
//                to: SBUIconSetType.Metric.defaultIconSize
//            ),
//            for: .search,
//            state: .normal
//        )
//        
//        self.setImage(
//            SBUIconSetType.iconRemove.image(
//                with: self.theme?.clearIconTintColor,
//                to: SBUIconSetType.Metric.defaultIconSizeMedium
//            ),
//            for: .clear,
//            state: .normal
//        )
//        
//        self.placeholder = SBUStringSet.Search
//        self.barTintColor = self.theme?.cancelButtonTintColor
//        
//        // Note: https://stackoverflow.com/a/28499827
//        if let theme = self.theme {
//            if #available(iOS 13.0, *) {
//                self.searchTextField.textColor = theme.searchTextColor
//                self.searchTextField.font = theme.searchTextFont
//                self.searchTextField.attributedPlaceholder = NSAttributedString(
//                    string: SBUStringSet.Search,
//                    attributes: [.foregroundColor: theme.searchPlaceholderColor,
//                                 .font: theme.searchTextFont]
//                )
//                self.searchTextField.backgroundColor = theme.searchTextBackgroundColor
//            } else {
//                if let textfield = self.value(forKey: "searchField") as? UITextField {
//                    textfield.textColor = theme.searchTextColor
//                    textfield.font = theme.searchTextFont
//                    textfield.attributedPlaceholder = NSAttributedString(
//                        string: SBUStringSet.Search,
//                        attributes: [.foregroundColor: theme.searchPlaceholderColor,
//                                     .font: theme.searchTextFont]
//                    )
//                    textfield.backgroundColor = theme.searchTextBackgroundColor
//                }
//            }
//        }
    }
}
