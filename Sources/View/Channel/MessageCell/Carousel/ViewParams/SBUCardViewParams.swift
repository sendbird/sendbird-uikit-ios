//
//  SBUCardViewParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/13.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation

/// The data model used for configuring ``SBUCardView``.
/// - Since: 3.7.0
public struct SBUCardViewParams {
    /// The URL string for image
    /// - Since: 3.7.0
    public let imageURL: String?
    /// The title of the card
    /// - Since: 3.7.0
    public let title: String?
    /// The subtitle of the card
    /// - Since: 3.7.0
    public let subtitle: String?
    /// The description of the card
    /// - Since: 3.7.0
    public let description: String?
    /// The link that is used with `title`
    /// - Since: 3.7.0
    public let link: String?
    
    /// If it's `true`, it has the link.
    /// - Since: 3.7.0
    public var hasLink: Bool { link != nil }
    
    /// Initializes ``SBUCardViewParams``.
    /// - Since: 3.7.0
    public init(
        imageURL: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        description: String? = nil,
        link: String? = nil
    ) {
        self.imageURL = imageURL
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.link = link
    }
}
