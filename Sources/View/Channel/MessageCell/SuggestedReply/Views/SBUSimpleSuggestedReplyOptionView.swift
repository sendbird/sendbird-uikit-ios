//
//  SBUSimpleSuggestedReplyOptionView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/04/22.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

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
