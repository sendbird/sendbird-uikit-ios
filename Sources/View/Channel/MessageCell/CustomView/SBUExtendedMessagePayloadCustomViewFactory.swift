//
//  SBUCustomViewFactory.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK
import UIKit

// swiftlint:disable type_name
/// **DO NOT** use this protocol. Use `SBUExtendedMessagePayloadCustomViewFactory` instead of this.
/// Protocol for calling ``SBUCustomViewFactory`` internally like a template pattern.
/// Additionally, it serves as an interface to be mapped for swift backwards compatibility where the `some` and `any` keyword is not available.
/// - Since: 3.11.0
public protocol SBUExtendedMessagePayloadCustomViewFactoryInternal: AnyObject {
    
    /// **DO NOT** implement this methods.
    /// Methods to call internally in a `SBUserMessageCell`
    static func makeCustomView(message: SendbirdChatSDK.BaseMessage?) -> UIView?
    
    /// Methods for determining where to attach factory-generated views.
    /// This is an optional method, and the default configuration is to replace the entire cell area.
    /// - Parameters:
    ///   - customView: A custom view that you returned directly from the ``SBUExtendedMessagePayloadCustomViewFactory``.
    ///   - cell: The cell instance to be targeted. It is recommended to attach a custom view after understanding the internal structure of the ``SBUUserMessageCell``.
    static func configure(with customView: UIView, cell: SBUUserMessageCell)
}

extension SBUExtendedMessagePayloadCustomViewFactoryInternal {
    /// Default configuration.
    public static func configure(with customView: UIView, cell: SBUUserMessageCell) {
        cell.messageContentView.subviews.forEach({ $0.removeFromSuperview() })
        cell.messageContentView.addSubview(customView)
        customView
            .sbu_constraint(equalTo: cell.messageContentView, left: 12, right: 12, bottom: 0)
            .sbu_constraint(equalTo: cell.messageContentView, top: 0, priority: .defaultLow)
    }
}

/// Factory protocol for creating and configuring CustomViews.
/// By default, you only need to implement the makeCustomView function.
///
/// Additionally, if you want to change the location of the `custom view` in the `SBUserMessageCell`,
/// you also need to implement  ``SBUExtendedMessagePayloadCustomViewFactory/configure(with:cell:)`` as well.
///
/// - NOTE: `Custom view` is called if the `custom_view` field of `mesage.extendedMessagePayload` exists
///    and is successfully parsed by the set decodable `view data`.
///    If it is not called as intended, check the `console log message` first.
public protocol SBUExtendedMessagePayloadCustomViewFactory: SBUExtendedMessagePayloadCustomViewFactoryInternal {
    associatedtype ViewData: Decodable
    
    /// Methods to create and return a view. Must be implemented.
    /// NOTE: The internal structure of data can be organized differently for each app service. 
    /// - Parameters:
    ///   - data: A `decodable` model object to parse the `custom_view` field of `message.extendedMessagePayload` to use.
    ///   - message: A `message` data for additional custom UI configuration.
    /// - Returns: The `custom view` that will be created and attached.
    /// ```
    /// class CustomViewFactory: SBUExtendedMessagePayloadCustomViewFactory {
    ///    public static func makeCustomView(
    ///        _ data: CustomViewData, // Returns data with type inference internally.
    ///        message: SendbirdChatSDK.BaseMessage?
    ///    ) -> UIView? {
    ///        switch data.type { // `data.type` is an example for explanation purposes
    ///        case .type1:
    ///            let view = CustomView1()
    ///            // bind data
    ///            return view
    ///        case .type2:
    ///            let view = CustomView2()
    ///            // bind data
    ///            return view
    ///        }
    ///    }
    /// }
    ///
    /// struct CustomData: Decodable {
    ///     let customDataField: String // your own field.
    ///     ...
    ///
    ///     enum CodingKey: String, CodingKey {
    ///         case customDataField = "custom_data_field" // Required if snake case.
    ///         ...
    ///     }
    /// }
    /// ```
    static func makeCustomView(_ data: ViewData, message: SendbirdChatSDK.BaseMessage?) -> UIView?
    
    /// Method called when an error occurs.
    /// This is an optional method, it will only print the error log, then return `nil` by default.
    /// - Parameters:
    ///   - error: A specific error instance.
    ///   - message: A `message` data for resolving error.
    /// - Returns: The `custom view` that will be created and attached. If an error occurs, you should implement it to return nil in general.
    static func errorHandler(_ error: Error, message: SendbirdChatSDK.BaseMessage?) -> UIView?
}
// swiftlint:enable type_name

public extension SBUExtendedMessagePayloadCustomViewFactory {
    /// Internal methods for ``SBUUserMessageCell``.
    static func makeCustomView(message: SendbirdChatSDK.BaseMessage?) -> UIView? {
        do {
            guard let data: ViewData = try message?.decodeCustomViewData() else { return nil }
            return makeCustomView(data, message: message)
        } catch {
            return errorHandler(error, message: message)
        }
    }
    
    /// Handles errors that occur during the process.
    /// This function takes an error and a message as parameters and returns a UIView.
    /// If an error occurs, it generally returns nil.
    /// - Parameters:
    ///   - error: The error that occurred.
    ///   - message: The message data for resolving the error.
    /// - Returns: The custom view that will be created and attached. If an error occurs, it generally returns nil.
    static func errorHandler(_ error: Error, message: SendbirdChatSDK.BaseMessage?) -> UIView? {
        SBULog.error("[Failed] decode CustomViewData : \(String(describing: error))")
        return nil
    }
}
