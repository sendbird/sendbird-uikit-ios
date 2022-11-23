//
//  SBUDateFormatSet.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/06/08.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation

public struct SBUDateFormatSet {
    public static var EMMMyyyy = "E, MMM yyyy"
    public static var MMMddyyyy = "MMM dd, yyyy"
    public static var EMMMdd = "E, MMM dd"
    public static var MMMdd = "MMM dd"
    public static var hhmma = "hh:mm a"
    public static var hhmm = "hh:mm"
    public static var yyyyMMddhhmm = "yyyyMMddhhmm"
    public static var yyyyMMddhhmmss = "yyyyMMddhhmmss"
    public static var MMMddAthhmma = "MMM dd 'at' hh:mm a"
    
    public class Channel {
        /// Used in `SBUChannelCell`
        public static var lastUpdatedDateFormat = SBUDateFormatSet.MMMdd
        
        /// Used in `SBUChannelCell`
        public static var lastUpdatedTimeFormat = SBUDateFormatSet.hhmm
        
        public static var lastSeenDateFormat = SBUDateFormatSet.MMMddyyyy
    }
    
    public class Message {
        /// Used when sending file message from `SBUBaseViewController`
        public static var fileNameFormat = SBUDateFormatSet.yyyyMMddhhmmss
        
        /// Used `SBUFileViewer titleView.dateTimeLabel`
        public static var fileViewerTimeFormat = SBUDateFormatSet.hhmma
        
        /// Used in `SBUMessageDateView`
        public static var sentDateFormat = SBUDateFormatSet.EMMMdd
        
        /// Used in `SBUMessageStateView timeLabel`
        public static var sentTimeFormat = SBUDateFormatSet.hhmm
        
        /// Used in `SBUOpenChannelContentBaseMessageCell`
        public static var sentTimeFormatInOpenChannel = SBUDateFormatSet.hhmm
    }
    
    public class MessageSearch {
        /// Used in `SBUMessageSearchResultCell`
        public static var sentTimeFormat = SBUDateFormatSet.hhmm
    }
    
    public class MessageThread {
        public static var sentDateTimeFormat = SBUDateFormatSet.MMMddAthhmma
    }
}
