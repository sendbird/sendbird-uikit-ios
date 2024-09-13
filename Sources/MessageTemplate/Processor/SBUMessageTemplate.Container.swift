//
//  SBUMessageTemplate.Container.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 8/26/24.
//

import Foundation

extension SBUMessageTemplate {
    /// The model struct that makes up the container of the MessageTemplate
    /// - Since: 3.27.2
    public struct Container {
        /// type value
        public let type: ContainerType
        /// container options
        public let containerOptions: ContainerOptions
    }
}

extension SBUMessageTemplate.Container {
    static func create(with data: [String: Any]?) -> SBUMessageTemplate.Container {
        guard let data = data else { return .default }
        let type = ContainerType(typeString: data["type"] as? String)
        let options = ContainerOptions.create(with: data["container_options"] as? [String: Any])
        return SBUMessageTemplate.Container(type: type, containerOptions: options)
    }
}

extension SBUMessageTemplate.Container {
    /// Enum value representing the ContainerType for layout configuration
    /// - Since: 3.27.2
    public enum ContainerType: String {
        case `default`
        case unknown
    }
    
    /// Model struct for ui configuration of subviews inside the container
    /// - Since: 3.27.2
    public struct ContainerOptions {
        /// Profile exposure enabled boolean value (default: true)
        public let profile: Bool
        /// Time exposure enabled boolean value (default: true)
        public let time: Bool
        /// Nickname exposure enabled boolean value (default: true)
        public let nickname: Bool
    }
}

extension SBUMessageTemplate.Container {
    static var `default`: SBUMessageTemplate.Container {
        SBUMessageTemplate.Container(type: .default, containerOptions: .default)
    }
}

extension SBUMessageTemplate.Container.ContainerType {
    /// A value indicating whether the container type is a valid type
    public var isValid: Bool { self != .unknown }
    
    init(typeString: String?) {
        self = .init(rawValue: typeString ?? "") ?? .unknown
    }
    
    public static func isValidType(with template: [String: Any]) -> Bool {
        SBUMessageTemplate.Container.ContainerType(typeString: template["type"] as? String).isValid
    }
}

extension SBUMessageTemplate.Container.ContainerOptions: Decodable {
    static var `default`: SBUMessageTemplate.Container.ContainerOptions {
        SBUMessageTemplate.Container.ContainerOptions(
            profile: true,
            time: true,
            nickname: true
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case profile, time, nickname
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.profile = try container.decodeIfPresent(Bool.self, forKey: .profile) ?? true
        self.time = try container.decodeIfPresent(Bool.self, forKey: .time) ?? true
        self.nickname = try container.decodeIfPresent(Bool.self, forKey: .nickname)  ?? true
    }
    
    static func create(with data: [String: Any]?) -> SBUMessageTemplate.Container.ContainerOptions {
        guard let data = data else { return .default }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            return try JSONDecoder().decode(SBUMessageTemplate.Container.ContainerOptions.self, from: jsonData)
        } catch {
            return .default
        }
    }
}
