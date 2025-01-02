//
//  SBUMessageTemplate.Action.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

/// Message template namespace class
public class SBUMessageTemplate {
    // MARK: - Action
    /// Message Template Touch Action Class
    /// - Since: 3.29.0
    public class Action: Decodable {
        /// Action type
        public let type: ActionType
        /// String data values
        public let data: String
        /// Additional data values
        public let alterData: String?
        
        enum CodingKeys: String, CodingKey {
            case type, data, alterData
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.type = try container.decode(ActionType.self, forKey: .type)
            self.data = try container.decode(String.self, forKey: .data)
            self.alterData = try container.decodeIfPresent(String.self, forKey: .alterData)
        }
        
        init(
            type: ActionType,
            data: String,
            alterData: String?
        ) {
            self.type = type
            self.data = data
            self.alterData = alterData
        }
        
        init(action: TemplateSyntax.Action) {
            self.type = .init(rawValue: action.type.rawValue) ?? .custom
            self.data = action.data
            self.alterData = action.alterData
        }
        
        /// - Since: 3.21.0
        public var urlFromActionDatas: URL? {
            if let url = URL(string: self.data.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                return url
            }
            
            if let urlString = self.alterData, let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                return url
            }
            
            return nil
        }
    }
    
    /// Action type
    /// - Since: 3.29.0
    public enum ActionType: String, Decodable {
        case web, custom, uikit
    }
}
