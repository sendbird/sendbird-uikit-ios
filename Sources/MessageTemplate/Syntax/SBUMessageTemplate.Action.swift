//
//  SBUMessageTemplate.Action.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/09/30.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUMessageTemplate {
    // MARK: - Action
    public class Action: Decodable {
        public let type: ActionType
        public let data: String
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
    
    public enum ActionType: String, Decodable {
        case web, custom, uikit
    }
}
