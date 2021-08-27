//
//  StreamingChannel.swift
//  SendBirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/17.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation

struct StreamingChannel: Decodable {
    struct Creator: Decodable {
        let id: String
        let name: String
        let profileURL: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case profileURL = "profile_url"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(String.self, forKey: .id)
            self.name = try container.decode(String.self, forKey: .name)
            self.profileURL = try container.decode(String.self, forKey: .profileURL)
        }
    }
    
    let name: String
    let creatorInfo: Creator
    let tags: [String]
    let thumbnailURL: String
    let liveChannelURL: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case creatorInfo = "creator_info"
        case tags
        case thumbnailURL = "thumbnail_url"
        case liveChannelURL = "live_channel_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.creatorInfo = try container.decode(Creator.self, forKey: .creatorInfo)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.thumbnailURL = try container.decode(String.self, forKey: .thumbnailURL)
        self.liveChannelURL = try container.decode(String.self, forKey: .liveChannelURL)
    }
}
