//
//  SBUGlobalCustomParams.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/09/09.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This class is used to manage global custom parameters for Sendbird UIKit.
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
    public static var groupChannelParamsCreateBuilder: ((_ params: GroupChannelCreateParams?) -> Void)?
    
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
    public static var groupChannelParamsUpdateBuilder: ((_ params: GroupChannelUpdateParams?) -> Void)?
    
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
    public static var openChannelParamsCreateBuilder: ((_ params: OpenChannelCreateParams?) -> Void)?
    
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
    public static var openChannelParamsUpdateBuilder: ((_ params: OpenChannelUpdateParams?) -> Void)?
    
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
    public static var userMessageParamsSendBuilder: ((_ params: UserMessageCreateParams?) -> Void)?
    
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
    public static var userMessageParamsUpdateBuilder: ((_ params: UserMessageUpdateParams?) -> Void)?
    
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
    public static var fileMessageParamsSendBuilder: ((_ params: FileMessageCreateParams?) -> Void)?
    
    /// This is a builder that allows you to predefined the global `FileMessageCreateParams` processing to be used when sending a voice message.
    ///
    /// - Important:
    /// * This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    /// * If you change the `fileName`, `mimeType`, `fileSize` and `metaArrays` values, you cannot guarantee the processing of Voice Message.
    /// * If you want to set `metaArrays`, please add `metaArray` using the `append` method.
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.fileMessageParamsSendBuilder = { params in
    ///     params?.metaArrays?.append( <MetaArray> )
    ///     ...
    /// }
    /// ```
    /// - Since: 3.4.0
    public static var voiceFileMessageParamsSendBuilder: ((_ params: FileMessageCreateParams?) -> Void)?
    
    /// This is a builder that allows you to set a predefined the global `MultipleFilesMessageCreateParams` that is used when sending a multiple files message.
    ///
    /// - Important:
    /// This value is ignored if you set the parameter value directly through functions that receive the parameter inside the class.
    ///
    /// See the example below for builder setting.
    /// ```
    /// SBUGlobalCustomParams.multipleFilesMessageParamsSendBuilder = { params in
    ///     params?.data = "some data string"
    ///     ...
    /// ```
    /// - Since: 3.10.0
    public static var multipleFilesMessageParamsSendBuilder: ((_ params: MultipleFilesMessageCreateParams?) -> Void)?
    
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
    public static var messageListParamsBuilder: ((_ params: MessageListParams?) -> Void)?

}
