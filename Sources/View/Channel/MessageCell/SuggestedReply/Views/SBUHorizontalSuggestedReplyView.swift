//
//  SBUHorizontalSuggestedReplyView.swift
//  QuickStart
//
//  Created by Damon Park on 2024/03/30.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This is a horizontal suggested reply view for displaying a list of `options`.
/// - Since: 3.23.0
open class SBUHorizontalSuggestedReplyView: SBUSuggestedReplyView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    
    /// content insets for collectionview
    public var contentInsets: UIEdgeInsets = .init(top: 0, left: 50, bottom: 0, right: 12)
    
    /// item spacing size
    public var itemSpacing: CGFloat = 8
    
    /// ``UICollectionViewFlowLayout`` instance. This is default layout for horizontal collection view.
    public lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = self.itemSpacing
        layout.sectionInset = .zero
        return layout
    }()

    /// ``UICollectionView`` instance for displaying horizontal suggested reply options.
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: self.layout
        )
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            HorizontalSuggestedReplyViewCell.self,
            forCellWithReuseIdentifier: HorizontalSuggestedReplyViewCell.sbu_className
        )
        return collectionView
    }()
    
    var items = [String]()
    
    // MARK: - Sendbird UIKit Life Cycle
    
    open override func setupViews() {
        super.setupViews()
        
        self.backgroundColor = .clear
        self.addSubview(collectionView)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.clipsToBounds = false
        self.clipsToBounds = false
    }
    
    open override func setupLayouts() {
        super.setupLayouts()

        self.collectionView.contentInset = self.contentInsets
        
        self.sbu_constraint(height: HorizontalSuggestedReplyViewCell.cellHeight)
        self.collectionView.sbu_constraint(height: HorizontalSuggestedReplyViewCell.cellHeight)
        self.collectionView.sbu_constraint(equalTo: self, left: -12, right: -12, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.collectionView.backgroundColor = .clear
        
        if self.collectionView.currentLayoutDirection.isRTL {
            self.collectionView.transform = .init(scaleX: -1, y: 1)
        }
    }
    
    /// This is configure method.
    /// - Parameters:
    ///   - configuration: suggested reply view parameters
    ///   - delegate: delegate for event handle.
    open override func configure(
        with configuration: SBUSuggestedReplyViewParams,
        delegate: SBUSuggestedReplyViewDelegate? = nil
    ) {
        super.configure(with: configuration, delegate: delegate)
        self.items = configuration.replyOptions
        self.collectionView.reloadData()
    }
    
    func option(at index: Int) -> String? {
        guard self.items.count > index else { return nil }
        return self.items[index]
    }
    
    // MARK: - collectionView delegate & datasource methods
    
    open func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return (self.params?.replyOptions.count ?? 0)
    }
    
    open func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let option = self.option(at: indexPath.row), let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HorizontalSuggestedReplyViewCell.sbu_className,
            for: indexPath
        ) as? HorizontalSuggestedReplyViewCell else {
            return UICollectionViewCell()
        }
        
        if cell.currentLayoutDirection.isRTL {
            cell.contentView.transform = .init(scaleX: -1, y: 1)
        }
        
        cell.configure(with: option, delegate: self)
        return cell
    }
    
    open func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let value = self.items[safe: indexPath.row] else { return .zero }
        let size = (value as NSString).size(withAttributes: [NSAttributedString.Key.font: SBUTheme.messageCellTheme.userMessageFont])
        
        return CGSize(
            width: (15 + size.width + 15).rounded(.up),
            height: 30
        )
    }
}

/// This is a horizontal suggested reply view cell for displaying a value of `options`.
/// - Since: 3.23.0
open class HorizontalSuggestedReplyViewCell: SBUCollectionViewCell {
    
    /// Value to set the height of the cell.
    public static var cellHeight: CGFloat = 40.0
    
    /// Use option view as subview.
    public var optionView = SBUHorizontalSuggestedReplyOptionView(frame: .zero)
    
    /// This is cell configure method.
    /// - Parameters:
    ///   - text: option value
    ///   - delegate: action event delegate
    func configure(
        with text: String,
        delegate: SBUSuggestedReplyOptionViewDelegate
    ) {
        self.optionView.configure(with: text, delegate: delegate)
    }
    
    // MARK: - View Lifecycle
    
    open override func setupViews() {
        super.setupViews()

        self.contentView.addSubview(self.optionView)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
    }

    open override func setupLayouts() {
        super.setupLayouts()

        self.optionView.sbu_constraint(equalTo: self.contentView, left: 0, right: 0, top: 0, bottom: 0)
    }
    
}
