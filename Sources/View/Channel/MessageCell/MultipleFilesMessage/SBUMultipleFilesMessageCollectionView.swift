//
//  SBUMultipleFilesMessageCollectionView.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2023/09/07.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

/// CollectionView that shows the files of a multiple files message.
/// - Since: 3.10.0
open class SBUMultipleFilesMessageCollectionView: UICollectionView, SBUViewLifeCycle {
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme        
    
    public var cornerRadius: CGFloat = 1
    
    open func configure(
        delegate: UICollectionViewDelegate,
        dataSource: UICollectionViewDataSource,
        theme: SBUMessageCellTheme? = nil,
        cornerRadius: CGFloat
    ) {
        self.delegate = delegate
        self.dataSource = dataSource
        if let theme = theme {
            self.theme = theme
        }
        
        self.cornerRadius = cornerRadius
        
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
        self.setupStyles()
        
        self.reloadData()
    }
    
    open func setupViews() {
        self.register(
            SBUMultipleFilesMessageCollectionViewCell.self,
            forCellWithReuseIdentifier: SBUMultipleFilesMessageCollectionViewCell.sbu_className
        )
    }
    
    open func setupLayouts() { }
    
    open func setupStyles() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = self.cornerRadius // Constants.collectionViewCornerRadius
        self.layer.masksToBounds = true
    }
    
    open func setupActions() { }
    
    open func updateLayouts() { }
    
    open func updateStyles() { }
}
