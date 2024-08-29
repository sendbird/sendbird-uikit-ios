//
//  SBUMessageFormSingleTextItemView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 7/2/24.
//

import UIKit
import SendbirdChatSDK

/// - Since: 3.27.0
public class SBUMessageFormSingleTextItemView: SBUMessageFormItemView, UITextFieldDelegate {
    
    /// A vertical stack view to configure layouts of the items.
    public var stackView = SBUStackView(axis: .vertical, alignment: .leading, spacing: 0)
    /// A horizontal stack view to configure layouts of `title` and `optional`.
    public var titleStackView = SBUStackView(axis: .horizontal, alignment: .fill, spacing: 3)
    /// The `UILabel` displaying form item title.`
    public var titleView = UILabel()
    /// Top space view.
    public var topSpaceView = UIView()
    /// A container view to wrap `inputStackView`.
    public var inputContainer = UIView()
    /// A horizontal stack view to configure layouts of `valueStackView` and `input icon`.
    public var inputStackView = SBUStackView(axis: .horizontal, alignment: .fill, spacing: 4)
    /// A vertical stack view to configure layouts of `input item` and `text label`.
    public var valueStackView = SBUStackView(axis: .vertical, alignment: .fill, spacing: 0)
    /// The `UITextField` for displaying and interacting with the input form item.
    public var inputTextField = UITextField()
    /// The `UILabel` displaying the submitted values.
    public var inputTextLabel = UILabel()
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
        // | | | | inputTextField   |               | | |
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
        self.valueStackView.setVStack([self.inputTextField, self.inputTextLabel])
        self.inputStackView.setHStack([self.valueStackView, self.iconContainer])

        self.inputContainer.addSubview(inputStackView)

        self.stackView.setVStack([
            self.titleStackView,
            self.topSpaceView,
            self.inputContainer,
            self.bottomSpaceView,
            self.errorTitleView
        ])
        
        self.inputTextField.delegate = self

        self.addSubview(stackView)
        
        self.titleView.attributedText = self.titleAttributedString

        self.errorTitleView.text = SBUStringSet.FormType_Error_Default

        self.inputTextField.placeholder = self.formItem?.placeholder
        self.inputTextField.text = self.status.text
        self.inputTextField.keyboardType = formItem?.style.layout.keyboardType ?? .default

        self.inputTextLabel.text = self.status.text
    }

    public override func setupLayouts() {
        super.setupLayouts()

        self.titleView.sbu_constraint_greaterThan(height: 12)
        
        self.errorTitleView.sbu_constraint(height: 12)

        self.topSpaceView.sbu_constraint(width: 1, height: 6)
        self.bottomSpaceView.sbu_constraint(width: 1, height: 4)

        self.inputTextField
            .sbu_constraint(height: 20)
        
        self.inputIconView
            .sbu_constraint(width: 20, height: 20)
            .sbu_constraint(equalTo: self.iconContainer, leading: 0, trailing: 0, bottom: 0)

        self.inputStackView
            .sbu_constraint(equalTo: self.inputContainer, left: 12, top: 8)
            .sbu_constraint(equalTo: self.inputContainer, right: 12, bottom: 8)

        self.inputContainer
            .sbu_constraint(equalTo: self.stackView, left: 0, right: 0)
            .sbu_constraint(height: 36, priority: .defaultLow)
        
        self.stackView
            .sbu_constraint(equalTo: self, left: 0, top: 0)
            .sbu_constraint(equalTo: self, right: 0, bottom: 0, priority: .defaultHigh)
            .sbu_constraint_multiplier(widthAnchor: self.widthAnchor, widthMultiplier: 1) // NOTE: do not remove this constraints (AC-3258)
    }

    public override func setupStyles() {
        super.setupStyles()

        self.titleView.numberOfLines = 0

        self.errorTitleView.font = theme.formErrorTitleFont
        self.errorTitleView.textColor = theme.formInputErrorColor

        self.inputTextField.font = theme.formInputTextFont
        self.inputTextField.textColor = theme.formInputTitleColor
        self.inputTextField.setPlaceholderColor(theme.formInputPlaceholderColor)
        self.inputTextField.textAlignment = .left
        self.inputTextField.borderStyle = .none
        self.inputTextField.autocorrectionType = .no
        self.inputTextField.spellCheckingType = .no
        
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

    public override func setupActions() {
        super.setupActions()
        
        self.inputTextField.addTarget(self, action: #selector(onChangeFieldValue(textField:)), for: .editingChanged)
    }

    @objc
    func onChangeFieldValue(textField: UITextField) {
        guard self.status.isEditable == true else { return }
        guard let item = self.formItem else { return }
        
        item.draftValues = [textField.text].compactMap({ $0 })
        self.status.edting(item: item)
        self.inputTextField.text = self.status.text
        
        self.delegate?.messageFormItemView(self, didUpdate: item)
        
        self.updateInputValidation()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
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
            if errorType.hasError == true {
                self.inputContainer.layer.borderColor = theme.formInputBorderErrorColor.cgColor
                self.errorTitleView.isHidden = false
                self.bottomSpaceView.isHidden = false
            } else {
                self.inputContainer.layer.borderColor = theme.formInputBorderActiveColor.cgColor
                self.bottomSpaceView.isHidden = true
                self.errorTitleView.isHidden = true
            }
        } else {
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
        self.inputTextField.text = self.status.text
        self.inputTextField.isEnabled = self.status.isEditable
        self.inputTextField.isHidden = self.status.didSubmit
        
        self.inputTextLabel.text = self.status.text
        self.inputTextLabel.isHidden = !self.status.didSubmit
        
        self.iconContainer.isHidden = !self.status.didSubmit
    }

    /// Text view delegate methods and called when editing starts
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.isActive = true
    }
    
    /// Text view delegate methods and called when editing end
    public func textFieldDidEndEditing(_ textField: UITextField) {
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
}
