//
//  ConnectBusinessMessagingView.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/22/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit

class ConnectBusinessMessagingView: NibCustomView {
    @IBOutlet weak var selectSampleAppsButton: UIButton!
    @IBOutlet weak var applicationIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var feedOnlySwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        signInButton.layer.cornerRadius = ViewController.CornerRadius.small.rawValue
        [applicationIdTextField, userIdTextField, nicknameTextField].forEach {
            guard let textField = $0 else { return }
            let paddingView = UIView(frame: CGRect(
                x: 0,
                y: 0,
                width: 16,
                height: textField.frame.size.height)
            )
            textField.leftView = paddingView
            textField.delegate = self
            textField.leftViewMode = .always
            textField.layer.borderWidth = 1
            textField.layer.cornerRadius = ViewController.CornerRadius.small.rawValue
            textField.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            textField.tintColor = #colorLiteral(red: 0.4666666667, green: 0.337254902, blue: 0.8549019608, alpha: 1)
        }
    }
}

extension ConnectBusinessMessagingView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
