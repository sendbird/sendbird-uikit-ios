//
//  SBUTextView.swift
//  SendbirdChatLocalCachingTests
//
//  Created by Damon Park on 7/2/24.
//

import UIKit

/// A TextView with a placeholder.
/// - Since: 3.27.0
open class SBUTextView: UITextView, SBUViewLifeCycle {
    /// placeholder label view
    public let placeholderLabel: UILabel = UILabel()
    /// vertical stackview containing a placeholder label
    public let palceholderContainer = SBUStackView(axis: .vertical, alignment: .top, spacing: 0)
    
    /// placeholder string
    open var placeholder: String? {
        didSet {
            self.placeholderLabel.text = placeholder
            self.placeholderLabel.numberOfLines = 0
        }
    }
    
    /// placeholder color
    open var placeholderColor: UIColor = .lightGray {
        didSet { self.placeholderLabel.textColor = placeholderColor }
    }
    
    /// placeholder font
    open override var font: UIFont? {
        didSet { self.placeholderLabel.font = font }
    }
    
    open override var text: String! {
        didSet { self.textDidChange() }
    }
    
    open override var attributedText: NSAttributedString! {
        didSet { self.textDidChange() }
    }
    
    open override var textAlignment: NSTextAlignment {
        didSet { self.placeholderLabel.textAlignment = textAlignment }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateLayouts()
        self.updateStyles()
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: UITextView.textDidChangeNotification,
            object: nil
        )
    }
    
    open func setupViews() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification, 
            object: nil
        )
        
        self.palceholderContainer.setVStack([self.placeholderLabel, UIView()])
        self.addSubview(self.palceholderContainer)
        self.sendSubviewToBack(self.palceholderContainer)
        
        self.palceholderContainer.isUserInteractionEnabled = false
        self.placeholderLabel.isUserInteractionEnabled = false
        
        self.textDidChange()
    }
    
    open func setupLayouts() { 
        // Set Auto Layout constraints
        self.palceholderContainer.sbu_constraint(
            equalTo: self,
            left: textContainerInset.left + 5,
            right: textContainerInset.right + 5,
            top: textContainerInset.top,
            bottom: textContainerInset.bottom,
            priority: .required
        )
        
        let widthDiff = textContainerInset.left + textContainerInset.right + 10
        let heightDiff = textContainerInset.top + textContainerInset.bottom
        
        self.palceholderContainer
            .sbu_constraint(widthAnchor: self.widthAnchor, width: -widthDiff, priority: .defaultHigh)
            .sbu_constraint(heightAnchor: self.heightAnchor, height: -heightDiff, priority: UILayoutPriority(500))
    }
    
    open func setupStyles() {
        self.placeholderLabel.textColor = self.placeholderColor
        self.placeholderLabel.font = self.font
        self.placeholderLabel.textAlignment = self.textAlignment
    }
    
    open func updateLayouts() { }
    
    open func updateStyles() { }
    
    open func setupActions() { }
    
    /// Methods called when text changes
    @objc
    open func textDidChange() {
        // NOTE: (AC-3275)
        // Use alpha instead of hidden to prevent placelabel height from changing
        self.placeholderLabel.alpha = self.text.isEmpty ? 1.0 : 0.0
    }
}
