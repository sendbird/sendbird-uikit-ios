//
//  Date+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 25/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension Date {
    enum DateFormat: String {
        case EMMMyyyy = "E, MMM yyyy"
        case MMMddyyyy = "MMM dd, yyyy"
        case EMMMdd = "E, MMM dd"
        case MMMdd = "MMM dd"
        case hhmma = "hh:mm a"
        case yyyyMMddhhmm = "yyyyMMddhhmm"
        case yyyyMMddhhmmss = "yyyyMMddhhmmss"
    }
    
    static func from(_ baseTimestamp: Int64) -> Date {
        let timestampString = String(format: "%lld", baseTimestamp)
        let timeInterval = timestampString.count == 10
            ? TimeInterval(baseTimestamp)
            : TimeInterval(Double(baseTimestamp) / 1000.0)
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    func toString(format: DateFormat, localizedFormat: Bool = true) -> String {
        self.toString(formatString: format.rawValue, localizedFormat: localizedFormat)
    }
    
    func toString(formatString: String, localizedFormat: Bool = true) -> String {
        let formatter = DateFormatter()

        if localizedFormat {
            formatter.setLocalizedDateFormatFromTemplate(formatString)
        } else {
            formatter.dateFormat = formatString
        }
        return formatter.string(from: self)
    }
 
    static func elplasedTimeBetweenNow(baseTimestamp: Int64) -> String? {
        let baseDate = Date.from(baseTimestamp)
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
        let baseDate = Date.from(baseTimestamp)
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
            
            return baseDate.toString(format: .MMMdd)
        }
        else {
            return baseDate.toString(format: .hhmma)
        }
    }
    
    static func lastSeenTime(baseTimestamp: Int64) -> String? {
        let baseDate = Date.from(baseTimestamp)
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
                + " " + baseDate.toString(format: .MMMddyyyy)
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
