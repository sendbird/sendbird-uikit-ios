//
//  SBUDateFormatSet.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/06/08.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation

/// Default date formats.
public struct SBUDateFormatSet {
    /// Format: E, MMM yyyy
    public static var EMMMyyyy = "E, MMM yyyy"
    /// Format: MMM dd, yyyy
    public static var MMMddyyyy = "MMM dd, yyyy"
    /// Format: E, MMM dd
    public static var EMMMdd = "E, MMM dd"
    /// Format: MMM dd
    public static var MMMdd = "MMM dd"
    /// Format: hh:mm a
    public static var hhmma = "hh:mm a"
    /// Format: hh:mm
    public static var hhmm = "hh:mm"
    /// Format: yyyy/MM/dd
    public static var yyyyMMdd = "yyyy/MM/dd"
    /// Format: yyyyMMddhhmm
    public static var yyyyMMddhhmm = "yyyyMMddhhmm"
    /// Format: yyyyMMddhhmmss
    public static var yyyyMMddhhmmss = "yyyyMMddhhmmss"
    /// Format: MMM dd hh:mm a
    public static var MMMddhhmma = "MMM dd hh:mm a"
    /// Format: MMM dd, yyyy hh:mm a
    public static var MMMddyyyyhhmma = "MMM dd, yyyy hh:mm a"
    
    /// Data formats for Channel
    public class Channel {
        /// Used in `SBUChannelCell`
        public static var lastUpdatedDateFormat = SBUDateFormatSet.MMMdd
        /// Used in `SBUChannelCell`
        public static var lastUpdatedPastYearFormat = SBUDateFormatSet.yyyyMMdd
        /// Used in `SBUChannelCell`
        public static var lastUpdatedTimeFormat = SBUDateFormatSet.hhmma
        
        /// Not used now
        public static var lastSeenDateFormat = SBUDateFormatSet.MMMddyyyy
    }
    
    /// Data formats for Message
    public class Message {
        /// Used when sending file message from `SBUBaseViewController`
        public static var fileNameFormat = SBUDateFormatSet.yyyyMMddhhmmss

        /// Deprecated
        @available(*, deprecated, renamed: "fileViewControllerTimeFormat")
        public static var fileViewerTimeFormat = SBUDateFormatSet.hhmma
        
        /// Used in `dateTimeLabel` in ``SBUFileViewController/titleView``
        public static var fileViewControllerTimeFormat = SBUDateFormatSet.hhmma
        
        /// Used in `SBUMessageStateView timeLabel`
        public static var sentTimeFormat = SBUDateFormatSet.hhmm
        
        /// Used in `SBUOpenChannelContentBaseMessageCell`
        public static var sentTimeFormatInOpenChannel = SBUDateFormatSet.hhmm
        
        /// Used to show date separates in the message list.
        
        /// Used in `SBUMessageDateView`
        public static var dateSeparatorDateFormat = SBUDateFormatSet.EMMMdd
        /// Used in `SBUMessageDateView`
        public static var dateSeparatorPastYearFormat = SBUDateFormatSet.MMMddyyyy
        /// Used in `SBUMessageDateView`
        public static var dateSeparatorTimeFormat = SBUDateFormatSet.EMMMdd
        /// Used in `SBUMessageDateView`
        public static var dateSeparatorYesterdayFormat = SBUDateFormatSet.EMMMdd
        
        /// Used in `SBUMessageDateView`
        @available(*, deprecated, renamed: "dateSeparatorDateFormat") // 3.3.1
        public static var sentDateFormat: String {
            get { SBUDateFormatSet.Message.dateSeparatorDateFormat }
            set { SBUDateFormatSet.Message.dateSeparatorDateFormat = newValue }
        }
    }
    
    /// Data formats for MessageSearch
    public class MessageSearch {
        /// Used in `SBUMessageSearchResultCell`
        public static var lastUpdatedDateFormat = SBUDateFormatSet.MMMdd
        /// Used in `SBUMessageSearchResultCell`
        public static var lastUpdatedPastYearFormat = SBUDateFormatSet.yyyyMMdd
        /// Used in `SBUMessageSearchResultCell`
        public static var lastUpdatedTimeFormat = SBUDateFormatSet.hhmma

        /// Format for the sent time in messages
        @available(*, unavailable, message: "Use `Date.lastUpdatedTimeForMessageSearchResultCell(baseTimestamp:)` instead") // 3.3.1
        public static var sentTimeFormat = SBUDateFormatSet.hhmm
    }
    
    /// Data formats for MessageThread
    public class MessageThread {
        /// Used in `SBUParentMessageInfoView`
        public static var sentDateDateFormat = SBUDateFormatSet.MMMddhhmma
        /// Used in `SBUParentMessageInfoView`
        public static var sentDatePastYearFormat = SBUDateFormatSet.MMMddyyyyhhmma
        /// Used in `SBUParentMessageInfoView`
        public static var sentDateTimeFormat = SBUDateFormatSet.MMMddhhmma
        /// Used in `SBUParentMessageInfoView`
        public static var sentDateYesterdayFormat = SBUDateFormatSet.MMMddhhmma
    }
    
    /// Data formats for VoiceMessage
    public class VoiceMessage {
        /// Used in `SBUVoiceRecorder`
        /// - Since: 3.4.0
        public static var fileNameFormat = SBUDateFormatSet.yyyyMMddhhmmss
    }
}
