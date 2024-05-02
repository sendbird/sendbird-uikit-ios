//
//  SBUMessageTemplate.Syntax.Identifier.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/28.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol MessageTemplateItemIdentifiable {
    func setIdentifier(with factory: SBUMessageTemplate.Syntax.Identifier.Factory)
}

extension SBUMessageTemplate.Syntax {
    struct Identifier: Equatable, Codable {
        let messageId: Int64
        let index: Int
        let className: String
        
        static var `default`: Identifier {
            Identifier(messageId: 0, index: NSNotFound, className: "unknown")
        }
        
        var isValid: Bool { self.messageId != 0 && self.index != NSNotFound }
        
        var key: String {
            SBUCacheManager.TemplateImage.memoryCache.generateKey(
                messageId: self.messageId,
                viewIndex: self.index
            )
        }
        
        static func == (
            lhs: SBUMessageTemplate.Syntax.Identifier,
            rhs: SBUMessageTemplate.Syntax.Identifier
        ) -> Bool {
            lhs.messageId == rhs.messageId &&
            lhs.index == rhs.index &&
            lhs.className == rhs.className
        }
        
    }
}

extension SBUMessageTemplate.Syntax.Identifier {
    class Factory: Equatable, Codable {
        private(set) var messageId: Int64 = 0
        private(set) var currentIndex: Int = 0
        
        var cacheTarget = [String: String]() // [cacheKey: urlString]
        var identifiers = [SBUMessageTemplate.Syntax.Identifier]()
        
        init(messageId: Int64? = nil) { self.messageId = messageId ?? 0 }
        
        private func getIndexBeforeIncrement() -> Int {
            let index = self.currentIndex
            self.currentIndex += 1
            return index
        }
        
        var isValid: Bool { self.messageId != 0 }
        
        func generate(with view: SBUMessageTemplate.Syntax.View) -> SBUMessageTemplate.Syntax.Identifier {
            let identifier = SBUMessageTemplate.Syntax.Identifier(
                messageId: self.messageId,
                index: self.getIndexBeforeIncrement(),
                className: String(describing: type(of: view))
            )
            
            if let url = view.imageUrlString, view.isFixedSize == false {
                self.cacheTarget[identifier.key] = url
            }
            
            identifiers.append(identifier)
            
            return identifier
        }
        
        func getUncachedData() -> [String: String]? {
            let noHit = cacheTarget
                .filter {
                    let fileName = SBUCacheManager.Image.createCacheFileName(
                        urlString: $0.value,
                        cacheKey: nil
                    )
                    return SBUCacheManager.Image.get(
                        fileName: fileName,
                        subPath: SBUCacheManager.PathType.template
                    ) == nil
                }
            
            return noHit.hasElements ? noHit : nil
        }
        
        static func == (
            lhs: SBUMessageTemplate.Syntax.Identifier.Factory,
            rhs: SBUMessageTemplate.Syntax.Identifier.Factory
        ) -> Bool {
            lhs.identifiers == rhs.identifiers &&
            lhs.cacheTarget == rhs.cacheTarget
        }
    }
}

extension SBUMessageTemplate.Syntax.Identifier.Factory: SBUCarouselCacheKey { }
