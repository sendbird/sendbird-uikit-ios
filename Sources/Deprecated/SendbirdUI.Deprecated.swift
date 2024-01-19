//
//  SendbirdUI.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2024/01/03.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@available(*, deprecated, renamed: "SendbirdUI") // 3.0.0
public typealias SBUMain = SendbirdUI

extension SendbirdUI {
    // MARK: - Initialize
    /// This function is used to initializes SDK with applicationId.
    /// - Parameter applicationId: Application ID
    @available(*, unavailable, message: "Using the `initialize(applicationId:startHandler:migrationStartHandler:completionHandler:)` function, and in the CompletionHandler, please proceed with the following procedure.", renamed: "initialize(applicationId:startHandler:migrationStartHandler:completionHandler:)") // 2.2.0
    public static func initialize(applicationId: String) {
        SendbirdUI.initialize(applicationId: applicationId, startHandler: nil, migrationHandler: nil) { _ in
            
        }
    }
    
    /// This function is used to initializes SDK with applicationId.
    ///
    /// When the completion handler is called, please proceed with the next operation.
    ///
    /// - Parameters:
    ///   - applicationId: Application ID
    ///   - migrationStartHandler: Do something to display the progress of the DB migration.
    ///   - completionHandler: Do something to display the completion of the DB migration.
    ///
    /// - Since: 2.2.0
    @available(*, deprecated, renamed: "initialize(applicationId:startHandler:migrationHandler:completionHandler:)") // 3.0.0
    public static func initialize(applicationId: String,
                                  migrationStartHandler: @escaping (() -> Void),
                                  completionHandler: @escaping ((_ error: SBError?) -> Void)) {
        self.initialize(
            applicationId: applicationId,
            startHandler: nil,
            migrationHandler: migrationStartHandler,
            completionHandler: completionHandler
        )
    }
    
    // MARK: - Common
    @available(*, deprecated, renamed: "moveToChannel(channelURL:basedOnChannelList:messageListParams:)") // 1.2.2
    public static func openChannel(channelUrl: String,
                                   basedOnChannelList: Bool = true,
                                   messageListParams: MessageListParams? = nil) {
        moveToChannel(
            channelURL: channelUrl,
            basedOnChannelList: basedOnChannelList,
            messageListParams: messageListParams
        )
    }
    
    // MARK: - Connection
    @available(*, deprecated, renamed: "connectIfNeeded(completionHandler:)") // 2.2.0
    public static func connectionCheck(
        completionHandler: @escaping (_ user: User?, _ error: SBError?) -> Void
    ) {
        self.connectIfNeeded(completionHandler: completionHandler)
    }
}
