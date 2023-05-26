//
//  SBUCreateOpenChannelModule.ProfileInput.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/24.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the profile input component.
public protocol SBUCreateOpenChannelModuleProfileInputDelegate: SBUCommonDelegate {
    /// Called when the changed text in th `profileInputComponent`.
    /// - Parameters:
    ///    - profileInputComponent: `SBUCreateOpenChannelModule.ProfileInput` object.
    ///    - string: An text in textFiled of `profileInputComponent
    func createOpenChannelModule(_ profileInputComponent: SBUCreateOpenChannelModule.ProfileInput, shouldChangeChannelName string: String)
    
    /// Called when the selected channel image in `profileInputComponent`.
    /// - Parameters:
    ///   - profileInputComponent: `SBUCreateOpenChannelModule.ProfileInput` object.
    ///   - needRemoveItem: If the image is already set, set the needRemoveItem to `true`and activate the deletion option.
    func createOpenChannelModuleDidSelectChannelImage(_ profileInputComponent: SBUCreateOpenChannelModule.ProfileInput, needRemoveItem: Bool)
}

extension SBUCreateOpenChannelModule {
    
    /// A module component that represent the profile input of `SBUCreateOpenChannelModule`.
    @objc(SBUCreateOpenChannelModuleProfileInput)
    open class ProfileInput: UIView, UITextFieldDelegate {
        
        // MARK: - UI properties (Public)
        public lazy var baseStackView: SBUStackView = {
            let hStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 16)
            return hStackView
        }()
        
        public lazy var channelImageView: SBUCoverImageView = {
            let coverImage = SBUCoverImageView()
            coverImage.frame = CGRect(
                x: 0,
                y: 0,
                width: kCoverImageSize,
                height: kCoverImageSize
            )
            return coverImage
        }()
        
        public var channelNameInputField: SBUUnderLineTextField = {
            let textField = SBUUnderLineTextField()
            textField.textAlignment = .left
            textField.leftViewMode = .always
            textField.rightView = nil
            textField.rightViewMode = .never
            textField.returnKeyType = .done
            textField.clearButtonMode = .whileEditing

            return textField
        }()
        
        /// The object that is used as the theme of the profile input component. The theme must adopt the `SBUCreateOpenChannelTheme` class.
        public var theme: SBUCreateOpenChannelTheme?
        
        // MARK: - Logic properties (Public)

        /// The object that acts as the delegate of the profile input component. The delegate must adopt the `SBUCreateOpenChannelModuleProfileInputDelegate`.
        public weak var delegate: SBUCreateOpenChannelModuleProfileInputDelegate?
        
        private var isImageSelected: Bool = false
        private let kCoverImageSize: CGFloat = 80.0
        private let placeholderIconSize: CGSize = .init(width: 46, height: 46)
        private var coverImage: UIImage?
        
        // MARK: Lifecycle
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUCreateOpenChannelModuleProfileInputDelegate` type listener
        ///   - theme: `SBUCreateOpenChannelTheme` object
        open func configure(
            delegate: SBUCreateOpenChannelModuleProfileInputDelegate?,
            theme: SBUCreateOpenChannelTheme
        ) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupLayouts()
        }
        
        open func setupViews() {
            self.channelImageView.addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(showImagePicker(sender:)))
            )
            
            self.channelImageView.setPlaceholder(type: .iconCamera, iconSize: placeholderIconSize)
            self.channelImageView.clipsToBounds = true
            
            self.channelNameInputField.delegate = self
            
            self.baseStackView.setHStack([
                self.channelImageView,
                self.channelNameInputField
            ])
            
            self.addSubview(self.baseStackView)
        }
        
        // MARK: - Style
        open func setupLayouts() {
            self.baseStackView
                .sbu_constraint(equalTo: self, leading: 16, trailing: -16, top: 16)
            
            self.channelImageView
                .sbu_constraint(width: kCoverImageSize, height: kCoverImageSize)
            
            self.channelNameInputField
                .sbu_constraint(height: kCoverImageSize/2)
            
        }
        
        open func setupStyles(theme: SBUCreateOpenChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            self.channelNameInputField.font = self.theme?.textFieldFont
            self.channelNameInputField.textColor = self.theme?.textFieldTextColor
            self.channelNameInputField.placeholder = SBUStringSet.CreateOpenChannel_ProfileInput_Placeholder
            self.channelNameInputField.updateColor(self.theme?.textFieldUnderlineColor)
            
            self.channelNameInputField.setPlaceholderColor(self.theme?.textFieldPlaceholderColor)
        }
        
        open override func layoutSubviews() {
            super.layoutSubviews()
            
            self.channelImageView.layer.cornerRadius = kCoverImageSize / 2
        }
        
        // MARK: - Common
        
        /// Gets channel name string
        /// - Returns: channel name
        public func getChannelName() -> String? {
            return self.channelNameInputField.text
        }
        
        /// Gets channel cover image object.
        /// - Returns: The channel cover image.
        public func getChannelCoverImage() -> UIImage? {
            return self.coverImage ?? nil
        }
        
        /// Updates channel image
        /// - Parameter image: Image to be updated
        open func updateChannelImage(_ image: UIImage?) {
            if let image = image {
                self.isImageSelected = true
                self.coverImage = image
                self.channelImageView.setImage(withImage: image)
            } else {
                self.isImageSelected = false
                self.coverImage = nil
                self.channelImageView.setPlaceholder(type: .iconCamera, iconSize: placeholderIconSize)
            }
        }
        
        // MARK: - Action
        @objc open func showImagePicker(sender: UITapGestureRecognizer) {
            self.delegate?.createOpenChannelModuleDidSelectChannelImage(self, needRemoveItem: self.isImageSelected)
        }
        
        open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            let nsText = NSString(string: textField.text ?? "")
            let replacedText = nsText.replacingCharacters(in: range, with: string) as String
            
            self.delegate?.createOpenChannelModule(self, shouldChangeChannelName: replacedText)
            
            return true
        }
    }
}
