//
//  SBUUnderLineTextField.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/30.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUUnderLineTextField: UITextField {

    // MARK: - UI (Public)
    /// A layer that represents the border of the text field.
    /// - Since: 3.28.0
    public let border = CALayer()
    
    // MARK: - Life cycle
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
    }
    
    open func setupViews() {
        self.layer.addSublayer(border)
    }
    
    open func setupStyles() {
        self.border.borderWidth = 1
        self.layer.masksToBounds = true
    }
    
    open func updateStyles() {
        
    }
    
    open func setupLayouts() {
        
    }
    
    open func updateLayouts() {
        self.border.frame = CGRect(
            x: 0,
            y: self.frame.size.height - self.border.borderWidth,
            width: self.frame.size.width - 10,
            height: self.frame.size.height + self.border.borderWidth
        )
    }
    
    open func updateColor(_ color: UIColor?) {
        guard let color = color else { return }
        
        self.border.borderColor = color.cgColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateStyles()
        self.updateLayouts()
    }
}
