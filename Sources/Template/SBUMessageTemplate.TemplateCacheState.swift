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

    /// 성공인데 메모리 캐시에 템플릿이 없는 키를 뺀 상태.
    /// 공개 템플릿 캐시 초기화 API 는 메모리 템플릿을 비우지만 view model 의 이 상태는 성공으로 남긴다. 이 키를 빼면 셀이 기존 다운로드 경로로 다시 받는다.
    /// 로딩 중과 실패는 그대로 둔다. 빼면 같은 요청이 겹치거나 실패한 요청을 계속 다시 보낸다.
    func removingSuccessMissingFromMemory(type: SBUMessageTemplate.TemplateType) -> Self {
        let cache = SBUCacheManager.template(with: type)
        return self.filter { $0.value != .success || cache.getMemoryTemplate(forKey: $0.key) != nil }
    }
}
