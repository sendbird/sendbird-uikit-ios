//
//  SBUNewNotificationInfo.swift
//  QuickStart
//
//  Created by Tez Park on 2023/03/02.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import QuartzCore

public typealias SBUNewNotificationInfoHandler = () -> Void

class SBUNewNotificationInfo: SBUView {
    // MARK: - Properties (Public)
    lazy var newNotificationInfoButton: UIButton? = {
        let newNotificationInfoButton = UIButton()
        newNotificationInfoButton.layer.masksToBounds = true
        newNotificationInfoButton.tag = DefaultInfoButtonTag
        newNotificationInfoButton.titleLabel?.textAlignment = .center
        return newNotificationInfoButton
    }()
    
    var actionHandler: SBUNewNotificationInfoHandler?
    
    // MARK: - Properties (Private)
    let DefaultInfoButtonTag = 10001

    @SBUThemeWrapper(theme: SBUTheme.notificationTheme.list)
    var theme: SBUNotificationTheme.List
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// This function Initializes the new message information item.
    /// - Parameter type: Type of new message info item (default: tooltip)
    override init() {
        super.init(frame: .zero)
    }
    
    @available(*, unavailable, renamed: "SBUNewNotificationInfo.init(frame:)")
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }

    /// This function handles the initialization of views.
    override func setupViews() {
        if let newNotificationInfoButton = self.newNotificationInfoButton {
            newNotificationInfoButton.addTarget(
                self,
                action: #selector(onTapNewNotificationInfo),
                for: .touchUpInside
            )
            self.addSubview(newNotificationInfoButton)
        }
    }
    
    /// This function handles the initialization of autolayouts.
    override func setupLayouts() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: SBUConstant.newNotificationInfoSize.height),
        ])
        
        if let newNotificationInfoButton = self.newNotificationInfoButton {
            newNotificationInfoButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newNotificationInfoButton.leftAnchor.constraint(equalTo: self.leftAnchor),
                newNotificationInfoButton.rightAnchor.constraint(equalTo: self.rightAnchor),
                newNotificationInfoButton.topAnchor.constraint(equalTo: self.topAnchor),
                newNotificationInfoButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
        }
    }
    
    /// This function handles the initialization of styles.
    override func setupStyles() {
        self.backgroundColor = .clear
        self.layer.masksToBounds = false
        
        setupButtonStyle()
        
        if let newNotificationInfoButton = self.newNotificationInfoButton,
           newNotificationInfoButton.tag == DefaultInfoButtonTag {
            
            newNotificationInfoButton.titleLabel?.font = theme.tooltipFont
            newNotificationInfoButton.setTitleColor(theme.tooltipTextColor, for: .normal)
            newNotificationInfoButton.setBackgroundImage(
                UIImage.from(color: theme.tooltipBackgroundColor),
                for: .normal
            )
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    private func setupButtonStyle() {
        self.newNotificationInfoButton?.layer.cornerRadius = self.frame.height / 2
        self.newNotificationInfoButton?.clipsToBounds = true
    }

    // MARK: - Action
    @objc func onTapNewNotificationInfo() {
        self.actionHandler?()
    }
    
    // MARK: - Count
    /// This function updates the count of new messages and sets the button's action.
    /// - Parameters:
    ///   - count: Message count
    ///   - actionHandler: Button's action handler
    func updateCount(count: Int, actionHandler: SBUNewNotificationInfoHandler?) {
        if let newNotificationInfoButton = self.newNotificationInfoButton {
            newNotificationInfoButton.setTitle(SBUStringSet.Channel_New_Message(count), for: .normal)
            newNotificationInfoButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            newNotificationInfoButton.sizeToFit()
        }
        self.actionHandler = actionHandler
    }
}
