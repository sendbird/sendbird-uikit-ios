//
//  SBUMultipleFilesMessageCell.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2023/07/21.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// A message cell that displays a MultipleFilesMessage.
/// - Since: 3.10.0
open class SBUMultipleFilesMessageCell: SBUContentBaseMessageCell, UICollectionViewDelegate, UICollectionViewDataSource {
    public var multipleFilesMessage: MultipleFilesMessage? {
        self.message as? MultipleFilesMessage
    }
    
    /// The view that contains the collectionView.
    public var containerView = UIView()
    
    /// The view that displays multiple images.
    public lazy var collectionView: SBUMultipleFilesMessageCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        
        let collectionview = SBUMultipleFilesMessageCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.isScrollEnabled = false
        
        return collectionview
    }()
    
    /// The height constraint for the collectionView.
    public private(set) var collectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Action
    /// The closure for selection gesture of the specific file at `indexPath`
    public var fileSelectHandler: ((_ fileInfo: UploadedFileInfo, _ index: Int) -> Void)?
    
    /// An array of indices of files that keeps track of which files are finished being uploaded.
    /// When a file uploading is complete, the file's index is added to this array
    /// via `reloadUpdatedTableViewRows()`.
    var uploadedIndices = [Int]()
    
    // Constants
    struct Constants {
        static let bubblePadding = 4.0
        static let collectionViewCornerRadius = 12.0
        static let collectionViewItemSpacing = 4.0
        static let collectionViewLineSpacing = 4.0
        static let collectionViewCellCornerRadius = 6.0
    }

    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()

        // + ------------------- +
        // | containerView       |
        // + ------------------- +
        // | reactionView        |
        // + ------------------- +
        
        // Set up collectionView.

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            SBUMultipleFilesMessageCollectionViewCell.self,
            forCellWithReuseIdentifier: SBUMultipleFilesMessageCollectionViewCell.sbu_className
        )
        collectionView.backgroundColor = theme.leftBackgroundColor
        
        containerView.addSubview(collectionView)

        self.mainContainerView.setVStack([
            self.containerView,
            self.reactionView
        ])
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
    
        self.mainContainerView
            .sbu_constraint(width: SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize.width)
        
        self.collectionViewHeightConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: 0)
        self.collectionViewHeightConstraint.isActive = true
        
        let bubblePadding = Constants.bubblePadding
        self.collectionView.sbu_constraint(
            equalTo: self.containerView,
            left: bubblePadding,
            right: bubblePadding,
            top: bubblePadding,
            bottom: bubblePadding
        )
        
        self.layoutIfNeeded()
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.mainContainerView.rightBackgroundColor = self.theme.leftBackgroundColor
        self.mainContainerView.rightPressedBackgroundColor = self.theme.leftPressedBackgroundColor
        self.mainContainerView.setupStyles()
        
        #if SWIFTUI
        if self.viewConverter.multipleFilesMessage.entireContent != nil {
            self.mainContainerView.setTransparentBackgroundColor()
        }
        #endif
    }
    
    open override func setupActions() {
        super.setupActions()
        
        self.containerView.addGestureRecognizer(self.contentLongPressRecognizer)
    }
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let configuration = configuration as? SBUMultipleFilesMessageCellParams else { return }
      
        self.useReaction = configuration.useReaction
        self.enableEmojiLongPress = configuration.enableEmojiLongPress
        self.useQuotedMessage = configuration.useQuotedMessage
        self.useThreadInfo = configuration.useThreadInfo
      
        super.configure(with: configuration)
        
        // Set up collectionView.
        #if SWIFTUI
        if self.configuration?.isThreadMessage == false {
            if self.applyViewConverter(.multipleFilesMessage) {
                return
            }
        } else {
            if self.applyViewConverterForMessageThread(.multipleFilesMessage) {
                return
            }
        }
        #endif
        self.collectionView.configure(
            delegate: self,
            dataSource: self,
            theme: self.theme,
            cornerRadius: Constants.collectionViewCornerRadius
        )
        self.collectionView.layoutIfNeeded()
        self.collectionViewHeightConstraint.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
    }
    
    public override func resetMainContainerViewLayer() {
        #if SWIFTUI
        if self.viewConverter.multipleFilesMessage.entireContent != nil {
            return
        }
        #endif
        super.resetMainContainerViewLayer()
    }
    
    // MARK: - Action
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension SBUMultipleFilesMessageCell: UICollectionViewDelegateFlowLayout {
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SBUMultipleFilesMessageCollectionViewCell.sbu_className,
            for: indexPath
        ) as? SBUMultipleFilesMessageCollectionViewCell,
              let multipleFilesMessage = multipleFilesMessage else {
            return UICollectionViewCell()
        }
        
        // Manipulate current index.
        var numberOfFiles = 0
        
        if multipleFilesMessage.files.isEmpty {
            let param = multipleFilesMessage.messageParams as? MultipleFilesMessageCreateParams
            numberOfFiles = param?.uploadableFileInfoList.count ?? 0
        } else {
            numberOfFiles = multipleFilesMessage.files.count
        }
        
        guard let modifiedIndex = modifyIndex(numberOfFiles: numberOfFiles, originalIndex: indexPath[1]) else {
            return cell
        }
        
        // Configure cell.
        var uploadableFileInfo: UploadableFileInfo?
        var uploadedFileInfo: UploadedFileInfo?
        
        var showOverlay = true
        
        if multipleFilesMessage.files.isEmpty {
            let param = multipleFilesMessage.messageParams as? MultipleFilesMessageCreateParams
            uploadableFileInfo = param?.uploadableFileInfoList[modifiedIndex]
            
            let item = indexPath.row
            showOverlay = !self.uploadedIndices.contains(item)
        } else {
            uploadedFileInfo = multipleFilesMessage.files[modifiedIndex]
            showOverlay = false
        }
        
        cell.configure(
            uploadableFileInfo: uploadableFileInfo,
            uploadedFileInfo: uploadedFileInfo,
            requestId: multipleFilesMessage.requestId,
            index: modifiedIndex,
            imageCornerRadius: 6,
            showOverlay: showOverlay
        )
        cell.setupActions()
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let multipleFilesMessage = multipleFilesMessage else {
            return 0
        }
        
        var numberOfFiles: Int = 0
        // Pending
        if multipleFilesMessage.files.count == 0 {
            guard let messageCreateParams = multipleFilesMessage.messageParams as? MultipleFilesMessageCreateParams else {
                return 0
            }
            numberOfFiles = messageCreateParams.uploadableFileInfoList.count
        }
        
        // Succeeded
        else {
            numberOfFiles = multipleFilesMessage.files.count
        }
        
        return isRightPositionWithOdd(numberOfFiles) ?
        numberOfFiles + 1 :
        numberOfFiles

    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let collectionCell = collectionView.cellForItem(at: indexPath) as? SBUMultipleFilesMessageCollectionViewCell else { return }
        guard let uploadedFileInfo = collectionCell.uploadedFileInfo else { return }
        guard let index = self.multipleFilesMessage?.files.firstIndex(where: { $0.url == uploadedFileInfo.url }) else { return }
        self.fileSelectHandler?(uploadedFileInfo, index)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bubblePadding = SBUMultipleFilesMessageCell.Constants.bubblePadding
        let itemSpacing = SBUMultipleFilesMessageCell.Constants.collectionViewItemSpacing
        let imageSize =  (SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize.width - bubblePadding * 2 - itemSpacing) / 2
        
        return CGSize(width: imageSize, height: imageSize)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        // Clean up
        self.uploadedIndices = []

        // Clean up previous collectionView and re-initialize and re-layout a new one.
        self.collectionView.removeFromSuperview()
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = Constants.collectionViewItemSpacing
        layout.minimumLineSpacing = Constants.collectionViewLineSpacing
        
        let collectionview = SBUMultipleFilesMessageCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.isScrollEnabled = false
        self.collectionView = collectionview
        
        self.containerView.addSubview(collectionView)
        self.setupViews()
        self.setupStyles()
        self.setupLayouts()
        
        collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    
    /// - Returns nil if cell should be skipped, or the modified index if the cell should be displayed
    private func modifyIndex(numberOfFiles: Int, originalIndex: Int) -> Int? {
        
        // Special case:
        // If sender is currentUser
        // and if files.count is odd number
        // and if current cell index is second to last
        // => skip the cell.
        if isRightPositionWithOdd(numberOfFiles) &&
            originalIndex == numberOfFiles - 1 {
            return nil
        }
        
        var modifiedIndex = 0
        
        // Special case:
        // If sender is currentUser
        // and if files.count is ODD number
        // and if current cell index is the last
        // => index for dataSource should be 1 smaller than numberOfFiles
        if isRightPositionWithOdd(numberOfFiles) &&
            originalIndex == numberOfFiles {
            modifiedIndex = numberOfFiles - 1
        }
        
        // Default case.
        else {
            modifiedIndex = originalIndex
        }
        
        return modifiedIndex
    }
    
    private func isRightPositionWithOdd(_ numberOfFiles: Int) -> Bool {
        return position == .right &&
        numberOfFiles.isMultiple(of: 2) == false
    }
}
