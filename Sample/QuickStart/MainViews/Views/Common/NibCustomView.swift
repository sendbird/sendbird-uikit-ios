//
//  NibCustomView.swift
//  QuickStart
//
//  Created by Damon Park on 2023/08/27.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

class NibCustomView: UIView {
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        let bundle: Bundle  = Bundle(for: type(of: self))
        let nibName: String = "\(type(of: self))".split(separator: ".").map(String.init).last!
        
        let nib: UINib = UINib(nibName: nibName, bundle: bundle)
        let view: UIView = nib.instantiate(withOwner: self, options: nil).compactMap{ $0 as? UIView }.first!
        
        view.frame = bounds
        
        view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(view)
    }
}

