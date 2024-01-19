//
//  SBUExtendedMessage.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation

/// `Structures to model `extended message` to make it easier to use
/// - Since: 3.11.0
struct SBUExtendedMessagePayload {
    /// Parsed `suggested replies` data.
    public let suggestedReplies: [String]?
    /// Parsed array of `form`.
    public let forms: [SBUForm]?
    /// This is custom view data, set on the server side, and can be of `Any` type.
    public let customView: Any?

    init?(from value: [String: Any]) {
        self.suggestedReplies = SBUExtendedMessagePayload.getSuggestedReplies(from: value)
        self.forms = SBUExtendedMessagePayload.getForms(from: value)
        self.customView = SBUExtendedMessagePayload.getCustomView(from: value)
    }

    enum CodingKeys: String, CodingKey {
        case suggestedReplies = "suggested_replies"
        case forms
        case customView = "custom_view"
    }
}

extension SBUExtendedMessagePayload {

    fileprivate static func getSuggestedReplies(from value: [String: Any]) -> [String]? {
        guard let json = value[CodingKeys.suggestedReplies.rawValue] else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
        return try? JSONDecoder().decode([String].self, from: data)
    }
    
    fileprivate static func getForms(from value: [String: Any]) -> [SBUForm]? {
        guard let json = value[CodingKeys.forms.rawValue] else { return nil }
        guard let data = try? JSONSerialization.data(withJSONObject: json) else { return nil }
        return try? JSONDecoder().decode([SBUForm].self, from: data)
    }
    
    fileprivate static func getCustomView(from value: [String: Any]) -> Any? {
        value[CodingKeys.customView.rawValue]
    }
}

extension SBUExtendedMessagePayload {
    func decodeCustomViewData<ViewData: Decodable>() throws -> ViewData? {
        guard let json = self.customView else { return nil }
        let data = try JSONSerialization.data(withJSONObject: json)
        return try JSONDecoder().decode(ViewData.self, from: data)
    }
}

extension Dictionary where Key == String, Value == Any {
    var toExtendedMessage: SBUExtendedMessagePayload? { SBUExtendedMessagePayload(from: self) }
}
