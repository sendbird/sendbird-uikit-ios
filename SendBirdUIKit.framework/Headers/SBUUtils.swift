//
//  SBUUtils.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 26/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit 
import MobileCoreServices

private let kDefaultCoverUrl = "static.sendbird.com/sample/cover"

class SBUUtils: NSObject {
    
    static func getFileType(by fileMessage: SBDFileMessage) -> MessageFileType {
        return getFileType(by: fileMessage.type)
    }
    
    static func getFileType(by type: String) -> MessageFileType {
        let type = type.lowercased()
        
        if type.hasPrefix("image") { return .image }
        if type.hasPrefix("video") { return .video }
        if type.hasPrefix("audio") { return .audio }
        if type.hasPrefix("pdf")   { return .pdf }
        
        return .etc
    }
    
    static func generateChannelName(channel: SBDGroupChannel) -> String {
        guard !channel.name.contains(kDefaultCoverUrl) else { return channel.name }
        guard let members = channel.members as? [SBDUser] else { return channel.name }
        let users = members
            .sbu_convertUserList()
            .filter { $0.userId != SBUGlobals.CurrentUser?.userId }

        guard users.count != 0 else { return SBUStringSet.Channel_Name_No_Members}
        let userNicknames = users.sbu_getUserNicknames()
        let channelName = userNicknames.joined(separator: ", ")

        return channelName
    }
    
    static func getMimeType(url: URL) -> String? {
        let lastPathComponent = url.lastPathComponent
        let ext = (lastPathComponent as NSString).pathExtension
        guard let UTI = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension, ext as CFString, nil)?
            .takeRetainedValue() else { return nil }
        guard let retainedValueMimeType = UTTypeCopyPreferredTagWithClass(
            UTI, kUTTagClassMIMEType)?
            .takeRetainedValue() else { return nil }
        let mimeType = retainedValueMimeType as String
        
        return mimeType
    }
    
    static func getReceiptState(channel: SBDGroupChannel,
                                message: SBDBaseMessage) -> SBUMessageReceiptState {
        let didReadAll = channel.getUnreadMemberCount(message) == 0
        let didDeliverAll = channel.getUndeliveredMemberCount(message) == 0
        
        if didReadAll {
            return .readReceipt
        } else if didDeliverAll {
            return .deliveryReceipt
        } else {
            return .none
        }
    }
    
    static func emptyTitleForRowEditAction(for size: CGSize) -> String {
        let placeholderSymbol = "\u{200A}"
        let minimalActionWidth: CGFloat = 30
        let shiftFactor: CGFloat = 1.1

        let flt_max = CGFloat.greatestFiniteMagnitude
        let maxSize = CGSize(width: flt_max, height: flt_max)
        let attributes = [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: UIFont.systemFontSize)
        ]
        let boundingRect = placeholderSymbol.boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil
        )
        
        var usefulWidth = size.width - minimalActionWidth
        usefulWidth = usefulWidth < 0 ? 0 : usefulWidth
        let countOfSymbols = Int(floor(usefulWidth * shiftFactor / boundingRect.width))
        return String(repeating: placeholderSymbol, count: countOfSymbols)
    }
    
    static func isValid(coverUrl: String) -> Bool {
        guard coverUrl.hasPrefix(SBUConstant.coverImagePrefix) == false,
            coverUrl.count != 0  else {
                return false
        }
        
        return true
    }
    
    static func isValid(channelName: String) -> Bool {
        guard channelName.hasPrefix(SBUStringSet.Channel_Name_Default) == false,
            channelName.count != 0  else {
                return false
        }
        
        return true
    }
}
