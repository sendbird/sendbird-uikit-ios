//
//  MainItemView.swift
//  QuickStart
//
//  Created by Damon Park on 2023/08/27.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

class MainItemView: NibCustomView {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseView.backgroundColor = .white
        baseView.layer.cornerRadius = ViewController.CornerRadius.large.rawValue
        
        shadowView.layer.cornerRadius = ViewController.CornerRadius.large.rawValue
        shadowView.layer.shadowRadius = ViewController.CornerRadius.large.rawValue
        shadowView.layer.shadowOffset.height = 8.0
        shadowView.layer.shadowOpacity = 0.12
        
        unreadCountLabel.textColor = SBUColorSet.ondark01
        unreadCountLabel.font = SBUFontSet.caption1
        unreadCountLabel.backgroundColor = SBUColorSet.error300
        unreadCountLabel.layer.cornerRadius = unreadCountLabel.frame.height / 2
        unreadCountLabel.layer.masksToBounds = true
    }
}
