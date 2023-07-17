//
//  SBUQuickReplyOptionView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/11.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUQuickReplyOptionViewDelegate: AnyObject {
    /// Called when `optionView` is selected.
    /// - Parameter optionView: The selected ``SBUQuickReplyOptionView`` object
    func quickReplyOptionViewDidSelect(_ optionView: SBUQuickReplyOptionView)
}

public class SBUQuickReplyOptionView: SBUView {
    // MARK: - Properties
    /// The theme for ``SBUQuickReplyOptionView`` that is type of ``SBUMessageCellTheme``.
    /// - Since: 3.7.0
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    /// The selectable stack view. The default value contains ``textView`` as arranged subview.
    /// - Since: 3.7.0
    public var selectableStackView = SBUSelectableStackView()
    
    /// The view that shows the reply option text.
    /// - Since: 3.7.0
    public var textView: UIView = SBUUserMessageTextView()
    
    /// The text of the reply option.
    /// To update the text, use ``SBUQuickReplyOptionView/configure(with:delegate:)``
    /// ```swift
    /// view.configure(with: "Another option")
    /// ```
    /// - Since: 3.7.0
    public private(set) var text: String?
    
    /// The delegate that is type of ``SBUQuickReplyOptionViewDelegate``
    /// ```swift
    /// view.delegate = self // `self` conforms to `SBUQuickReplyOptionViewDelegate`
    /// // or
    /// view.configure(with: "Another option", delegate: self)
    /// ```
    /// - Since: 3.7.0
    public weak var delegate: SBUQuickReplyOptionViewDelegate?
    
    // MARK: - Sendbird UIKit Life Cycle
    public override func setupViews() {
        super.setupViews()
        
        self.selectableStackView.isSelected = false
        self.selectableStackView.position = .right
        self.selectableStackView.stackView.alignment = .trailing
        
        self.selectableStackView.setStack([
            self.textView
        ])
        self.addSubview(selectableStackView)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.selectableStackView
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.selectableStackView.layer.cornerRadius = 16
        self.selectableStackView.layer.borderWidth = 1
        self.selectableStackView.layer.borderColor = self.theme.rightBackgroundColor.cgColor
        self.selectableStackView.rightPressedBackgroundColor = self.theme.leftBackgroundColor
        self.selectableStackView.setupStyles()
    }
    
    public override func setupActions() {
        super.setupActions()
        
        let tapRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.onSelectOption)
        )
        self.textView.addGestureRecognizer(tapRecognizer)
    }
    
    /// Calls ``SBUQuickReplyOptionViewDelegate/quickReplyOptionViewDidSelect(_:)``
    /// - NOTE: If ``text`` is `nil`, it won't invoke the delegate method.
    /// - Since: 3.7.0
    @objc
    public func onSelectOption() {
        guard self.text != nil else { return }
        self.selectableStackView.isSelected = true
        self.delegate?.quickReplyOptionViewDidSelect(self)
    }
    
    // MARK: - Configure
    /// Configure ``SBUQuickReplyOptionView`` with `optionText`.
    /// - Since: 3.7.0
    public func configure(with optionText: String, delegate: SBUQuickReplyOptionViewDelegate? = nil) {
        self.text = optionText
        self.delegate = delegate
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
        self.setupActions()
        
        let textViewModel = SBUUserMessageTextViewModel(
            message: nil,
            position: .right,
            text: optionText,
            textColor: self.theme.rightBackgroundColor
        )
        (self.textView as? SBUUserMessageTextView)?.configure(model: textViewModel)
        
        self.layoutIfNeeded()
    }
}
