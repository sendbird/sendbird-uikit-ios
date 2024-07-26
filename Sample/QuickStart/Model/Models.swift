//
//  Models.swift
//  InspectionQuickStart
//
//  Created by Jed Gyeong on 6/19/24.
//

import Foundation

enum SampleAppType: Int {
    case none = 0
    case basicUsage
    case businessMessagingSample
    case chatBot
    case customSample
}

enum AuthType: Int {
    case authFeed = 0
    case websocket
}
