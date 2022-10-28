//
//  SBUOpenChannelImageContentView.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUOpenChannelImageContentView: SBUImageContentView {
    
    open override func setupSizeContraint() {
        self.widthConstraint = self.imageView.widthAnchor.constraint(
            equalToConstant: SBUGlobals.messageCellConfiguration.openChannel.thumbnailSize.width
        )
        self.heightConstraint = self.imageView.heightAnchor.constraint(
            equalToConstant: SBUGlobals.messageCellConfiguration.openChannel.thumbnailSize.height
        )

        NSLayoutConstraint.activate([
            self.widthConstraint,
            self.heightConstraint
        ])
    }

    open override func resizeImageView(by size: CGSize) {
        self.widthConstraint.constant = min(
            size.width,
            SBUGlobals.messageCellConfiguration.openChannel.thumbnailSize.width
        )
        self.heightConstraint.constant = min(
            size.height,
            SBUGlobals.messageCellConfiguration.openChannel.thumbnailSize.height
        )
    }
}
