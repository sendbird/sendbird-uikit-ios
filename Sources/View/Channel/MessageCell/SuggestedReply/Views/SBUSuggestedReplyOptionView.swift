//
//  SBUSuggestedReplyOptionView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// - since: 3.11.0
public protocol SBUSuggestedReplyOptionViewDelegate: AnyObject {
    /// Called when `optionView` is selected.
    /// - Parameter optionView: The selected ``SBUSuggestedReplyOptionView`` object
    func suggestedReplyOptionViewDidSelect(_ optionView: SBUSuggestedReplyOptionView)
}

/// Suggested reply view's base view, which has a basic interface with the data.
/// - since: 3.11.0
open class SBUSuggestedReplyOptionView: SBUView {
    // MARK: - Properties
    /// The theme for ``SBUSuggestedReplyOptionView`` that is type of ``SBUMessageCellTheme``.
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// The text of the reply option.
    /// To update the text, use ``SBUSuggestedReplyOptionView/configure(with:delegate:)``
    /// ```swift
    /// view.configure(with: "Another option")
    /// ```
    public private(set) var text: String?
    
    /// The delegate that is type of ``SBUSuggestedReplyOptionViewDelegate``
    /// ```swift
    /// view.delegate = self // `self` conforms to `SBUSuggestedReplyOptionViewDelegate`
    /// // or
    /// view.configure(with: "Another option", delegate: self)
    /// ```
    public weak var delegate: SBUSuggestedReplyOptionViewDelegate?
    
    // MARK: - Configure
    /// Configure ``SBUSuggestedReplyOptionView`` with `optionText`.
    open func configure(with optionText: String, delegate: SBUSuggestedReplyOptionViewDelegate? = nil) {
        self.text = optionText
        self.delegate = delegate

        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
        self.setupActions()
    }
}
