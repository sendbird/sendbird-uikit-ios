//
//  SBUUnderLineTextField.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/30.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUUnderLineTextField: UITextField {

    // MARK: - UI (Private)
    private let border = CALayer()
    
    // MARK: - Life cycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width-10, height: self.frame.size.height)
        
        self.border.borderWidth = 1
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    public func updateColor(_ color: UIColor?) {
        guard let color = color else { return }
        
        self.border.borderColor = color.cgColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.border.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width-10, height: self.frame.size.height)
    }
}
