//
//  SBUParentMessageInfoReactionView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/12.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
open class SBUParentMessageInfoReactionView: SBUMessageReactionView {
    open override func setupStyles() {
        super.setupStyles()
        
        self.layer.borderWidth = 0
    }

    open override func configure(maxWidth: CGFloat, useReaction: Bool, reactions: [Reaction]) {
        guard useReaction else {
            self.collectionViewMinWidthContraint.isActive = false
            self.isHidden = true
            return
        }

        self.collectionViewMinWidthContraint.isActive = true
        self.maxWidth = maxWidth
        self.reactions = reactions
        self.emojiList = SBUEmojiManager.getAllEmojis()
        
        self.sameCellWidth = true

        let hasMoreEmoji = self.reactions.count < emojiList.count
        let cellSizes = reactions.reduce(0) {
            $0 + self.getCellSize(count: $1.userIds.count).width
        }

        var width: CGFloat = cellSizes
            + CGFloat(reactions.count - 1) * layout.minimumLineSpacing
            + layout.sectionInset.left + layout.sectionInset.right
        if hasMoreEmoji {
            width += self.getCellSize(count: 0).width + layout.minimumLineSpacing
        }
        self.collectionViewMinWidthContraint.constant = width < maxWidth ? width : maxWidth
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        self.collectionViewHeightConstraint.constant = self.collectionView
            .collectionViewLayout.collectionViewContentSize.height

        self.setNeedsLayout()
    }
    
    open override func getCellSize(count: Int) -> CGSize {
        return CGSize(width: 53, height: 30)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard !reactions.isEmpty else { return 1 }

        if self.reactions.count < emojiList.count {
            return self.reactions.count + 1
        } else {
            return self.reactions.count
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.hasMoreEmoji(at: indexPath) || reactions.isEmpty {
            return self.getCellSize(count: 0)
        }

        let count = reactions[indexPath.row].userIds.count
        return self.getCellSize(count: count)
    }
}
