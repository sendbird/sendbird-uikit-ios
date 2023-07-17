//
//  SBUCardListData.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/14.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation

/// The generic typed data model that is used to configure the card list view.
/// - Important: Please define your data model `CardData`, which represents the type of each element in ``recommends`` inside ``SBUCardListData``. `CardData` must conform to `Codable`.
/// ```swift
/// var cardListData: SBUCardListData<{MyDataType}>
/// print(type(of: cardListData.recommends)) // [{MyDataType}]
/// ```
/// - Since: 3.7.0
public struct SBUCardListData<CardData: Codable>: Codable {
    /// The array of the data used for configuring ``SBUCardListView``.
    /// - Since: 3.7.0
    public let recommends: [CardData]
}
