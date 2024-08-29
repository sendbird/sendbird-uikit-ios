//
//  SBUMessageFormFallbackView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 7/4/24.
//

import UIKit

/// The View exposed when the form message version does not valid
/// - Since: 3.27.0
public class SBUMessageFormFallbackView: SBUMessageFormView {
    let container = UIView()
    let titleLabel = UILabel()
    
    public override func setupViews() {
        super.setupViews()
        
        self.container.addSubview(self.titleLabel)
        self.addSubview(self.container)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.2
        self.titleLabel.attributedText = NSMutableAttributedString(
            string: SBUStringSet.FormType_Fallback_Message,
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.container
            .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
            .sbu_constraint_lessThan(width: 244)
        
        self.titleLabel.sbu_constraint(equalTo: self, left: 12, right: 12, top: 6, bottom: 6)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.titleLabel.font = theme.userMessageFont
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textColor = theme.userMessageLeftTextColor
        self.titleLabel.backgroundColor = .clear
        self.container.layer.cornerRadius = 16
        self.container.backgroundColor = theme.leftBackgroundColor
    }
}
