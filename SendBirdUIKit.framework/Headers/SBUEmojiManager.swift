//
//  SBUEmojiManager.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/05/19.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import Foundation

@objcMembers
public class SBUEmojiManager {

    // MARK: - Private property
    static let shared = SBUEmojiManager()
    private var container: SBDEmojiContainer?
    private var emojiHash: String? {
        container?.emojiHash
    }
    var useReactionCurrnetChannel: Bool = false
 
    // MARK: - Public function
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
    static var useReaction: Bool {

        if let appInfo = SBDMain.getAppInfo(),
            appInfo.useReaction, shared.useReactionCurrnetChannel {
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
                completionHandler(nil, nil)
                return
        }

        SBULog.info("[Request] Load all emojis")
        SBDMain.getAllEmojis { container, error in
            if let error = error {
                SBULog.error("[Failed] Load all emojis: \(error.localizedDescription)")
                completionHandler(container, error)
                return
            }

            guard let container = container else {
                SBULog.error("[Failed] Load all emojis: EmojiContainer is not set")
                completionHandler(nil, nil)
                return
            }

            SBULog.info("[Succeed] Load all emojis")
            shared.container = container
            completionHandler(container, nil)
        }
    }
}
