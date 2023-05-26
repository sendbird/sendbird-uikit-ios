//
//  SBUIconSetType.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/01/22.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Sendbird's icon set type enumerate.
/// - Since: 3.2.0
public enum SBUIconSetType: String, Hashable {
    case iconAdd
    case iconBack
    case iconBan
    case iconBroadcast
    case iconCamera
    case iconChat
    case iconChannels
    case iconCheckboxChecked
    case iconCheckboxUnchecked
    case iconChevronDown
    case iconChevronRight
    case iconClose
    case iconCopy
    case iconCreate
    case iconDocument
    case iconDelete
    case iconDone
    case iconDoneAll
    case iconDownload
    case iconEdit
    case iconEmojiMore
    case iconEmpty
    case iconError
    case iconFileAudio
    case iconFileDocument
    case iconFreeze
    case iconGif
    case iconInfo
    case iconLeave
    case iconMembers
    case iconMessage
    case iconModerations
    case iconMore
    case iconMute
    case iconNotificationFilled
    case iconNotificationOffFilled
    case iconNotifications
    case iconOperator
    case iconPhoto
    case iconPlay
    case iconPlus
    case iconQuestion
    case iconRefresh
    case iconRemove
    case iconReply
    case iconReplied
    case iconSearch
    case iconSend
    case iconSpinner
    case iconSupergroup
    case iconThumbnailNone
    case iconUser
    case iconRadioButtonOn
    case iconRadioButtonOff
    case iconThread
    case iconVoiceMessageOn
    case iconPause
    case iconRecording
    case iconStop
    
    // MARK: - Metric
    
    struct Metric {
        static let defaultIconSizeVerySmall = CGSize(value: 12)
        static let defaultIconSizeSmall = CGSize(value: 16)
        static let defaultIconSizeMedium = CGSize(value: 18)
        static let defaultIconSize = CGSize(value: 24)
        static let defaultIconSizeLarge = CGSize(value: 32)
        static let defaultIconSizeVeryLarge = CGSize(value: 48)
        static let quotedMessageIconSize = CGSize(value: 20)
        static let iconActionSheetItem = defaultIconSize
        static let iconEmojiSmall = CGSize(value: 20)
        static let iconEmojiLarge = CGSize(value: 38)
        static let iconEmptyView = CGSize(value: 60)
        static let iconGifPlay = CGSize(value: 28)
        static let iconSpinnerLarge = CGSize(value: 40)
        static let iconSpinnerSizeForTemplate = CGSize(value: 36)
        static let iconUserProfile = CGSize(value: 40)
        static let iconUserProfileInChat = CGSize(value: 15)
        static let iconChevronDown = CGSize(value: 22)
        static let iconVoiceMessageSize = CGSize(value: 20)
    }
    
    // MARK: - Image handling
    
    private static let bundle = Bundle(identifier: SBUConstant.bundleIdentifier)
    
    func load(tintColor: UIColor? = nil) -> UIImage {
        guard let image = UIImage(named: self.rawValue, in: SBUIconSetType.bundle, compatibleWith: nil) else {
            return UIImage()
        }
        guard let tintColor = tintColor else { return image }
        
        return image.sbu_with(tintColor: tintColor)
    }
    
    /// Applies tint & resize to given values.
    /// - Parameters:
    ///     - tintColor: Tint color to apply to the icon. Tint is applied to default icons according to `tintAndResize` flag.
    ///     - size: Size for the icon to be resized to. Resizing is applied to default icons according to `tintAndResize` flag.
    ///     - tintAndResize: Whether to apply tint & resized icons for customized icons as well.
    /// - Returns: `UIImage` with tint applied & resized if possible. When the icon is the customized image and ``SBUGlobals.isTintColorEnabledForCustomizedIcon`` is `false`, doesn't use `tintColor`. When the icon is the customized image and ``SBUGlobals.isCustomizedIconResizable`` is `false`, doesn't use `size`
    func image(with tintColor: UIColor? = nil, to size: CGSize, tintAndResize: Bool = true) -> UIImage {
        // TODO: Update logic for better DX of `tintAndResize`
        // Prevents customized icons from being applied with tintColor.
        let isCustomized = SBUIconSetType.customizedIcons.contains(self)
        
        if isCustomized {
            // Apply tint.
            let resultImage = (SBUGlobals.isTintColorEnabledForCustomizedIcon && tintAndResize)
            ? self.image.sbu_with(tintColor: tintColor)
            : self.image
            
            // Apply resize.
            return (SBUGlobals.isCustomizedIconResizable && tintAndResize)
            ? resultImage.resize(with: size)
            : resultImage
        } else {
            // Apply tint and resize
            return tintAndResize
            ? self.image.sbu_with(tintColor: tintColor).resize(with: size)
            : self.image
        }
    }
    
    func markCustomized() {
        SBUIconSetType.customizedIcons.insert(self)
    }
    
    static func resetCustomized() {
        let customized = SBUIconSetType.customizedIcons.map { $0 }
        customized.forEach { $0.loadDefault() }
        
        SBUIconSetType.customizedIcons.removeAll()
    }
    
    func loadDefault() {
        switch self {
        case .iconAdd: SBUIconSet.iconAdd = SBUIconSetType.iconAdd.load()
        case .iconBack: SBUIconSet.iconBack = SBUIconSetType.iconBack.load()
        case .iconBan: SBUIconSet.iconBan = SBUIconSetType.iconBan.load()
        case .iconBroadcast: SBUIconSet.iconBroadcast = SBUIconSetType.iconBroadcast.load()
        case .iconCamera: SBUIconSet.iconCamera = SBUIconSetType.iconCamera.load()
        case .iconChat: SBUIconSet.iconChat = SBUIconSetType.iconChat.load()
        case .iconChannels: SBUIconSet.iconChannels = SBUIconSetType.iconChannels.load()
        case .iconCheckboxChecked: SBUIconSet.iconCheckboxChecked = SBUIconSetType.iconCheckboxChecked.load()
        case .iconCheckboxUnchecked: SBUIconSet.iconCheckboxUnchecked = SBUIconSetType.iconCheckboxUnchecked.load()
        case .iconChevronDown: SBUIconSet.iconChevronDown = SBUIconSetType.iconChevronDown.load()
        case .iconChevronRight: SBUIconSet.iconChevronRight = SBUIconSetType.iconChevronRight.load()
        case .iconClose: SBUIconSet.iconClose = SBUIconSetType.iconClose.load()
        case .iconCopy: SBUIconSet.iconCopy = SBUIconSetType.iconCopy.load()
        case .iconCreate: SBUIconSet.iconCreate = SBUIconSetType.iconCreate.load()
        case .iconDelete: SBUIconSet.iconDelete = SBUIconSetType.iconDelete.load()
        case .iconDocument: SBUIconSet.iconDocument = SBUIconSetType.iconDocument.load()
        case .iconDone: SBUIconSet.iconDone = SBUIconSetType.iconDone.load()
        case .iconDoneAll: SBUIconSet.iconDoneAll = SBUIconSetType.iconDoneAll.load()
        case .iconDownload: SBUIconSet.iconDownload = SBUIconSetType.iconDownload.load()
        case .iconEdit: SBUIconSet.iconEdit = SBUIconSetType.iconEdit.load()
        case .iconEmojiMore: SBUIconSet.iconEmojiMore = SBUIconSetType.iconEmojiMore.load()
        case .iconEmpty: SBUIconSet.iconEmpty = SBUIconSetType.iconEmpty.load()
        case .iconError: SBUIconSet.iconError = SBUIconSetType.iconError.load()
        case .iconFileAudio: SBUIconSet.iconFileAudio = SBUIconSetType.iconFileAudio.load()
        case .iconFileDocument: SBUIconSet.iconFileDocument = SBUIconSetType.iconFileDocument.load()
        case .iconFreeze: SBUIconSet.iconFreeze = SBUIconSetType.iconFreeze.load()
        case .iconGif: SBUIconSet.iconGif = SBUIconSetType.iconGif.load()
        case .iconInfo: SBUIconSet.iconInfo = SBUIconSetType.iconInfo.load()
        case .iconLeave: SBUIconSet.iconLeave = SBUIconSetType.iconLeave.load()
        case .iconMembers: SBUIconSet.iconMembers = SBUIconSetType.iconMembers.load()
        case .iconMessage: SBUIconSet.iconMessage = SBUIconSetType.iconMessage.load()
        case .iconModerations: SBUIconSet.iconModerations = SBUIconSetType.iconModerations.load()
        case .iconMore: SBUIconSet.iconMore = SBUIconSetType.iconMore.load()
        case .iconMute: SBUIconSet.iconMute = SBUIconSetType.iconMute.load()
        case .iconNotificationFilled: SBUIconSet.iconNotificationFilled = SBUIconSetType.iconNotificationFilled.load()
        case .iconNotificationOffFilled: SBUIconSet.iconNotificationOffFilled = SBUIconSetType.iconNotificationOffFilled.load()
        case .iconNotifications: SBUIconSet.iconNotifications = SBUIconSetType.iconNotifications.load()
        case .iconOperator: SBUIconSet.iconOperator = SBUIconSetType.iconOperator.load()
        case .iconPhoto: SBUIconSet.iconPhoto = SBUIconSetType.iconPhoto.load()
        case .iconPlay: SBUIconSet.iconPlay = SBUIconSetType.iconPlay.load()
        case .iconPlus: SBUIconSet.iconPlus = SBUIconSetType.iconPlus.load()
        case .iconQuestion: SBUIconSet.iconQuestion = SBUIconSetType.iconQuestion.load()
        case .iconRefresh: SBUIconSet.iconRefresh = SBUIconSetType.iconRefresh.load()
        case .iconRemove: SBUIconSet.iconRemove = SBUIconSetType.iconRemove.load()
        case .iconReply: SBUIconSet.iconReply = SBUIconSetType.iconReply.load()
        case .iconReplied: SBUIconSet.iconReplied = SBUIconSetType.iconReplied.load()
        case .iconSearch: SBUIconSet.iconSearch = SBUIconSetType.iconSearch.load()
        case .iconSend: SBUIconSet.iconSend = SBUIconSetType.iconSend.load()
        case .iconSpinner: SBUIconSet.iconSpinner = SBUIconSetType.iconSpinner.load()
        case .iconSupergroup: SBUIconSet.iconSupergroup = SBUIconSetType.iconSupergroup.load()
        case .iconThumbnailNone: SBUIconSet.iconThumbnailNone = SBUIconSetType.iconThumbnailNone.load()
        case .iconUser: SBUIconSet.iconUser = SBUIconSetType.iconUser.load()
        case .iconRadioButtonOn: SBUIconSet.iconRadioButtonOn = SBUIconSetType.iconRadioButtonOn.load()
        case .iconRadioButtonOff: SBUIconSet.iconRadioButtonOff = SBUIconSetType.iconRadioButtonOff.load()
        case .iconThread: SBUIconSet.iconThread = SBUIconSetType.iconThread.load()
        case .iconVoiceMessageOn: SBUIconSet.iconVoiceMessageOn = SBUIconSetType.iconVoiceMessageOn.load()
        case .iconPause: SBUIconSet.iconPause = SBUIconSetType.iconPause.load()
        case .iconRecording: SBUIconSet.iconRecording = SBUIconSetType.iconRecording.load()
        case .iconStop: SBUIconSet.iconStop = SBUIconSetType.iconStop.load()
        }
        
        SBUIconSetType.customizedIcons.remove(self)
    }
    
    // MARK: - Private Properties
    
    /// To keep track of which icons have been customized (set by users)
    private static var customizedIcons: Set<SBUIconSetType> = []
    
    private var image: UIImage {
        switch self {
        case .iconNotificationFilled: return SBUIconSet.iconNotificationFilled
        case .iconNotificationOffFilled: return SBUIconSet.iconNotificationOffFilled
        case .iconAdd: return SBUIconSet.iconAdd
        case .iconBack: return SBUIconSet.iconBack
        case .iconBan: return SBUIconSet.iconBan
        case .iconBroadcast: return SBUIconSet.iconBroadcast
        case .iconCamera: return SBUIconSet.iconCamera
        case .iconChat: return SBUIconSet.iconChat
        case .iconChannels: return SBUIconSet.iconChannels
        case .iconCheckboxUnchecked: return SBUIconSet.iconCheckboxUnchecked
        case .iconCheckboxChecked: return SBUIconSet.iconCheckboxChecked
        case .iconChevronDown: return SBUIconSet.iconChevronDown
        case .iconChevronRight: return SBUIconSet.iconChevronRight
        case .iconClose: return SBUIconSet.iconClose
        case .iconCopy: return SBUIconSet.iconCopy
        case .iconCreate: return SBUIconSet.iconCreate
        case .iconDelete: return SBUIconSet.iconDelete
        case .iconDocument: return SBUIconSet.iconDocument
        case .iconDone: return SBUIconSet.iconDone
        case .iconDoneAll: return SBUIconSet.iconDoneAll
        case .iconDownload: return SBUIconSet.iconDownload
        case .iconEdit: return SBUIconSet.iconEdit
        case .iconEmojiMore: return SBUIconSet.iconEmojiMore
        case .iconEmpty: return SBUIconSet.iconEmpty
        case .iconError: return SBUIconSet.iconError
        case .iconFileAudio: return SBUIconSet.iconFileAudio
        case .iconFileDocument: return SBUIconSet.iconFileDocument
        case .iconFreeze: return SBUIconSet.iconFreeze
        case .iconGif: return SBUIconSet.iconGif
        case .iconInfo: return SBUIconSet.iconInfo
        case .iconLeave: return SBUIconSet.iconLeave
        case .iconMembers: return SBUIconSet.iconMembers
        case .iconMessage: return SBUIconSet.iconMessage
        case .iconModerations: return SBUIconSet.iconModerations
        case .iconMore: return SBUIconSet.iconMore
        case .iconMute: return SBUIconSet.iconMute
        case .iconNotifications: return SBUIconSet.iconNotifications
        case .iconOperator: return SBUIconSet.iconOperator
        case .iconPhoto: return SBUIconSet.iconPhoto
        case .iconPlay: return SBUIconSet.iconPlay
        case .iconPlus: return SBUIconSet.iconPlus
        case .iconQuestion: return SBUIconSet.iconQuestion
        case .iconRefresh: return SBUIconSet.iconRefresh
        case .iconRemove: return SBUIconSet.iconRemove
        case .iconReply: return SBUIconSet.iconReply
        case .iconReplied: return SBUIconSet.iconReplied
        case .iconSearch: return SBUIconSet.iconSearch
        case .iconSend: return SBUIconSet.iconSend
        case .iconSpinner: return SBUIconSet.iconSpinner
        case .iconSupergroup: return SBUIconSet.iconSupergroup
        case .iconThumbnailNone: return SBUIconSet.iconThumbnailNone
        case .iconUser: return SBUIconSet.iconUser
        case .iconRadioButtonOn: return SBUIconSet.iconRadioButtonOn
        case .iconRadioButtonOff: return SBUIconSet.iconRadioButtonOff
        case .iconThread: return SBUIconSet.iconThread
        case .iconVoiceMessageOn: return SBUIconSet.iconVoiceMessageOn
        case .iconPause: return SBUIconSet.iconPause
        case .iconRecording: return SBUIconSet.iconRecording
        case .iconStop: return SBUIconSet.iconStop
        }
    }
}
