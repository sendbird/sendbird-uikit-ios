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

/// - since: 3.11.0
open class SBUSimpleSuggestedReplyOptionView: SBUSuggestedReplyOptionView {
    /// The selectable stack view. The default value contains ``textView`` as arranged subview.
    public var selectableStackView = SBUSelectableStackView()

    /// The view that shows the reply option text.
    public var textView: UIView = SBUUserMessageTextView()

    // MARK: - Sendbird UIKit Life Cycle
    open override func setupViews() {
        super.setupViews()

        self.selectableStackView.isSelected = false
        self.selectableStackView.position = .right
        self.selectableStackView.stackView.alignment = .trailing

        self.selectableStackView.setStack([
            self.textView
        ])
        self.addSubview(selectableStackView)
        
        let textViewModel = SBUUserMessageTextViewModel(
            message: nil,
            position: .right,
            text: self.text,
            textColor: self.theme.suggestedReplyTitleColor,
            isEdited: false
        )
        (self.textView as? SBUUserMessageTextView)?.configure(model: textViewModel)
    }

    open override func setupLayouts() {
        super.setupLayouts()

        self.selectableStackView
            .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0)
            .sbu_constraint(equalTo: self, bottom: 1, priority: .defaultHigh)
    }

    open override func setupStyles() {
        super.setupStyles()

        self.selectableStackView.layer.cornerRadius = 16
        self.selectableStackView.layer.borderWidth = 1
        self.selectableStackView.layer.borderColor = self.theme.suggestedReplyBorderColor.cgColor
        self.selectableStackView.rightBackgroundColor = self.theme.suggestedReplyBackgroundColor
        self.selectableStackView.rightPressedBackgroundColor = self.theme.suggestedReplyBackgroundSelectedColor
        self.selectableStackView.setupStyles()
    }

    open override func setupActions() {
        super.setupActions()

        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.onSelectOption)
        )
        self.textView.addGestureRecognizer(tapRecognizer)
    }

    /// Calls ``SBUSuggestedReplyOptionViewDelegate/suggestedReplyOptionViewDidSelect(_:)``
    /// - NOTE: If ``text`` is `nil`, it won't invoke the delegate method.
    @objc
    open func onSelectOption() {
        guard self.text != nil else { return }
        self.selectableStackView.isSelected = true
        self.delegate?.suggestedReplyOptionViewDidSelect(self)
    }

    // override for highlighted color.
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.selectableStackView.isSelected = true
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.selectableStackView.isSelected = false
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.selectableStackView.isSelected = false
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        guard self.selectableStackView.isSelected == true else { return }
        
        self.selectableStackView.isSelected = self.bounds.contains(touch.location(in: self))
    }
}
