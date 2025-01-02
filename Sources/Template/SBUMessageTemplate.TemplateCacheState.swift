//
//  SBUMessageTemplate.TemplateCacheState.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 11/13/24.
//

import Foundation

extension SBUMessageTemplate {
    enum TemplateCacheState {
        case success
        case failure
        case loading
    }
}

extension Dictionary where Key == String, Value == SBUMessageTemplate.TemplateCacheState {
    func uncachedKeys(from keys: [String]) -> [String]? {
        let result = keys.filter { self[$0] != .success && self[$0] != .loading }
        if result.isEmpty { return nil }
        return result
    }
    
    mutating func loadingKeys(from keys: [String]) {
        for key in keys {
            self[key] = .loading
        }
    }
    
    mutating func didLoadKeys(form keys: [String], success: Bool) {
        for key in keys {
            self[key] = success ? .success : .failure
        }
    }
}
