//
//  SBUIconSetType.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/01/22.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

enum SBUIconSetType: String, Hashable {
    case iconAdd
    case iconBack
    case iconBan
    case iconBroadcast
    case iconCamera
    case iconChat
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
    case iconSearch
    case iconSend
    case iconSpinner
    case iconSupergroup
    case iconThumbnailNone
    case iconUser
    
    // MARK: - Metric
    
    struct Metric {
        static let defaultIconSizeSmall = CGSize(value: 16)
        static let defaultIconSizeMedium = CGSize(value: 18)
        static let defaultIconSize = CGSize(value: 24)
        static let defaultIconSizeLarge = CGSize(value: 32)
        static let defaultIconSizeXLarge = CGSize(value: 48)
        static let iconActionSheetItem = defaultIconSize
        static let iconEmojiSmall = CGSize(value: 20)
        static let iconEmojiLarge = CGSize(value: 38)
        static let iconEmptyView = CGSize(value: 60)
        static let iconGifPlay = CGSize(value: 28)
        static let iconSpinnerLarge = CGSize(value: 40)
        static let iconUserProfile = CGSize(value: 40)
        static let iconUserProfileInChat = CGSize(value: 15)
        static let iconChevronDown = CGSize(value: 22)
    }
    
    // MARK: - Image handling
    
    private static let bundle = Bundle(identifier: "com.sendbird.uikit")
    
    func load(tintColor: UIColor? = nil) -> UIImage {
        let image = UIImage(named: self.rawValue, in: SBUIconSetType.bundle, compatibleWith: nil)!
        guard let tintColor = tintColor else { return image }
        
        return image.sbu_with(tintColor: tintColor)
    }
    
    /// Apply tint & resize to given values
    /// - Parameters:
    ///     - tintColor: Tint color to apply to the icon. Tint is applied to default icons according to `tintAndResize` flag.
    ///     - size: Size for the icon to be resized to. Resizing is applied to default icons according to `tintAndResize` flag.
    ///     - tintAndResize: Whether to apply tint & resized icons for customized icons as well.
    /// - Returns: `UIImage` with tint applied & resized if possible.
    func image(with tintColor: UIColor? = nil, to size: CGSize, tintAndResize: Bool = true) -> UIImage {
        // Prevents customized icons from being applied with tintColor.
        let isCustomized = SBUIconSetType.customizedIcons.contains(self)
        
        // return unmodified (no tint & resize) image if it's a customized icon and doesn't allow effects.
        guard !isCustomized || tintAndResize else { return self.image}
        
        // Apply tint.
        let resultImage = self.image.sbu_with(tintColor: tintColor)

        // Apply resize.
        return resultImage.resize(with: size)
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
        case .iconSearch: SBUIconSet.iconSearch = SBUIconSetType.iconSearch.load()
        case .iconSend: SBUIconSet.iconSend = SBUIconSetType.iconSend.load()
        case .iconSpinner: SBUIconSet.iconSpinner = SBUIconSetType.iconSpinner.load()
        case .iconSupergroup: SBUIconSet.iconSupergroup = SBUIconSetType.iconSupergroup.load()
        case .iconThumbnailNone: SBUIconSet.iconThumbnailNone = SBUIconSetType.iconThumbnailNone.load()
        case .iconUser: SBUIconSet.iconUser = SBUIconSetType.iconUser.load()
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
        case .iconSearch: return SBUIconSet.iconSearch
        case .iconSend: return SBUIconSet.iconSend
        case .iconSpinner: return SBUIconSet.iconSpinner
        case .iconSupergroup: return SBUIconSet.iconSupergroup
        case .iconThumbnailNone: return SBUIconSet.iconThumbnailNone
        case .iconUser: return SBUIconSet.iconUser
        }
    }
}
