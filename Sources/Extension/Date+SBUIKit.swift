//
//  Date+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 25/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension Date {
    
    /// The `Date` value represents the time interval since 1970 with the time stamp
    /// - Parameter baseTimestamp: The `Int64` value representing the base timestamp.
    /// - Since: 2.2.0
    static public func sbu_from(_ baseTimestamp: Int64) -> Date {
        let timestampString = String(format: "%lld", baseTimestamp)
        let timeInterval = timestampString.count == 10
            ? TimeInterval(baseTimestamp)
            : TimeInterval(Double(baseTimestamp) / 1000.0)
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    /// Gets string value with own date format string. It recommends that use ``SBUDateFormatSet``
    /// - Parameters:
    ///   - dateFormat: The string value from representing the date format.
    ///   - localizedFormat: If `true`, it sets localized date format.
    /// - Note: If you want to use your own date format, please see ``SBUDateFormatSet``
    /// - Since: 3.0.0
    public func sbu_toString(dateFormat: String, localizedFormat: Bool = true) -> String {
        let formatter = DateFormatter()

        if localizedFormat {
            formatter.setLocalizedDateFormatFromTemplate(dateFormat)
        } else {
            formatter.dateFormat = dateFormat
        }
        return formatter.string(from: self)
    }
 
    static func elplasedTimeBetweenNow(baseTimestamp: Int64) -> String? {
        let baseDate = Date.sbu_from(baseTimestamp)
        let currDate = Date()
  
        let baseDateComponents = Calendar.current.dateComponents(
            [.minute, .hour, .day, .month, .year],
            from: baseDate
        )
        let currDateComponents = Calendar.current.dateComponents(
            [.minute, .hour, .day, .month, .year],
            from: currDate
        )

        if baseDateComponents.year != currDateComponents.year {
            let interval = (currDateComponents.year ?? 0) - (baseDateComponents.year ?? 0)
            return SBUStringSet.Date_Year(interval)
        } else if baseDateComponents.month != currDateComponents.month {
            let interval = (currDateComponents.month ?? 0) - (baseDateComponents.month ?? 0)
            return SBUStringSet.Date_Month(interval)
        } else if baseDateComponents.day != currDateComponents.day {
            let interval = (currDateComponents.day ?? 0) - (baseDateComponents.day ?? 0)
            return SBUStringSet.Date_Day(interval)
        } else if baseDateComponents.hour != currDateComponents.hour {
            let interval = (currDateComponents.hour ?? 0) - (baseDateComponents.hour ?? 0)
            return SBUStringSet.Date_Hour(interval)
        } else if baseDateComponents.minute != currDateComponents.minute {
            let interval = (currDateComponents.minute ?? 0) - (baseDateComponents.minute ?? 0)
            return SBUStringSet.Date_Min(interval)
        } else {
            return nil
        }
    }
    
    public static func lastUpdatedTimeForChannelCell(baseTimestamp: Int64) -> String? {
        self.lastUpdatedTime(
            baseTimestamp: baseTimestamp,
            dateFormat: SBUDateFormatSet.Channel.lastUpdatedDateFormat,
            pastYearFormat: SBUDateFormatSet.Channel.lastUpdatedPastYearFormat,
            timeFormat: SBUDateFormatSet.Channel.lastUpdatedTimeFormat
        )
    }
    
    public static func lastUpdatedTimeForMessageSearchResultCell(baseTimestamp: Int64) -> String? {
        self.lastUpdatedTime(
            baseTimestamp: baseTimestamp,
            dateFormat: SBUDateFormatSet.MessageSearch.lastUpdatedDateFormat,
            pastYearFormat: SBUDateFormatSet.MessageSearch.lastUpdatedPastYearFormat,
            timeFormat: SBUDateFormatSet.MessageSearch.lastUpdatedTimeFormat
        )
    }
    
    public static func messageCreatedTimeForParentInfo(baseTimestamp: Int64) -> String? {
        self.lastUpdatedTime(
            baseTimestamp: baseTimestamp,
            dateFormat: SBUDateFormatSet.MessageThread.sentDateDateFormat,
            pastYearFormat: SBUDateFormatSet.MessageThread.sentDatePastYearFormat,
            timeFormat: SBUDateFormatSet.MessageThread.sentDateTimeFormat,
            yesterdayFormat: SBUDateFormatSet.MessageThread.sentDateYesterdayFormat
        )
    }
    
    public static func dateSeparatedTime(baseTimestamp: Int64) -> String? {
        self.lastUpdatedTime(
            baseTimestamp: baseTimestamp,
            dateFormat: SBUDateFormatSet.Message.dateSeparatorDateFormat,
            pastYearFormat: SBUDateFormatSet.Message.dateSeparatorPastYearFormat,
            timeFormat: SBUDateFormatSet.Message.dateSeparatorTimeFormat,
            yesterdayFormat: SBUDateFormatSet.Message.dateSeparatorYesterdayFormat
        )
    }
    
    /// Create a string with a format based on the timestamp.
    /// - Parameters:
    ///   - baseTimestamp: Timestamp to apply formatting.
    ///   - dateFormat: Format used to display date.
    ///   - pastYearFormat: Format used to display date for past year.
    ///   - timeFormat: Format used to display today's time.
    ///   - yesterdayFormat: If this value is `nil`, return the `"Yesterday"` when updated time is yesterday.
    /// - Returns: Date formatted string
    public static func lastUpdatedTime(
        baseTimestamp: Int64,
        dateFormat: String = SBUDateFormatSet.MMMdd,
        pastYearFormat: String? = nil,
        timeFormat: String = SBUDateFormatSet.hhmm,
        yesterdayFormat: String? = nil
    ) -> String? {
        let baseDate = Date.sbu_from(baseTimestamp)
        let currDate = Date()
         
        let baseDateComponents = Calendar.current
            .dateComponents([.day, .month, .year], from: baseDate)
        let currDateComponents = Calendar.current
            .dateComponents([.day, .month, .year], from: currDate)
        
        if baseDateComponents.year != currDateComponents.year ||
            baseDateComponents.month != currDateComponents.month ||
            baseDateComponents.day != currDateComponents.day {

            if baseDateComponents.year == currDateComponents.year &&
                baseDateComponents.month == currDateComponents.month &&
                baseDateComponents.day != currDateComponents.day {
                
                if let yesterdayFormat = yesterdayFormat {
                    return baseDate.sbu_toString(dateFormat: yesterdayFormat, localizedFormat: false)
                }
                
                let interval = (currDateComponents.day ?? 0) - (baseDateComponents.day ?? 0)
                if interval == 1 {
                    return SBUStringSet.Date_Yesterday
                }
            }
            
            if (baseDateComponents.year != currDateComponents.year),
                let pastYearFormat = pastYearFormat {
                return baseDate.sbu_toString(dateFormat: pastYearFormat, localizedFormat: false)
            }
            
            return baseDate.sbu_toString(dateFormat: dateFormat, localizedFormat: false)
        } else {
            return baseDate.sbu_toString(dateFormat: timeFormat, localizedFormat: false)
        }
    }
    
    static func lastSeenTime(baseTimestamp: Int64) -> String? {
        let baseDate = Date.sbu_from(baseTimestamp)
        let currDate = Date()
        
        let baseDateComponents = Calendar.current
            .dateComponents([.minute, .hour, .day, .month, .year], from: baseDate)
        let currDateComponents = Calendar.current
            .dateComponents([.minute, .hour, .day, .month, .year], from: currDate)
        
        var lastSeenString = ""
        
        if baseDateComponents.year != currDateComponents.year ||
            baseDateComponents.month != currDateComponents.month {
            return SBUStringSet.Channel_Header_LastSeen
                + " " + SBUStringSet.Date_On
                + " " + baseDate.sbu_toString(
                    dateFormat: SBUDateFormatSet.Channel.lastSeenDateFormat
                )
        } else if baseDateComponents.day != currDateComponents.day {
            let interval = (currDateComponents.day ?? 0) - (baseDateComponents.day ?? 0)
            lastSeenString = SBUStringSet.Date_Day(interval)
        } else if baseDateComponents.hour != currDateComponents.hour {
            let interval = (currDateComponents.hour ?? 0) - (baseDateComponents.hour ?? 0)
            lastSeenString = SBUStringSet.Date_Hour(interval)
        } else if baseDateComponents.minute != currDateComponents.minute {
            let interval = (currDateComponents.minute ?? 0) - (baseDateComponents.minute ?? 0)
            lastSeenString = SBUStringSet.Date_Min(interval)
        } else {
            return nil
        }
        
        return SBUStringSet.Channel_Header_LastSeen
            + " " + lastSeenString
            + " " + SBUStringSet.Date_Ago
    }
    
    func isSameDay(as otherDate: Date) -> Bool {
        let baseDate = self
        let otherDate = otherDate
 
        let baseDateComponents = Calendar.current.dateComponents(
            [.day, .month, .year],
            from: baseDate
        )
        let otherDateComponents = Calendar.current.dateComponents(
            [.day, .month, .year],
            from: otherDate
        )

        if baseDateComponents.year == otherDateComponents.year,
            baseDateComponents.month == otherDateComponents.month,
            baseDateComponents.day == otherDateComponents.day {
            return true
        } else {
            return false
        }
    }
}

extension Date {
    /// Default date formats.
    /// - Since: 2.1.13
    @available(*, deprecated, renamed: "SBUDateFormatSet") // 3.0.0
    public enum SBUDateFormat {
        case EMMMyyyy
        case MMMddyyyy
        case EMMMdd
        case MMMdd
        case hhmma
        case hhmm
        case yyyyMMddhhmm
        case yyyyMMddhhmmss
        
        public var rawValue: String {
            switch self {
            case .EMMMyyyy:
                return SBUDateFormatSet.EMMMyyyy
            case .MMMddyyyy:
                return SBUDateFormatSet.MMMddyyyy
            case .EMMMdd:
                return SBUDateFormatSet.EMMMdd
            case .MMMdd:
                return SBUDateFormatSet.MMMdd
            case .hhmma:
                return SBUDateFormatSet.hhmma
            case .hhmm:
                return SBUDateFormatSet.hhmm
            case .yyyyMMddhhmm:
                return SBUDateFormatSet.yyyyMMddhhmm
            case .yyyyMMddhhmmss:
                return SBUDateFormatSet.yyyyMMddhhmmss
            }
        }
    }
    
    /// Gets string value with `SBUDateFormat`.
    /// - Parameters:
    ///    - format: The `SBUDateFormat` value.
    ///    - localizedFormat: If `true`, it sets localized date format.
    /// - Note: If you want to use your own date format, please see `sbu_toString(formatString:localizedFormat:)`.
    /// - Since: 2.1.13
    @available(*, deprecated, renamed: "sbu_toString(formatString:localizedFormat:)") // 3.0.0
    public func sbu_toString(format: SBUDateFormat, localizedFormat: Bool = true) -> String {
        self.sbu_toString(dateFormat: format.rawValue, localizedFormat: localizedFormat)
    }
    
    /// Gets string value with own date format string.
    /// - Parameters:
    ///   - formatString: The string value representing the date format.
    ///   - localizedFormat: If `true`, it sets localized date format.
    /// - Since: 2.1.13
    @available(*, deprecated, renamed: "sbu_toString(dateFormat:localizedFormat:)") // 3.0.0
    public func sbu_toString(formatString: String, localizedFormat: Bool = true) -> String {
        self.sbu_toString(dateFormat: formatString, localizedFormat: localizedFormat)
    }
}
