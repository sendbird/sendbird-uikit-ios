//
//  CustomAlertController.swift
//  QuickStart
//
//  Created by Celine Moon on 5/23/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// A view controller that displays Report Category options.
class CustomAlertController: UIViewController {
    var selectedCategory: ReportCategory?
    private var categoryButtons = [RerportCategoryButton]()
    var confirmHandler: ((ReportCategory) -> Void)?
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(tapCancel), for: .touchUpInside)
        button.backgroundColor = SBUColorSet.background100
        button.layer.cornerRadius = 14
        button.setTitleColor(SBUColorSet.background400, for: .normal)
        return button
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.setTitle("Report", for: .normal)
        button.addTarget(self, action: #selector(tapReport), for: .touchUpInside)
        button.backgroundColor = SBUColorSet.background100
        button.layer.cornerRadius = 14
        button.setTitleColor(SBUColorSet.background300, for: .disabled)
        button.setTitleColor(SBUColorSet.primary300, for: .normal)
        return button
    }()
    
    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Container for the alert
        let alertView = UIView()
        alertView.backgroundColor = .white
        alertView.layer.cornerRadius = 20
        alertView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(alertView)

        // Constraints for alertView
        alertView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        alertView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        alertView.widthAnchor.constraint(equalToConstant: 320).isActive = true
        alertView.heightAnchor.constraint(equalToConstant: 334).isActive = true

        // Options stack view
        alertView.addSubview(optionsStackView)

        // Add buttons to the optionsStackView
        for (index, category) in ReportCategory.allCases().enumerated() {
            let button = RerportCategoryButton(type: .custom)
            button.setTitle(category.rawValue, for: .normal)
            button.addTarget(self, action: #selector(tapReportCategory(_:)), for: .touchUpInside)
            button.tag = index
            
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.backgroundColor = .white
            button.layer.borderColor = SBUColorSet.primary300.cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 14
            button.setTitleColor(SBUColorSet.primary300, for: .normal)
            button.setTitleColor(.white, for: .selected)
            
            optionsStackView.addArrangedSubview(button)
            categoryButtons.append(button)
        }

        // Cancel, Confirm buttons
        alertView.addSubview(actionStackView)
        actionStackView.addArrangedSubview(cancelButton)
        actionStackView.addArrangedSubview(confirmButton)

        // Layout stack views
        optionsStackView.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 30).isActive = true
        optionsStackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20).isActive = true
        optionsStackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20).isActive = true
        optionsStackView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        actionStackView.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 30).isActive = true
        actionStackView.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20).isActive = true
        actionStackView.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20).isActive = true
        actionStackView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    @objc func tapReportCategory(_ sender: UIButton) {
        self.selectedCategory = ReportCategory.allCases()[sender.tag]
        print("selected: \(selectedCategory?.rawValue ?? "(no report category selected)")")
        
        for button in categoryButtons {
            button.isSelected = (button == sender)
        }
        confirmButton.isEnabled = true
    }

    @objc func tapCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func tapReport() {
        if let selectedCategory = self.selectedCategory {
            confirmHandler?(selectedCategory)
        }
        dismiss(animated: true, completion: nil)
    }
}

private class RerportCategoryButton: UIButton {
    override open var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            backgroundColor = isSelected ? SBUColorSet.primary300 : UIColor.white
        }
    }
}
