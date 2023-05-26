//
//  SBUIconSet.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/07.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUIconSet {
    
    // MARK: - Icons
    
    public static var iconAdd: UIImage = SBUIconSetType.iconAdd.load() {
        didSet { SBUIconSetType.iconAdd.markCustomized() }
    }
    public static var iconBack: UIImage = SBUIconSetType.iconBack.load() {
        didSet { SBUIconSetType.iconBack.markCustomized() }
    }
    public static var iconBan: UIImage = SBUIconSetType.iconBan.load() {
        didSet { SBUIconSetType.iconBan.markCustomized() }
    }
    public static var iconBroadcast: UIImage = SBUIconSetType.iconBroadcast.load() {
        didSet { SBUIconSetType.iconBroadcast.markCustomized() }
    }
    public static var iconCamera: UIImage = SBUIconSetType.iconCamera.load() {
        didSet { SBUIconSetType.iconCamera.markCustomized() }
    }
    public static var iconChat: UIImage = SBUIconSetType.iconChat.load() {
        didSet { SBUIconSetType.iconChat.markCustomized() }
    }
    public static var iconChannels: UIImage = SBUIconSetType.iconChannels.load() {
        didSet { SBUIconSetType.iconChannels.markCustomized() }
    }
    public static var iconCheckboxChecked: UIImage = SBUIconSetType.iconCheckboxChecked.load() {
        didSet { SBUIconSetType.iconCheckboxChecked.markCustomized() }
    }
    public static var iconCheckboxUnchecked: UIImage = SBUIconSetType.iconCheckboxUnchecked.load() {
        didSet { SBUIconSetType.iconCheckboxUnchecked.markCustomized() }
    }
    public static var iconChevronDown: UIImage = SBUIconSetType.iconChevronDown.load() {
        didSet { SBUIconSetType.iconChevronDown.markCustomized() }
    }
    public static var iconChevronRight: UIImage = SBUIconSetType.iconChevronRight.load() {
        didSet { SBUIconSetType.iconChevronRight.markCustomized() }
    }
    public static var iconClose: UIImage = SBUIconSetType.iconClose.load() {
        didSet { SBUIconSetType.iconClose.markCustomized() }
    }
    public static var iconCopy: UIImage = SBUIconSetType.iconCopy.load() {
        didSet { SBUIconSetType.iconCopy.markCustomized() }
    }
    public static var iconCreate: UIImage = SBUIconSetType.iconCreate.load() {
        didSet { SBUIconSetType.iconCreate.markCustomized() }
    }
    public static var iconDelete: UIImage = SBUIconSetType.iconDelete.load() {
        didSet { SBUIconSetType.iconDelete.markCustomized() }
    }
    public static var iconDocument: UIImage = SBUIconSetType.iconDocument.load() {
        didSet { SBUIconSetType.iconDocument.markCustomized() }
    }
    public static var iconDone: UIImage = SBUIconSetType.iconDone.load() {
        didSet { SBUIconSetType.iconDone.markCustomized() }
    }
    public static var iconDoneAll: UIImage = SBUIconSetType.iconDoneAll.load() {
        didSet { SBUIconSetType.iconDoneAll.markCustomized() }
    }
    public static var iconDownload: UIImage = SBUIconSetType.iconDownload.load() {
        didSet { SBUIconSetType.iconDownload.markCustomized() }
    }
    public static var iconEdit: UIImage = SBUIconSetType.iconEdit.load() {
        didSet { SBUIconSetType.iconEdit.markCustomized() }
    }
    public static var iconEmojiMore: UIImage = SBUIconSetType.iconEmojiMore.load() {
        didSet { SBUIconSetType.iconEmojiMore.markCustomized() }
    }
    public static var iconEmpty: UIImage = SBUIconSetType.iconEmpty.load() {
        didSet { SBUIconSetType.iconEmpty.markCustomized() }
    }
    public static var iconError: UIImage = SBUIconSetType.iconError.load() {
        didSet { SBUIconSetType.iconError.markCustomized() }
    }
    public static var iconFileAudio: UIImage = SBUIconSetType.iconFileAudio.load() {
        didSet { SBUIconSetType.iconFileAudio.markCustomized() }
    }
    public static var iconFileDocument: UIImage = SBUIconSetType.iconFileDocument.load() {
        didSet { SBUIconSetType.iconFileDocument.markCustomized() }
    }
    public static var iconFreeze: UIImage = SBUIconSetType.iconFreeze.load() {
        didSet { SBUIconSetType.iconFreeze.markCustomized() }
    }
    public static var iconGif: UIImage = SBUIconSetType.iconGif.load() {
        didSet { SBUIconSetType.iconGif.markCustomized() }
    }
    public static var iconInfo: UIImage = SBUIconSetType.iconInfo.load() {
        didSet { SBUIconSetType.iconInfo.markCustomized() }
    }
    public static var iconLeave: UIImage = SBUIconSetType.iconLeave.load() {
        didSet { SBUIconSetType.iconLeave.markCustomized() }
    }
    public static var iconMembers: UIImage = SBUIconSetType.iconMembers.load() {
        didSet { SBUIconSetType.iconMembers.markCustomized() }
    }
    public static var iconMessage: UIImage = SBUIconSetType.iconMessage.load() {
        didSet { SBUIconSetType.iconMessage.markCustomized() }
    }
    public static var iconModerations: UIImage = SBUIconSetType.iconModerations.load() {
        didSet { SBUIconSetType.iconModerations.markCustomized() }
    }
    public static var iconMore: UIImage = SBUIconSetType.iconMore.load() {
        didSet { SBUIconSetType.iconMore.markCustomized() }
    }
    public static var iconMute: UIImage = SBUIconSetType.iconMute.load() {
        didSet { SBUIconSetType.iconMute.markCustomized() }
    }
    public static var iconNotificationFilled: UIImage = SBUIconSetType.iconNotificationFilled.load() {
        didSet { SBUIconSetType.iconNotificationFilled.markCustomized() }
    }
    public static var iconNotificationOffFilled: UIImage = SBUIconSetType.iconNotificationOffFilled.load() {
        didSet { SBUIconSetType.iconNotificationOffFilled.markCustomized() }
    }
    public static var iconNotifications: UIImage = SBUIconSetType.iconNotifications.load() {
        didSet { SBUIconSetType.iconNotifications.markCustomized() }
    }
    public static var iconOperator: UIImage = SBUIconSetType.iconOperator.load() {
        didSet { SBUIconSetType.iconOperator.markCustomized() }
    }
    public static var iconPhoto: UIImage = SBUIconSetType.iconPhoto.load() {
        didSet { SBUIconSetType.iconPhoto.markCustomized() }
    }
    
    public static var iconPlay: UIImage = SBUIconSetType.iconPlay.load() {
        didSet { SBUIconSetType.iconPlay.markCustomized() }
    }
    public static var iconPlus: UIImage = SBUIconSetType.iconPlus.load() {
        didSet { SBUIconSetType.iconPlus.markCustomized() }
    }
    public static var iconQuestion: UIImage = SBUIconSetType.iconQuestion.load() {
        didSet { SBUIconSetType.iconQuestion.markCustomized() }
    }
    public static var iconRefresh: UIImage = SBUIconSetType.iconRefresh.load() {
        didSet { SBUIconSetType.iconRefresh.markCustomized() }
    }
    public static var iconRemove: UIImage = SBUIconSetType.iconRemove.load() {
        didSet { SBUIconSetType.iconRemove.markCustomized() }
    }
    public static var iconSearch: UIImage = SBUIconSetType.iconSearch.load() {
        didSet { SBUIconSetType.iconSearch.markCustomized() }
    }
    public static var iconSend: UIImage = SBUIconSetType.iconSend.load() {
        didSet { SBUIconSetType.iconSend.markCustomized() }
    }
    public static var iconSpinner: UIImage = SBUIconSetType.iconSpinner.load() {
        didSet { SBUIconSetType.iconSpinner.markCustomized() }
    }
    public static var iconSupergroup: UIImage = SBUIconSetType.iconSupergroup.load() {
        didSet { SBUIconSetType.iconSupergroup.markCustomized() }
    }
    public static var iconThumbnailNone: UIImage = SBUIconSetType.iconThumbnailNone.load() {
        didSet { SBUIconSetType.iconThumbnailNone.markCustomized() }
    }
    public static var iconUser: UIImage = SBUIconSetType.iconUser.load() {
        didSet { SBUIconSetType.iconUser.markCustomized() }
    }
    
    public static var iconReply: UIImage = SBUIconSetType.iconReply.load() {
        didSet { SBUIconSetType.iconReply.markCustomized() }
    }
    
    public static var iconReplied: UIImage = SBUIconSetType.iconReplied.load() {
        didSet { SBUIconSetType.iconReplied.markCustomized() }
    }
    
    public static var iconThread: UIImage = SBUIconSetType.iconThread.load() {
        didSet { SBUIconSetType.iconThread.markCustomized() }
    }
    
    public static var iconRadioButtonOn = SBUIconSetType.iconRadioButtonOn.load() {
        didSet { SBUIconSetType.iconRadioButtonOn.markCustomized() }
    }
    
    public static var iconRadioButtonOff = SBUIconSetType.iconRadioButtonOff.load() {
        didSet { SBUIconSetType.iconRadioButtonOff.markCustomized() }
    }
    
    /// An icon used as a button to show the voice message recording view in the input component.
    public static var iconVoiceMessageOn = SBUIconSetType.iconVoiceMessageOn.load() {
        didSet { SBUIconSetType.iconVoiceMessageOn.markCustomized() }
    }

    /// An icon used as a pause button to pause a voice message recording from playing in the input component.
    public static var iconPause = SBUIconSetType.iconPause.load() {
        didSet { SBUIconSetType.iconPause.markCustomized() }
    }

    /// An icon used as a record button start recording a voice message in the input component.
    public static var iconRecording = SBUIconSetType.iconRecording.load() {
        didSet { SBUIconSetType.iconRecording.markCustomized() }
    }

    /// An icon used as a stop button to stop recording a voice message in the input component.
    public static var iconStop = SBUIconSetType.iconStop.load() {
        didSet { SBUIconSetType.iconStop.markCustomized() }
    }
    
    /// Restore all customized icons to SDK's default icons.
    ///
    /// - Since: 2.1.0
    public static func restoreDefaultIcons() {
        SBUIconSetType.resetCustomized()
    }
}
