//
//  SBUQuickReplyView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/11.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUQuickReplyViewDelegate: AnyObject {
    /// Called when `optionView` is selected.
    /// - Parameters:
    ///    - view: ``SBUQuickReplyView`` object.
    ///    - optionView: The selected ``SBUQuickReplyOptionView`` object.
    func quickReplyView(_ view: SBUQuickReplyView, didSelectOption optionView: SBUQuickReplyOptionView)
}

@IBDesignable
public class SBUQuickReplyView: SBUView, SBUQuickReplyOptionViewDelegate {
    // MARK: - Properties
    /// ``SBUStackView`` instance. The default value is a vertical stack view that contains ``topSpacer`` and the array of ``SBUQuickReplyOptionView``s
    /// - Since: 3.7.0
    public var stackView: UIStackView = SBUStackView(
        axis: .vertical,
        alignment: .trailing,
        spacing: 8
    )
    
    /// The view to provide top spacing to the ``stackView``
    /// - Since: 3.7.0
    public var topSpacer: UIView = {
        let view = UIView()
        view.sbu_constraint(height: 12)
        return view
    }()
    
    /// (Read-only) The quick reply options as `String` array from ``SBUQuickReplyViewParams``
    /// - Since: 3.7.0
    public var options: [String] {
        params?.replyOptions ?? []
    }
    /// (Read-only) The message ID for quick reply which is from ``SBUQuickReplyViewParams``
    /// - Since: 3.7.0
    public var messageId: Int64? {
        params?.messageId
    }
    
    /// The data structure for ``SBUQuickReplyViewParams``. Please use ``configure(with:delegate:)`` to update ``params``
    /// - Since: 3.7.0
    public private(set) var params: SBUQuickReplyViewParams?

    /// The delegate that is type of ``SBUQuickReplyViewDelegate``
    /// - Since: 3.7.0
    public weak var delegate: SBUQuickReplyViewDelegate?
    
    // MARK: - Sendbird UIKit Life Cycle
    
    public override func setupViews() {
        super.setupViews()
        
        let optionViews = self.createQuickReplyOptionViews(options: self.options)
        self.stackView.setVStack(optionViews)
        self.stackView.insertArrangedSubview(self.topSpacer, at: 0)
        self.addSubview(stackView)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.stackView
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    public override func setupStyles() {
        super.setupStyles()
    }
    
    /// Updates UI with ``SBUQuickReplyViewParams`` object and ``SBUQuickReplyViewDelegate``.
    /// - Parameters:
    ///    - configuration: ``SBUQuickReplyViewParams`` object.
    ///    - delegate: ``SBUQuickReplyViewDelegate``, the delegate object that handles the selection event sent by ``SBUQuickReplyOptionView``.
    /// - Note: This method updates ``params`` and ``delegate`` then, calls ``setupViews()``, ``setupLayouts()`` and ``setupStyles()``
    /// - Since: 3.7.0
    public func configure(with configuration: SBUQuickReplyViewParams, delegate: SBUQuickReplyViewDelegate? = nil) {
        self.params = configuration
        self.delegate = delegate
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
    
    /// Creates ``SBUQuickReplyOptionView`` instances with ``SBUQuickReplyViewParams``.
    /// - Parameter options: The array of ``SBUQuickReplyOptionView``.
    /// - Returns: The array of ``SBUQuickReplyOptionView`` instances.
    /// - Since: 3.7.0
    public func createQuickReplyOptionViews(options: [String]) -> [SBUQuickReplyOptionView] {
        let optionViews = options.compactMap { option in
            let view = SBUQuickReplyOptionView()
            view.configure(with: option, delegate: self)
            return view
        }
        return optionViews
    }
    
    /// Called when a ``SBUQuickReplyOptionView`` is selected. It invokes ``SBUQuickReplyViewDelegate/quickReplyView(_:didSelectOption:)``
    /// - Since: 3.7.0
    public func quickReplyOptionViewDidSelect(_ optionView: SBUQuickReplyOptionView) {
        self.delegate?.quickReplyView(self, didSelectOption: optionView)
    }
}
