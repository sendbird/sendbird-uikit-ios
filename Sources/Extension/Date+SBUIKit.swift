//
//  Date+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 25/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension Date {
    /// Default date formats.
    /// - Since: 2.1.13
    public enum SBUDateFormat: String {
        case EMMMyyyy = "E, MMM yyyy"
        case MMMddyyyy = "MMM dd, yyyy"
        case EMMMdd = "E, MMM dd"
        case MMMdd = "MMM dd"
        case hhmma = "hh:mm a"
        case hhmm = "hh:mm"
        case yyyyMMddhhmm = "yyyyMMddhhmm"
        case yyyyMMddhhmmss = "yyyyMMddhhmmss"
    }
    
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
    
    /// Gets string value with `SBUDateFormat`.
    /// - Parameters:
    ///    - format: The `SBUDateFormat` value.
    ///    - localizedFormat: If `true`, it sets localized date format.
    /// - Note: If you want to use your own date format, please see `sbu_toString(formatString:localizedFormat:)`.
    /// - Since: 2.1.13
    public func sbu_toString(format: SBUDateFormat, localizedFormat: Bool = true) -> String {
        self.sbu_toString(formatString: format.rawValue, localizedFormat: localizedFormat)
    }
    
    /// Gets string value with own date format string.
    /// - Parameters:
    ///   - formatString: The string value representing the date format.
    ///   - localizedFormat: If `true`, it sets localized date format.
    /// - Since: 2.1.13
    public func sbu_toString(formatString: String, localizedFormat: Bool = true) -> String {
        let formatter = DateFormatter()

        if localizedFormat {
            formatter.setLocalizedDateFormatFromTemplate(formatString)
        } else {
            formatter.dateFormat = formatString
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
    
    static func lastUpdatedTime(baseTimestamp: Int64) -> String? {
        let baseDate = Date.sbu_from(baseTimestamp)
        let currDate = Date()
         
        let baseDateComponents = Calendar.current
            .dateComponents([.day, .month, .year], from: baseDate)
        let currDateComponents = Calendar.current
            .dateComponents([.day, .month, .year], from: currDate)
        
        if baseDateComponents.year != currDateComponents.year ||
            baseDateComponents.month != currDateComponents.month ||
            baseDateComponents.day != currDateComponents.day {

            if baseDateComponents.day != currDateComponents.day {
                let interval = (currDateComponents.day ?? 0) - (baseDateComponents.day ?? 0)
                if interval == 1 {
                    return SBUStringSet.Date_Yesterday
                }
            }
            
            return baseDate.sbu_toString(format: .MMMdd)
        }
        else {
            return baseDate.sbu_toString(format: .hhmma)
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
                + " " + baseDate.sbu_toString(format: .MMMddyyyy)
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
        }
        else {
            return false
        }
    }
}
