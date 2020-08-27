//
//  SBUMessageInputView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import Photos
import AVKit

@objc public protocol SBUMessageInputViewDelegate: NSObjectProtocol {
    @objc optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String)
    @objc optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectResource type: MediaResourceType)
    @objc optional func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String)
    @objc optional func messageInputViewDidStartTyping()
    @objc optional func messageInputViewDidEndTyping()
}


@IBDesignable @objcMembers
open class SBUMessageInputView: UIView, SBUActionSheetDelegate, UITextViewDelegate {
    @IBOutlet public weak var addButton: UIButton!
    @IBOutlet public weak var placeholderLabel: UILabel!
    @IBOutlet public weak var textView: UITextView!
    @IBOutlet public weak var sendButton: UIButton!

    @IBOutlet public weak var editView: UIView!
    @IBOutlet public weak var cancelButton: UIButton!
    @IBOutlet public weak var saveButton: UIButton!
    var basedText: String = ""

    @IBOutlet weak var textViewHieghtConstraint: NSLayoutConstraint!

    weak var delegate: SBUMessageInputViewDelegate?
    
    var isFrozen: Bool = false
    var isMuted: Bool = false

    // MARK: - Theme
    var theme: SBUMessageInputTheme = SBUTheme.messageInputTheme

    let cameraItem = SBUActionSheetItem(title: SBUStringSet.Camera)
    let libraryItem = SBUActionSheetItem(title: SBUStringSet.PhotoVideoLibrary)
    let documentItem = SBUActionSheetItem(title: SBUStringSet.Document)
    let cancelItem = SBUActionSheetItem(title: SBUStringSet.Cancel)

    
    // MARK: - View Lifecycle
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @available(*, unavailable, renamed: "SBUMessageInputView.sbu_loadViewFromNib()")
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "SBUMessageInputView.sbu_loadViewFromNib()")
    public init() {
        super.init(frame: .zero)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    /// This function handles the initialization of views.
    open func setupViews() {
        // textView
        self.textView.textContainerInset = UIEdgeInsets(top: 10, left: 9, bottom: 10, right: 16)
        self.textView.layer.borderWidth = 1
        self.textView.layer.cornerRadius = 20
        self.textView.delegate = self

        // saveButton
        self.saveButton.layer.cornerRadius = 4
    }
     
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.backgroundColor = theme.backgroundColor

        // placeholderLabel
        self.placeholderLabel.font = theme.textFieldPlaceholderFont
        if self.isFrozen {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Unavailable
            self.placeholderLabel.textColor = theme.textFieldDisabledColor
        }
        else if self.isMuted {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Muted
            self.placeholderLabel.textColor = theme.textFieldDisabledColor
        }
        else {
            self.placeholderLabel.text = SBUStringSet.MessageInput_Text_Placeholder
            self.placeholderLabel.textColor = theme.textFieldPlaceholderColor
        }

        // textView
        self.textView.backgroundColor = theme.textFieldBackgroundColor
        self.textView.tintColor = theme.textFieldTintColor
        self.textView.textColor = theme.textFieldTextColor
        self.textView.layer.borderColor = theme.textFieldBorderColor.cgColor
        
        // addButton
        let iconAdd = SBUIconSet.iconAdd
            .sbu_with(tintColor:
                (self.isFrozen || self.isMuted)
                ? theme.buttonDisabledTintColor
                : theme.buttonTintColor)
        self.addButton.setImage(iconAdd, for: .normal)
        
        // IconSend
        self.sendButton.setImage(SBUIconSet.iconSend
            .sbu_with(tintColor: theme.buttonTintColor), for: .normal)
        
        // cancelButton
        self.cancelButton.titleLabel?.font = theme.cancelButtonFont
        self.cancelButton.titleLabel?.textColor = theme.buttonTintColor
        
        // saveButton
        self.saveButton.backgroundColor = theme.buttonTintColor
        self.saveButton.titleLabel?.font = theme.saveButtonFont
        self.saveButton.titleLabel?.textColor = theme.saveButtonTextColor
        
        // Item
        self.cameraItem.image = SBUIconSet.iconCamera.sbu_with(tintColor: theme.buttonTintColor)
        self.libraryItem.image = SBUIconSet.iconPhoto.sbu_with(tintColor: theme.buttonTintColor)
        self.documentItem.image = SBUIconSet.iconDocument.sbu_with(tintColor: theme.buttonTintColor)
        self.cancelItem.color = theme.buttonTintColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }
     
    // MARK: - Edit View
    public func startEditMode(text: String) {
        self.textView.text = text
        self.basedText = text
        
        self.addButton.isHidden = true
        self.addButton.alpha = 0
        
        self.sendButton.isHidden = true
        self.sendButton.alpha = 0
        
        self.editView.isHidden = false
        self.editView.alpha = 1

        self.updateTextViewHeight()
        let bottom = NSMakeRange(self.textView.text.count - 1, 1)
        self.textView.scrollRangeToVisible(bottom)
        
        self.textView.becomeFirstResponder()

        self.layoutIfNeeded()
    }
    
    public func endEditMode() {
        self.textView.text = ""
        self.basedText = ""
        
        self.addButton.isHidden = false
        self.addButton.alpha = 1
        
        self.editView.isHidden = true
        self.editView.alpha = 0

        self.updateTextViewHeight()
        
        self.layoutIfNeeded()
    }
    
    // MARK: State
    
    /// Sets frozen mode state.
    /// - Parameter isFrozen `true` is frozen mode, `false` is unfrozen mode
    public func setFrozenModeState(_ isFrozen: Bool) {
        self.isFrozen = isFrozen
        
        self.textView.isEditable = !self.isFrozen
        self.textView.isUserInteractionEnabled = !self.isFrozen
        self.addButton.isEnabled = !self.isFrozen
        
        self.endEditMode()
        self.endTypingMode()
        self.setupStyles()
    }
    
    /// Sets frozen mode state.
    /// - Parameter isMuted `true` is muted mode, `false` is unmuted mode
    public func setMutedModeState(_ isMuted: Bool) {
        self.isMuted = isMuted
        
        self.textView.isEditable = !self.isMuted
        self.textView.isUserInteractionEnabled = !self.isMuted
        self.addButton.isEnabled = !self.isMuted
        
        self.endEditMode()
        self.endTypingMode()
        self.setupStyles()
    }
    
    // MARK: Common
    public func endTypingMode() {
        self.textView.text = ""
        self.sendButton.isHidden = true
        self.sendButton.alpha = 0
        self.endEditMode()
        self.layoutIfNeeded()
    }

    public func updateTextViewHeight() {
        self.placeholderLabel.isHidden = !self.textView.text.isEmpty

        switch self.textView.contentSize.height {
        case ..<38:
            self.textViewHieghtConstraint.constant = 38
        case 38...87:
            self.textViewHieghtConstraint.constant = self.textView.contentSize.height
        default:
            self.textViewHieghtConstraint.constant = 87
        }
    }

    // MARK: - Action
    @IBAction open func onClickAddButton(_ sender: Any) {
        self.endEditing(true)
        let itmes = [self.cameraItem, self.libraryItem, self.documentItem]
        SBUActionSheet.show(items: itmes, cancelItem: self.cancelItem, delegate: self)
    }
    
    @IBAction open func onClickSendButton(_ sender: Any) {
        self.delegate?.messageInputView?(
            self,
            didSelectSend: self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        self.updateTextViewHeight()
    }
    
    @IBAction open func onClickCancelButton(_ sender: Any) {
        self.endEditMode()
    }
    
    @IBAction open func onClickSaveButton(_ sender: Any) {
        let editedText = self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard basedText != editedText else {
            self.endEditMode()
            return
        }
        self.delegate?.messageInputView?(
            self,
            didSelectEdit: self.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    // MARK: UITextViewDelegate
    public func textViewDidChange(_ textView: UITextView) {
        guard self.editView.isHidden else { self.updateTextViewHeight(); return }

        let text = textView.text ?? ""
        self.sendButton.isHidden = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        self.sendButton.alpha = text.isEmpty ? 0 : 1
        self.updateTextViewHeight()

        self.layoutIfNeeded()
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        self.delegate?.messageInputViewDidEndTyping?()
    }

    public func textView(_ textView: UITextView,
                         shouldChangeTextIn range: NSRange,
                         replacementText text: String) -> Bool {
        if text.count > 0 {
            self.delegate?.messageInputViewDidStartTyping?()
        } else if text.count == 0, textView.text?.count ?? 0 <= 1 {
            self.delegate?.messageInputViewDidEndTyping?()
        }

        return true
    }

    // MARK: SBUActionSheetDelegate
    func didSelectActionSheetItem(index: Int, identifier: Int) {
        let type = MediaResourceType.init(rawValue: index) ?? .unknown
        if type == .camera, AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success == false {
                    // TODO: Request camera capture permission
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.messageInputView?(self, didSelectResource: type)
                    }
                }
            }
        } else if type == .library, PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                if status != .authorized {
                    // TODO: Request photo library permission
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.delegate?.messageInputView?(self, didSelectResource: type)
                    }
                }
            })
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.messageInputView?(self, didSelectResource: type)
            }
        }
    }

}
