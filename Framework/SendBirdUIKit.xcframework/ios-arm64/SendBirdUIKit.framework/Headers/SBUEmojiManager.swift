//
//  SBUEmojiManager.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/05/19.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

@objcMembers
public class SBUEmojiManager: NSObject {
    // MARK: - Private keys
    static let kEmojiCacheKey = "LOCAL_CACHING_EMOJI_CONTAINER"
    
    // MARK: - Private property
    static let shared = SBUEmojiManager()
    private var container: SBDEmojiContainer? {
        didSet { self.didSetContainer() }
    }
    private var emojiHash: String? {
        container?.emojiHash
    }

    
    // MARK: - Public function
    
    /// This function gets a list of the emoji categories.
    /// - Returns: `SBDEmojiCategory` type array
    public static func getEmojiCategories() -> [SBDEmojiCategory] {
        guard let container = shared.container else {
            SBULog.error("[Failed] Emoji Categories: load emoji")
            return []
        }

        guard let appInfo = SBDMain.getAppInfo() else {
            SBULog.error("[Failed] Emoji Categories: appInfo is nil")
            return []
        }

        guard appInfo.useReaction else {
            SBULog.error("[Failed] Emoji Categories: useReaction is false")
            return []
        }

        let categories = container.categories

        if categories.isEmpty {
            SBULog.error("[Failed] Emoji Categories: Category is empty")
        }

        return categories
    }

    /// This function gets a list of all emojis.
    /// - Returns: `SBDEmoji` type array
    public static func getAllEmojis() -> [SBDEmoji] {
        guard let container = shared.container else {
            SBULog.error("[Failed] Emoji List: load emoji")
            return []
        }

        guard let appInfo = SBDMain.getAppInfo() else {
            SBULog.error("[Failed] Emoji List: appInfo is nil")
            return []
        }

        guard appInfo.useReaction else {
            SBULog.error("[Failed] Emoji List: useReaction is false")
            return []
        }

        let emojis = container.categories.reduce([]) { $0 + $1.emojis }

        if emojis.isEmpty {
            SBULog.error("[Failed] Emoji List: emoji list is empty")
        }

        return emojis
    }

    /// This function gets a list of emojis corresponding to category id.
    /// - Returns: `SBDEmoji` type array
    public static func getEmojis(emojiCategoryId: Int64) -> [SBDEmoji] {
        guard let container = shared.container else {
            SBULog.error("[Failed] Emojis with category id: load emoji")
            return []
        }

        guard let appInfo = SBDMain.getAppInfo() else {
            SBULog.error("[Failed] Emojis with category id: appInfo is nil")
            return []
        }

        guard appInfo.useReaction else {
            SBULog.error("[Failed] Emojis with category id: useReaction is false")
            return []
        }

        let categories = container.categories
        if categories.isEmpty {
            SBULog.warning("[Warning] Emojis with category id: Category is empty")
            return []
        }

        guard let category = categories.first(where: { $0.cid == emojiCategoryId }) else {
            SBULog.warning("[Warning] Emojis with category id: Can not find category")
            return []
        }

        return category.emojis
    }

    
    // MARK: - private function
    static func useReaction(channel: SBDBaseChannel?) -> Bool {
        guard let groupChannel = channel as? SBDGroupChannel else { return false }
        
        if let appInfo = SBDMain.getAppInfo(),
           appInfo.useReaction, !groupChannel.isSuper, !groupChannel.isBroadcast  {
            return true
        } else {
            return false
        }
    }

    static func loadAllEmojis(completionHandler: @escaping (
        _ container: SBDEmojiContainer?,
        _ error: SBDError?) -> Void
    ) {
        guard let appInfo = SBDMain.getAppInfo(),
              self.shared.emojiHash == nil || appInfo.isEmojiUpdateNeeded(shared.emojiHash ?? "")
        else {
            completionHandler(shared.container, nil)
            return
        }
        
        SBULog.info("[Request] Load all emojis")
        
        // Load from cached data first.
        if let cachedContainer = UserDefaults.standard.data(forKey: SBUEmojiManager.kEmojiCacheKey) {
            let container = SBDEmojiContainer.build(fromSerializedData: cachedContainer)
            shared.container = container
        }
        
        SBDMain.getAllEmojis { container, error in
            if let error = error {
                if let cachedContainer = shared.container, container == nil {
                    SBULog.error("[Succeed] Load all emojis from cache")
                    completionHandler(cachedContainer, nil)
                } else {
                    SBULog.error("[Failed] Load all emojis: \(error.localizedDescription)")
                    completionHandler(nil, error)
                }
                return
            }
            
            guard let container = container else {
                if let cachedContainer = shared.container {
                    SBULog.error("[Succeed] Load all emojis from cache")
                    completionHandler(cachedContainer, nil)
                } else {
                    SBULog.error("[Failed] Load all emojis: EmojiContainer is not set")
                    completionHandler(nil, nil)
                }
                return
            }
            
            SBULog.info("[Succeed] Load all emojis")
            shared.container = container
            completionHandler(container, nil)
        }
    }
    
    private func didSetContainer() {
        if let serializedContainer = container?.serialize() {
            UserDefaults.standard.setValue(serializedContainer, forKey: SBUEmojiManager.kEmojiCacheKey)
        }
    }
}
