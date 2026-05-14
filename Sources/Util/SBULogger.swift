//
//  SBULogger.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 20/04/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//
//  swiftlint:disable identifier_name
import UIKit
@_spi(SendbirdInternal) import SendbirdAuthSDK

@objc
public enum LogType: UInt8 {
    case none    = 0b00000000
    case error   = 0b00000001
    case warning = 0b00000010
    case info    = 0b00000100
    case all     = 0b00000111
}

//  swiftlint:enable identifier_name
