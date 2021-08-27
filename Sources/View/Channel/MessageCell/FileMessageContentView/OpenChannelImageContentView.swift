//
//  OpenChannelImageContentView.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

class OpenChannelImageContentView: ImageContentView {
    
    override func setupSizeContraint() {
        self.widthConstraint = self.imageView.widthAnchor.constraint(
            equalToConstant: SBUConstant.openChannelThumbnailSize.width
        )
        self.heightConstraint = self.imageView.heightAnchor.constraint(
            equalToConstant: SBUConstant.openChannelThumbnailSize.height
        )

        NSLayoutConstraint.activate([
            self.widthConstraint,
            self.heightConstraint
        ])
    }

    override func resizeImageView(by size: CGSize) {
        self.widthConstraint.constant = min(size.width,
                                            SBUConstant.openChannelThumbnailSize.width)
        self.heightConstraint.constant = min(size.height,
                                             SBUConstant.openChannelThumbnailSize.height)
    }
}
