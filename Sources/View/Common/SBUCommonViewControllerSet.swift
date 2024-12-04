//
//  SBUCommonViewControllerSet.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/03/21.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The set of the supported view controllers that are commonly used in ``SendbirdUIKit``
/// - Since: 3.5.2
public class SBUCommonViewControllerSet {
    /// The type of file view controller that overrides ``SBUFileViewController``.
    /// ```swift
    /// SBUCommonViewControllerSet.FileViewController = MyAppFileViewController.self
    /// ```
    /// - Since: 3.5.2
    public static var FileViewController: SBUFileViewController.Type = SBUFileViewController.self
    
    // MOD TODO: Need to add CustomViewController sample
    
    /// The view controller that shows the selected accessible photos and videos.
    /// - Since: 3.28.0
    public static var SelectablePhotoViewController: SBUSelectablePhotoViewController.Type = SBUSelectablePhotoViewController.self
    
    /// The view controller that shows the message menu sheet.
    /// - Since: 3.28.0
    public static var MenuSheetViewController: SBUMenuSheetViewController.Type = SBUMenuSheetViewController.self

    /// The view controller that shows the reactions.
    /// - Since: 3.28.0
    public static var ReactionsViewController: SBUReactionsViewController.Type = SBUReactionsViewController.self
    
    /// The view controller that shows the emojis.
    /// - Since: 3.28.0
    public static var EmojiListViewController: SBUEmojiListViewController.Type = SBUEmojiListViewController.self
}
