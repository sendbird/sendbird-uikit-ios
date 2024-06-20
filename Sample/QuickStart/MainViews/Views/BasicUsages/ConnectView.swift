//
//  ConnectView.swift
//  QuickStart
//
//  Created by Damon Park on 2023/08/27.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

class ConnectView: NibCustomView {
    @IBOutlet weak var logoStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var signInStackView: UIStackView!
    @IBOutlet weak var applicationIdTextField: UITextField!
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var selectSampleAppsButton: UIButton!
    
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

extension ConnectView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

