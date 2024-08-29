//
//  SBUMessageFormMultiTextItemView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 7/2/24.
//

import UIKit
import SendbirdChatSDK

/// - Since: 3.27.0
public class SBUMessageFormMultiTextItemView: SBUMessageFormItemView, UITextViewDelegate {
    
    /// A vertical stack view to configure layouts of the items.
    public var stackView = SBUStackView(axis: .vertical, alignment: .leading, spacing: 0)
    /// A horizontal stack view to configure layouts of `title` and `optional`.
    public var titleStackView = SBUStackView(axis: .horizontal, alignment: .top, spacing: 3)
    /// The `UILabel` displaying form item title.`
    public var titleView = UILabel()
    /// Top space view.
    public var topSpaceView = UIView()
    /// A container view to wrap `inputStackView`.
    public var inputContainer = UIView()
    /// A horizontal stack view to configure layouts of `valueStackView` and `input icon`.
    public var inputStackView = SBUStackView(axis: .horizontal, alignment: .top, spacing: 0)
    /// A vertical stack view to configure layouts of `input item` and `text label`.
    public var valueStackView = SBUStackView(axis: .vertical, alignment: .fill, spacing: 0)
    
    /// The `UITextField` for displaying and interacting with the input form item.
    public var inputTextView = SBUTextView()
    /// The `UILabel` displaying the submitted values.
    public var inputTextLabel = SBUPaddingLabel(3, 0, 6, 0)
    /// A container view to wrap `inputIconView`.
    public var iconContainer = UIView()
    /// The `UIImageView` for displaying input completion icons.
    public var inputIconView = UIImageView()
    /// Bottom space view. can be hidden. Used only if there is an error message.
    public var bottomSpaceView = UIView()
    /// The `UILabel` displaying the error message.
    public var errorTitleView = UILabel()
    
    private var isActive: Bool = false {
        didSet { updateInputValidation() }
    }

    // MARK: - Sendbird UIKit Life Cycle
    public override func setupViews() {
        super.setupViews()

        // + -- stackView ----------------------------- +
        // | + --- titleStackView ------------------- + |
        // | | titleView                              | |
        // | + -------------------------------------- + |
        // + ------------------------------------------ +
        // | topSpaceView                               |
        // + ------------------------------------------ +
        // | + -- inputContainer -------------------- + |
        // | | +---- inputStackView --------------- + | |
        // | | | +- valueStackView -+               | | |
        // | | | | inputTextView    |               | | |
        // | | | +------------------+ inputIconView | | |
        // | | | | inputTextLabel   |               | | |
        // | | | +------------------+               | | |
        // | | +----------------------------------- + | |
        // | + -------------------------------------- + |
        // + ------------------------------------------ +
        // | bottomSpaceView                            |
        // + ------------------------------------------ +
        // | errorTitleView                             |
        // + ------------------------------------------ +
        
        self.iconContainer.addSubview(self.inputIconView)

        self.titleStackView.setHStack([self.titleView])
        self.valueStackView.setVStack([self.inputTextView, self.inputTextLabel])
        self.inputStackView.setHStack([self.valueStackView, self.iconContainer])

        self.inputContainer.addSubview(inputStackView)

        self.stackView.setVStack([
            self.titleStackView,
            self.topSpaceView,
            self.inputContainer,
            self.bottomSpaceView,
            self.errorTitleView
        ])
        
        self.inputTextView.delegate = self

        self.addSubview(stackView)
        
        self.titleView.attributedText = self.titleAttributedString

        self.errorTitleView.text = SBUStringSet.FormType_Error_Default

        self.inputTextView.placeholder = self.formItem?.placeholder
        self.inputTextView.text = self.status.text
        self.inputTextView.keyboardType = .default
        
        self.inputTextLabel.font = SBUFontSet.body3
        self.inputTextLabel.textColor = theme.formInputTitleColor
        self.inputTextLabel.textAlignment = .left
        self.inputTextLabel.numberOfLines = 0
        
        self.inputIconView.isHidden = !self.status.didSubmit
    }

    public override func setupLayouts() {
        super.setupLayouts()

        self.titleView.sbu_constraint_greaterThan(height: 12)
        
        self.errorTitleView.sbu_constraint(height: 12)

        self.topSpaceView.sbu_constraint(width: 1, height: 6)
        self.bottomSpaceView.sbu_constraint(width: 1, height: 4)

        self.inputTextView
            .sbu_constraint_greaterThan(height: 80, priority: .defaultLow)
        
        self.inputContainer
            .sbu_constraint_greaterThan(height: 96)
            
        self.iconContainer
            .sbu_constraint(heightAnchor: self.inputStackView.heightAnchor, height: 0)
        
        self.inputIconView
            .sbu_constraint(width: 20, height: 20, priority: UILayoutPriority(900))
            .sbu_constraint(equalTo: self.iconContainer, leading: 0, trailing: 0, bottom: 0)

        self.inputStackView
            .sbu_constraint(equalTo: self.inputContainer, left: 6, top: 3)
            .sbu_constraint(equalTo: self.inputContainer, right: 12, bottom: 8)

        self.inputContainer
            .sbu_constraint(equalTo: self.stackView, left: 0, right: 0)
            .sbu_constraint(height: 36, priority: .defaultLow)
        
        self.stackView
            .sbu_constraint(equalTo: self, left: 0, top: 0)
            .sbu_constraint(equalTo: self, right: 0, bottom: 0, priority: .defaultHigh)
            .sbu_constraint_multiplier(widthAnchor: self.widthAnchor, widthMultiplier: 1) // NOTE: do not remove this constraints (AC-3258)
        
        self.inputStackView.spacing = 4 // NOTE: Set after layout setup due to auto layout warnings.
    }

    public override func setupStyles() {
        super.setupStyles()
            
        self.titleView.numberOfLines = 0
    
        self.errorTitleView.font = theme.formErrorTitleFont
        self.errorTitleView.textColor = theme.formInputErrorColor

        self.inputTextView.font = theme.formInputTextFont
        self.inputTextView.textColor = theme.formInputTitleColor
        self.inputTextView.placeholderColor = theme.formInputPlaceholderColor
        self.inputTextView.textAlignment = .left
        self.inputTextView.backgroundColor = .clear
        self.inputTextView.autocorrectionType = .no
        self.inputTextView.spellCheckingType = .no
        self.inputTextView.alwaysBounceHorizontal = false
        self.inputTextView.alwaysBounceVertical = true
        self.inputTextView.isScrollEnabled = true
    
        self.inputTextLabel.font = theme.formInputTextFont
        self.inputTextLabel.textColor = self.status.isOptional ? theme.formInputPlaceholderColor : theme.formInputTitleColor
        self.inputTextLabel.textAlignment = .left
        self.inputTextLabel.numberOfLines = 0
        self.inputTextLabel.backgroundColor = .clear

        self.inputContainer.layer.borderColor = theme.formInputBorderNormalColor.cgColor
        self.inputContainer.layer.borderWidth = 1.0
        self.inputContainer.layer.cornerRadius = 6
        self.inputContainer.backgroundColor = self.status.didSubmit ? theme.formInputBackgroundDoneColor : theme.formInputBackgroundColor

        self.inputIconView.image = SBUIconSet.iconDone.sbu_with(tintColor: theme.formInputIconColor)

        self.updateInputValidation()
        self.updateInputData()
    }

    func updateInputValidation() {
        if self.status.didSubmit == true {
            self.inputContainer.layer.borderColor = UIColor.clear.cgColor
            self.bottomSpaceView.isHidden = true
            self.errorTitleView.isHidden = true
            return
        }
        
        let errorType = didValidation ? self.isValidInput() : .none
        
        if isActive == true {
            // active: true
            if errorTitleView.isHidden == false {
                self.inputContainer.layer.borderColor = theme.formInputBorderErrorColor.cgColor
                self.errorTitleView.isHidden = false
                self.bottomSpaceView.isHidden = false
            } else {
                self.inputContainer.layer.borderColor = theme.formInputBorderActiveColor.cgColor
                self.bottomSpaceView.isHidden = true
                self.errorTitleView.isHidden = true
            }
        } else {
            // active: false
            if errorType.hasError == true {
                self.inputContainer.layer.borderColor = theme.formInputBorderErrorColor.cgColor
                self.errorTitleView.text = errorType.errorMessage
                self.errorTitleView.isHidden = false
                self.bottomSpaceView.isHidden = false
            } else {
                self.inputContainer.layer.borderColor = theme.formInputBorderNormalColor.cgColor
                self.bottomSpaceView.isHidden = true
                self.errorTitleView.isHidden = true
            }
        }
    }
    
    /// Methods that update the view state and values
    public func updateInputData() {
        self.inputTextView.text = self.status.text
        self.inputTextView.isEditable = self.status.isEditable
        self.inputTextView.isHidden = self.status.didSubmit
        
        self.inputTextLabel.text = self.status.text
        self.inputTextLabel.isHidden = !self.status.didSubmit
        
        self.iconContainer.isHidden = !self.status.didSubmit
    }
    
    /// Text view delegate methods and called when text is changed
    public func textViewDidChange(_ textView: UITextView) {
        guard self.status.isEditable == true else { return }
        guard let item = self.formItem else { return }
        
        item.draftValues = [textView.text].compactMap({ $0 })
        self.status.edting(item: item)
        self.inputTextView.text = self.status.text
        
        self.delegate?.messageFormItemView(self, didUpdate: item)
        
        self.updateInputValidation()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    /// Text view delegate methods and called when editing starts
    public func textViewDidBeginEditing(_ textView: UITextView) {
        // NOTE: (AC-3323)
        // fix scrolling issue
        self.inputTextView.text = ""
        self.inputTextView.text = self.formItem?.draftValues?.first
        
        self.isActive = true
    }
    
    /// Text view delegate methods and called when editing end
    public func textViewDidEndEditing(_ textView: UITextView) {
        self.didValidation = true
        self.isActive = false
    }
    
    func isValidInput() -> InputErrorType {
        guard let item = self.formItem else { return .none }
        let value = item.draftValues?.first ?? ""
        if value.isEmpty {
            if didValidation == false { return .none }
            return item.required ? .required : .none
        }
        return item.isValid([value]) ? .none : .invalid
    }
    
    func scrollToBottom() {
        if inputTextView.text.count > 0 {
            let bottom = NSRange(location: inputTextView.text.count - 1, length: 1)
            inputTextView.scrollRangeToVisible(bottom)
        }
    }
}
