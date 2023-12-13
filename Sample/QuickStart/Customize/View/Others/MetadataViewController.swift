//
//  MetadataViewController.swift
//  QuickStart
//
//  Created by Celine Moon on 12/5/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// MARK: - Metadata Create, Update, Delete VC
class MetadataViewController: UIViewController {
    let metadataLabel: PaddedLabel = {
        let label = PaddedLabel()
        label.textInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        label.text = "channel metadata"
        label.layer.cornerRadius = 13
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.black.cgColor
        label.numberOfLines = 0
        return label
    }()
    
    let metadataKeyTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "(Channel Metadata) KEY"
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    let metadataValueTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "(Channel Metadata) VALUE"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let createButton: UIButton = {
       let button = UIButton()
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.systemGreen, for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        return button
    }()
    
    let updateButton: UIButton = {
       let button = UIButton()
        button.setTitle("Update", for: .normal)
        button.setTitleColor(.systemOrange, for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        return button
    }()
    
    let deleteButton: UIButton = {
       let button = UIButton()
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.setTitleColor(.systemGray, for: .disabled)
        return button
    }()
    
    var channel: GroupChannel
    var mode: MetadataMode
    
    var metadataKey: String?
    var metadataValue: String?
    
    init(channel: GroupChannel, mode: MetadataMode) {
        self.channel = channel
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(metadataLabel)
        self.view.addSubview(metadataKeyTextField)
        self.view.addSubview(metadataValueTextField)
        self.view.addSubview(createButton)
        self.view.addSubview(updateButton)
        self.view.addSubview(deleteButton)
        
        metadataLabel.translatesAutoresizingMaskIntoConstraints = false
        metadataKeyTextField.translatesAutoresizingMaskIntoConstraints = false
        metadataValueTextField.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = 8.0
        
        NSLayoutConstraint.activate([
            metadataLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            metadataLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -300),
            metadataLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            metadataLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        NSLayoutConstraint.activate([
            metadataKeyTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            metadataKeyTextField.topAnchor.constraint(equalTo: metadataLabel.bottomAnchor, constant: margin),
            metadataKeyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            metadataKeyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            metadataKeyTextField.heightAnchor.constraint(equalToConstant: 40),
        ])

        // Constraints for textField2
        NSLayoutConstraint.activate([
            metadataValueTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            metadataValueTextField.topAnchor.constraint(equalTo: metadataKeyTextField.bottomAnchor, constant: margin),
            metadataValueTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            metadataValueTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            metadataValueTextField.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        NSLayoutConstraint.activate([
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.topAnchor.constraint(equalTo: metadataValueTextField.bottomAnchor, constant: margin),
            createButton.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        NSLayoutConstraint.activate([
            updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateButton.topAnchor.constraint(equalTo: createButton.bottomAnchor, constant: margin),
            updateButton.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        NSLayoutConstraint.activate([
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: margin),
            deleteButton.widthAnchor.constraint(equalToConstant: 80),
        ])
        
        // data setup
        let initialMetdata = channel.getCachedMetaData()
        metadataLabel.text = initialMetdata.isEmpty ? "no channel metadata" : initialMetdata.description
        
        metadataKeyTextField.delegate = self
        metadataValueTextField.delegate = self
        
        switch mode {
        case .create:
            metadataValueTextField.isEnabled = true
            createButton.isEnabled = true
            updateButton.isEnabled = false
            deleteButton.isEnabled = false
        case .update:
            metadataValueTextField.isEnabled = true
            createButton.isEnabled = false
            updateButton.isEnabled = true
            deleteButton.isEnabled = false
        case .delete:
            metadataValueTextField.isEnabled = false
            createButton.isEnabled = false
            updateButton.isEnabled = false
            deleteButton.isEnabled = true
        }
        
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    @objc func createButtonTapped() {
        guard let key = self.metadataKey,
              let value = self.metadataValue else { return }
        
        let metadata = [key: value]
        channel.createMetaData(metadata) { metaData, error in
            let successMessage =
            """
            Successfully created
            metadata \(String(describing: metaData))
            """
            
            let failedMessage =
            """
            Failed to create metadata.
            \(String(describing: error))
            """
            
            let alert = UIAlertController(
                title: error == nil ? "✅" : "❌",
                message: error == nil ? successMessage : failedMessage,
                preferredStyle: .alert
            )
            
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            
            if error == nil {
                let metadata = self.channel.getCachedMetaData()
                self.metadataLabel.text = metadata.description
            }
        }
    }
    
    @objc func updateButtonTapped() {
        guard let key = self.metadataKey,
              let value = self.metadataValue else { return }
        
        let metadata = [key: value]
        channel.updateMetaData(metadata) { metaData, error in
            let successMessage =
            """
            Successfully updated
            metadata \(String(describing: metaData))
            """
            
            let failedMessage =
            """
            Failed to update metadata.
            \(String(describing: error))
            """
            
            let alert = UIAlertController(
                title: error == nil ? "✅" : "❌",
                message: error == nil ? successMessage : failedMessage,
                preferredStyle: .alert
            )
            
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            if error == nil {
                let metadata = self.channel.getCachedMetaData()
                self.metadataLabel.text = metadata.description
            }
        }
    }
    
    @objc func deleteButtonTapped() {
        guard let key = self.metadataKey else { return }
        
        channel.deleteMetaData(key: key) { error in
            let successMessage =
            """
            Successfully deleted
            metadata \(key)
            """
            
            let failedMessage =
            """
            Failed to delete metadata.
            \(key)
            """
            
            let alert = UIAlertController(
                title: error == nil ? "✅" : "❌",
                message: error == nil ? successMessage : failedMessage,
                preferredStyle: .alert
            )
            
            let ok = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
            
            if error == nil {
                let metadata = self.channel.getCachedMetaData()
                self.metadataLabel.text = metadata.description
            }
        }
    }
}

extension MetadataViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.metadataKeyTextField {
            self.metadataKey = textField.text
        } else if textField == self.metadataValueTextField {
            self.metadataValue = textField.text
        }
        
        if let currentText = textField.text, let textRange = Range(range, in: currentText) {
            let updatedText = currentText.replacingCharacters(in: textRange, with: string)
            
            if textField == self.metadataKeyTextField {
                self.metadataKey = updatedText
            } else if textField == self.metadataValueTextField {
                self.metadataValue = updatedText
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.metadataKeyTextField {
            self.metadataKey = textField.text
        } else if textField == self.metadataValueTextField {
            self.metadataValue = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.metadataKeyTextField {
            self.metadataKey = textField.text
        } else if textField == self.metadataValueTextField {
            self.metadataValue = textField.text
        }
        textField.resignFirstResponder()
        return true
      }
}

enum MetadataMode: Int {
    case create
    case update
    case delete
}
