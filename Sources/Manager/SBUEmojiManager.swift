//
//  SBUEmojiManager.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/05/19.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

/// `SBUEmojiManager` is a class responsible for managing emojis in the application.
public class SBUEmojiManager {
    // MARK: - Private keys
    static let kEmojiCacheKey = "LOCAL_CACHING_EMOJI_CONTAINER"
    
    // MARK: - Private property
    static let shared = SBUEmojiManager()
    /// Serial queue for the `UserDefaults` cache: read/decode on restore, serialize/write on save.
    /// No explicit QoS: it inherits the submitter's (the connect flow runs on the main queue).
    static let cacheQueue = DispatchQueue(label: "\(SBUConstant.bundleIdentifier).queue.emoji.cache")
    /// Main-thread only.
    private var container: EmojiContainer?
    /// Hash of the container currently persisted in `UserDefaults`. Main-thread only.
    private var persistedEmojiHash: String?
    private var emojiHash: String? {
        container?.emojiHash
    }
    
    // MARK: - Public function
    
    /// This function gets a list of the emoji categories.
    /// - Returns: `EmojiCategory` type array
    public static func getEmojiCategories() -> [EmojiCategory] {
        guard let container = shared.container else {
            Log.error("[Failed] Emoji Categories: load emoji")
            return []
        }

        guard SBUAvailable.isSupportReactions() else {
            Log.error("[Failed] Emoji Categories: enableReactions is false")
            return []
        }

        let categories = container.categories

        if categories.isEmpty {
            Log.error("[Failed] Emoji Categories: Category is empty")
        }

        return categories
    }

    /// This function gets a list of all emojis.
    /// - Returns: `Emoji` type array
    public static func getAllEmojis() -> [Emoji] {
        guard let container = shared.container else {
            Log.error("[Failed] Emoji List: load emoji")
            return []
        }

        guard SBUAvailable.isSupportReactions() else {
            Log.error("[Failed] Emoji List: enableReactions is false")
            return []
        }

        let emojis = container.categories.reduce([]) { $0 + $1.emojis }

        if emojis.isEmpty {
            Log.error("[Failed] Emoji List: emoji list is empty")
        }

        return emojis
    }

    /// This function gets a list of emojis corresponding to category id.
    /// - Returns: `Emoji` type array
    public static func getEmojis(emojiCategoryId: Int64) -> [Emoji] {
        guard let container = shared.container else {
            Log.error("[Failed] Emojis with category id: load emoji")
            return []
        }

        guard SBUAvailable.isSupportReactions() else {
            Log.error("[Failed] Emojis with category id: enableReactions is false")
            return []
        }

        let categories = container.categories
        if categories.isEmpty {
            Log.warning("[Warning] Emojis with category id: Category is empty")
            return []
        }

        guard let category = categories.first(where: { $0.cid == emojiCategoryId }) else {
            Log.warning("[Warning] Emojis with category id: Can not find category")
            return []
        }

        return category.emojis
    }
    
    static func getEmojis(with categoryIds: [Int64]) -> [Emoji] {
        guard let container = shared.container else {
            Log.error("[Failed] Emojis with categoryIds")
            return []
        }
        
        let categories = container.categories
        guard !categories.isEmpty else {
            return []
        }
        
        let filteredEmojiCategories = categories.filter { categoryIds.contains($0.cid) }
        let filteredEmojis = filteredEmojiCategories.reduce([]) { $0 + $1.emojis }
        
        if filteredEmojis.isEmpty {
            Log.warning("Emojis for emojiCategoryIds is empty.")
        }
        
        return filteredEmojis
    }
    
    // MARK: - private function
    static func isReactionEnabled(channel: BaseChannel?) -> Bool {
        guard let groupChannel = channel as? GroupChannel else { return false }
        
        return !groupChannel.isBroadcast &&
            (groupChannel.isSuper ?
            SBUAvailable.isSupportReactions(for: .superGroup) :
            SBUAvailable.isSupportReactions(for: .group))
    }
    
    /// Decides whether to show the member list for each reaction upon long press on an emoji.
    /// - Since: 3.19.0
    static func isEmojiLongPressEnabled(channel: BaseChannel?) -> Bool {
        guard let groupChannel = channel as? GroupChannel else { return false }
        
        return !groupChannel.isSuper
    }
    
    /// Loads all Emojis from ChatSDK.
    ///
    /// Cache restore (`UserDefaults` read + decode) and cache save (serialize + `UserDefaults` write) run on
    /// `cacheQueue`, never on the caller's thread. The container is only assigned on the main thread.
    /// The cache is written only when the emoji hash changed; restoring from cache never writes it back.
    /// - Parameter completionHandler: The callback that includes either `EmojiContainer` or `SBError`.
    ///   Always called asynchronously on the main thread.
    public static func loadAllEmojis(completionHandler: @escaping (
        _ container: EmojiContainer?,
        _ error: SBError?) -> Void
    ) {
        Thread.executeOnMain {
            guard let appInfo = SendbirdChat.getAppInfo(),
                  self.shared.emojiHash == nil || appInfo.isEmojiUpdateNeeded(prevEmojiHash: shared.emojiHash ?? "")
            else {
                let container = shared.container
                Thread.executeOnMainAsync { completionHandler(container, nil) }
                return
            }
            
            Log.info("[Request] Load all emojis")
            
            // 1. Restore from the cached data first (off the main thread), without writing it back.
            self.restoreContainerFromCache { restored in
                // 2. Fetch from the server. Persist only if the hash changed.
                SendbirdChat.getAllEmojis { container, error in
                    Thread.executeOnMain {
                        if let error = error {
                            if let cachedContainer = shared.container, container == nil {
                                Log.info("[Succeed] Load all emojis from cache")
                                completionHandler(cachedContainer, nil)
                            } else {
                                Log.error("[Failed] Load all emojis: \(error.localizedDescription)")
                                completionHandler(nil, error)
                            }
                            return
                        }
                        
                        guard let container = container else {
                            if let cachedContainer = shared.container {
                                Log.info("[Succeed] Load all emojis from cache")
                                completionHandler(cachedContainer, nil)
                            } else {
                                Log.error("[Failed] Load all emojis: EmojiContainer is not set")
                                completionHandler(nil, nil)
                            }
                            return
                        }
                        
                        Log.info("[Succeed] Load all emojis")
                        shared.setContainer(container, persist: restored?.emojiHash != container.emojiHash)
                        completionHandler(container, nil)
                    }
                }
            }
        }
    }
    
    /// Reads and decodes the cached container on `cacheQueue`, then assigns it on the main thread.
    /// Does not write the cache back. `completionHandler` runs on the main thread with the restored container.
    private static func restoreContainerFromCache(completionHandler: @escaping (EmojiContainer?) -> Void) {
        cacheQueue.async {
            var restored: EmojiContainer?
            if let cachedContainer = UserDefaults.standard.data(forKey: SBUEmojiManager.kEmojiCacheKey) {
                restored = EmojiContainer.build(fromSerializedData: cachedContainer)
            }
            Thread.executeOnMain {
                if let restored = restored {
                    shared.container = restored
                    shared.persistedEmojiHash = restored.emojiHash
                }
                completionHandler(restored)
            }
        }
    }
    
    /// Main-thread only. Assigns the container and, if `persist` is set and the hash differs from the
    /// persisted one, serializes and writes it to `UserDefaults` on `cacheQueue`.
    private func setContainer(_ container: EmojiContainer, persist: Bool) {
        self.container = container
        
        guard persist, container.emojiHash != self.persistedEmojiHash else { return }
        self.persistedEmojiHash = container.emojiHash
        
        SBUEmojiManager.cacheQueue.async {
            if let serializedContainer = container.serialize() {
                UserDefaults.standard.setValue(serializedContainer, forKey: SBUEmojiManager.kEmojiCacheKey)
            }
        }
    }
    
    /// Checks if an emoji is available in current app.
    /// - Since: 3.27.0
    static func isEmojiAvailable(
        emojiKey: String,
        message: BaseMessage
    ) -> Bool {
        if let categoryIds = SBUGlobals.emojiCategoryFilter(message) {
            let emojiKeys = getEmojis(with: categoryIds).map { $0.key }
            if emojiKeys.contains(emojiKey) == false {
                return false
            }
        }
        return true
    }
    
    static func getAvailableEmojis(message: BaseMessage?) -> [Emoji] {
        if let message, let categoryIds = SBUGlobals.emojiCategoryFilter(message) {
            return getEmojis(with: categoryIds)
        } else {
            return getAllEmojis()
        }
    }
}
