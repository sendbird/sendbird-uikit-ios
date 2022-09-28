//
//  SBUGlobalCustomParams.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/09/09.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


public class SBUGlobalCustomParams {
    
    /// This is a builder that allows you to predefined the global `GroupChannelCreateParams` processing to be used when creating a channel.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.groupChannelParamsCreateBuilder = { params in
    ///     params?.isDistinct = true
    ///     ...
    /// }
    /// ```
    /// - Since: 1.2.2
    public static var groupChannelParamsCreateBuilder:((_ params: GroupChannelCreateParams?) -> Void)? = nil
    
    /// This is a builder that allows you to predefined the global `GroupChannelUpdateParams` processing to be used when updating a channel.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.groupChannelParamsUpdateBuilder = { params in
    ///     params?.coverURL = <URL_PATH>
    ///     ...
    /// }
    /// ```
    /// - Since: 1.2.2
    public static var groupChannelParamsUpdateBuilder:((_ params: GroupChannelUpdateParams?) -> Void)? = nil
    
    
    /// This is a builder that allows you to predefined the global `OpenChannelCreateParams` processing to be used when creating a channel.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.openChannelParamsCreateBuilder = { params in
    ///     params?.name = newValue
    ///     ...
    /// }
    /// ```
    /// - Since: 3.2.0
    public static var openChannelParamsCreateBuilder:((_ params: OpenChannelCreateParams?) -> Void)? = nil
    
    /// This is a builder that allows you to predefined the global `OpenChannelUpdateParams` processing to be used when updating a channel.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.openChannelParamsUpdateBuilder = { params in
    ///     params?.coverURL = <URL_PATH>
    ///     ...
    /// }
    /// ```
    /// - Since: 1.2.2
    public static var openChannelParamsUpdateBuilder:((_ params: OpenChannelUpdateParams?) -> Void)? = nil
    
    /// This is a builder that allows you to predefined the global `UserMessageCreateParams` processing to be used when sending a user message.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.userMessageParamsSendBuilder = { params in
    ///     params?.customType = <TYPE>
    ///     ...
    /// }
    /// ```
    /// - Since: 1.2.2
    public static var userMessageParamsSendBuilder:((_ params: UserMessageCreateParams?) -> Void)? = nil
    
    /// This is a builder that allows you to predefined the global `UserMessageUpdateParams` processing to be used when updating a user message.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.userMessageParamsUpdateBuilder = { params in
    ///     params?.message = <MESSAGE>
    ///     ...
    /// }
    /// ```
    /// - Since: 1.2.2
    public static var userMessageParamsUpdateBuilder:((_ params: UserMessageUpdateParams?) -> Void)? = nil
    
    /// This is a builder that allows you to predefined the global `FileMessageCreateParams` processing to be used when sending a file message.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.fileMessageParamsSendBuilder = { params in
    ///     params?.fileURL = <FILE_URL>
    ///     ...
    /// }
    /// ```
    /// - Since: 1.2.2
    public static var fileMessageParamsSendBuilder:((_ params: FileMessageCreateParams?) -> Void)? = nil

    
    /// This is a builder that allows you to predefined the global `MessageListParams` processing to be used when loading message list.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.messageListParamsBuilder = { params in
    ///     params?.includeReactions = true
    ///     params?.includeThreadInfo = true
    ///     ...
    /// }
    /// ```
    /// - Since: 1.2.2
    public static var messageListParamsBuilder:((_ params: MessageListParams?) -> Void)? = nil
}
