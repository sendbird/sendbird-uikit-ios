//
//  SBUSuggestedReplyView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// - since: 3.11.0
public protocol SBUSuggestedReplyViewDelegate: AnyObject {
    /// Called when `optionView` is selected.
    /// - Parameters:
    ///    - view: ``SBUSuggestedReplyView`` object.
    ///    - optionView: The selected ``SBUSuggestedReplyOptionView`` object.
    func suggestedReplyView(_ view: SBUSuggestedReplyView, didSelectOption optionView: SBUSuggestedReplyOptionView)
}

/// This is a base container view.
/// - since: 3.11.0
open class SBUSuggestedReplyView: SBUView, SBUSuggestedReplyOptionViewDelegate {
    /// (Read-only) The quick reply options as `String` array from ``SBUSuggestedReplyViewParams``
    public var options: [String] { params?.replyOptions ?? [] }
    
    /// (Read-only) The message ID for quick reply which is from ``SBUSuggestedReplyViewParams``
    public var messageId: Int64? { params?.messageId }
    
    /// this is `option views` to provide access to for style customization.
    public var optionViews: [SBUSuggestedReplyOptionView]?
    
    /// The data structure for ``SBUSuggestedReplyViewParams``. Please use ``configure(with:delegate:)`` to update ``params``
    public private(set) var params: SBUSuggestedReplyViewParams?
    
    /// The delegate that is type of ``SBUSuggestedReplyViewDelegate``
    /// - Since: 3.11.0
    public weak var delegate: SBUSuggestedReplyViewDelegate?
    
    /// Updates UI with ``SBUSuggestedReplyViewParams`` object and ``SBUSuggestedReplyViewDelegate``.
    /// - Parameters:
    ///    - configuration: ``SBUSuggestedReplyViewParams`` object.
    ///    - delegate: ``SBUSuggestedReplyViewDelegate``, the delegate object that handles the selection event sent by ``SBUSuggestedReplyOptionView``.
    /// - Note: This method updates ``params`` and ``delegate`` then, calls ``setupViews()``, ``setupLayouts()`` and ``setupStyles()``
    open func configure(with configuration: SBUSuggestedReplyViewParams, delegate: SBUSuggestedReplyViewDelegate? = nil) {
        self.params = configuration
        self.delegate = delegate

        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
    
    /// Called when a ``SBUSuggestedReplyOptionView`` is selected.
    /// It invokes ``SBUSuggestedReplyViewDelegate/suggestedReplyView(_:didSelectOption:)``
    open func suggestedReplyOptionViewDidSelect(_ optionView: SBUSuggestedReplyOptionView) {
        self.delegate?.suggestedReplyView(self, didSelectOption: optionView)
    }
    
    /// Method to return a view that inherits from ``SBUSuggestedReplyOptionView``.
    /// The parent class contains only data.
    open func createOptionView() -> SBUSuggestedReplyOptionView { SBUSimpleSuggestedReplyOptionView() }
    
    /// Creates ``SBUSuggestedReplyOptionView`` instances with ``SBUSuggestedReplyViewParams``.
    /// - Parameter options: The array of ``SBUSuggestedReplyOptionView``.
    /// - Returns: The array of ``SBUSuggestedReplyOptionView`` instances.
    open func createSuggestedReplyOptionViews(options: [String]) -> [SBUSuggestedReplyOptionView] {
        let optionViews = options.compactMap { option in
            let view = createOptionView()
            view.configure(with: option, delegate: self)
            return view
        }
        return optionViews
    }
    
    /// This is class method to create and set up the `SBUSuggestedReplyView`.
    /// - Parameters:
    ///   - options: The string array that configured the view list
    ///   - message: base message
    ///   - shouldHide: optional value for hiding suggested replies
    ///   - delegate: delegate for event delivery
    ///   - factory: factory method closure for generating suggested replies
    /// - since: 3.27.2
    open class func updateSuggestedReplyView(
        with options: [String]?,
        message: BaseMessage?,
        shouldHide: Bool,
        delegate: SBUSuggestedReplyViewDelegate? = nil,
        factory: (() -> SBUSuggestedReplyView?)? = nil
    ) -> SBUSuggestedReplyView? {
        guard shouldHide == false else { return nil }
        guard SendbirdUI.config.groupChannel.channel.isSuggestedRepliesEnabled else { return nil }
        
        guard let options = options else { return nil }
        guard let messageId = message?.messageId else { return nil }
        
        let suggestedReplyView = factory?() ?? Self.createDefaultSuggestedReplyView()
        let configuration = SBUSuggestedReplyViewParams(
            messageId: messageId,
            replyOptions: options
        )
        suggestedReplyView.configure(with: configuration, delegate: delegate)
        return suggestedReplyView
    }
    
    /// Class method to use when you want to fully customize the design of the ``SBUSuggestedReplyView``.
    /// Create your own view that inherits from ``SBUSuggestedReplyView`` and return it.
    /// NOTE: The default view is ``SBUVerticalSuggestedReplyView``, which is a vertically organized option view.
    /// - Returns: Views that inherit from ``SBUSuggestedReplyView``.
    /// - since: 3.27.2
    open class func createDefaultSuggestedReplyView() -> SBUSuggestedReplyView {
        switch SendbirdUI.config.groupChannel.channel.suggestedRepliesDirection {
        case .vertical: return  SBUVerticalSuggestedReplyView()
        case .horizontal: return SBUHorizontalSuggestedReplyView()
        }
    }
}
