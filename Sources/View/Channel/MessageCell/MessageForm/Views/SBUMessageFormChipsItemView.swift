//
//  SBUMessageFormChipsItemView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 7/2/24.
//

import UIKit
import SendbirdChatSDK

/// Item view of a message form with a chip design
/// - Since: 3.27.0
public class SBUMessageFormChipsItemView: SBUMessageFormItemView, SBUMesageFormChipViewDelegate {
    /// A vertical stack view to configure layouts of the fields.
    public var stackView = SBUStackView(axis: .vertical, alignment: .leading, spacing: 0)
    /// A horizontal stack view to configure layouts of `title` and `optional`.
    public var titleStackView = SBUStackView(axis: .horizontal, alignment: .fill, spacing: 3)
    /// The `UILabel` displaying form field title.`
    public var titleView = UILabel()
    /// Top space view.
    public var topSpaceView = UIView()
    /// A chip collection view.
    public let chipView = SBUMesageFormChipView()
    /// Bottom space view. can be hidden. Used only if there is an error message.
    public var bottomSpaceView = UIView()
    /// The `UILabel` displaying the error message.
    public var errorTitleView = UILabel()
    /// List of chips values.
    public var chips: [String] { formItem?.style.options ?? [] }
    
    public override func setupViews() {
        super.setupViews()
        
        // + -- stackView ------------------------- +
        // | + --- titleStackView --------------- + |
        // | | titleView                          | |
        // | + ---------------------------------- + |
        // + -------------------------------------- +
        // | topSpaceView                           |
        // + -------------------------------------- +
        // | chipView                               |
        // + -------------------------------------- +
        // | bottomSpaceView                        |
        // + -------------------------------------- +
        // | errorTitleView                         |
        // + -------------------------------------- +
        
        self.updateDefaultOptions()
        self.titleView.text = self.formItem?.name
        self.chipView.delegate = self

        self.titleStackView.setHStack([self.titleView])

        self.stackView.setVStack([
            self.titleStackView,
            self.topSpaceView,
            self.chipView,
            self.bottomSpaceView,
            self.errorTitleView
        ])
        
        self.addSubview(stackView)
        
        self.titleView.attributedText = self.titleAttributedString
        
        self.errorTitleView.text = SBUStringSet.FormType_Error_Default
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
    
        self.titleView.sbu_constraint_greaterThan(height: 12)
        
        self.errorTitleView.sbu_constraint(height: 12)

        self.topSpaceView.sbu_constraint(width: 1, height: 6, priority: .defaultHigh)
        self.bottomSpaceView.sbu_constraint(width: 1, height: 4, priority: .defaultHigh)
        
        self.chipView
            .sbu_constraint(equalTo: self.stackView, left: 0, right: 0)
        
        self.chipView.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
        self.chipView.setContentHuggingPriority(UILayoutPriority(249), for: .vertical)
        
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

        self.updateInputValidation()
        self.updateInputData()
        self.updateChips()
    }
    
    func updateInputValidation() {
        self.bottomSpaceView.isHidden = true
        self.errorTitleView.isHidden = true
        
        let errorType = self.isValidInput()
        
        if errorType.hasError == true {
            self.errorTitleView.isHidden = false
            self.errorTitleView.text = errorType.errorMessage
            self.bottomSpaceView.isHidden = false
        }
    }
    
    func updateInputData() {
        // do nothing
    }
    
    func updateChips() {
        self.chipView.update(chips: self.chips, status: self.status)
    }
    
    func updateDefaultOptions() {
        guard let item = self.formItem,
              let defaultOptions = item.style.defaultOptions,
              self.status.isEditable == true,
              item.draftValues == nil
        else { return }
        
        item.draftValues = defaultOptions
        self.status.edting(item: item)
    }
    
    private func createHorizontalStackView() -> UIStackView {
        let stackView = SBUStackView(axis: .horizontal, alignment: .leading, spacing: 8)
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    // MARK: - SBUMesageFormChipDelegate
    func messageFormChipView(_ chip: SBUMesageFormChipView, didSelect value: String) {
        guard self.status.isEditable == true else { return }
        guard let item = self.formItem else { return }
        guard let resultCount = item.style.resultCount else { return }
        
        let draftValues = item.draftValues ?? []
        
        var values: [String] = []
        
        if resultCount.isOnlyOne == true {
            if item.required == true {
                values = [value]
            } else {
                values = draftValues.contains(value) ? [] : [value]
            }
        } else {
            values = draftValues.toggle(value)
        }
        
        if resultCount.canUpdate(values) == false { return }
        
        item.draftValues = values
        
        self.status.edting(item: item)
        self.updateChips()
        self.updateInputValidation()
        
        self.delegate?.messageFormItemView(self, didUpdate: item)        
    }
    
    func isValidInput() -> InputErrorType {
        guard let item = self.formItem else { return .none }
        
        let values = item.draftValues ?? []
        
        if values.count == 0 {
            if didValidation == false { return .none }
            return item.required ? .required : .none
        }
        if item.style.resultCount?.isValid(values) == false {
            return .invalid
        }
        return item.isValid(values) ? .none : .invalid
    }
}
