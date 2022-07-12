//
//  SBUUserMentionConfiguration.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/04/15.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation

/// The class for configuring user mention feature.
/// - Since: 3.0.0
public class SBUUserMentionConfiguration: SBUMentionConfiguration {
    /// The trigger keyword. The value is same as `SBUStringSet.Mention.Trigger_Key` that is `"@"`.
    public var trigger: String { SBUStringSet.Mention.Trigger_Key }
    
    /// The delay time for debouncing (sec)
    public let debounceTime: TimeInterval = SBUDebouncer.defaultTime
    
    /// The delimiter. The default value is a horizontal white space.
    public let delimiter = " "
    
    /// The limitation numbers of the mentioned users in one message.
    public var mentionLimit: Int = 10

    /// The limitation number of the users that displays on the suggested mention list view.
    public var suggestionLimit: Int = 15
    
    /// The flag whether to use a custom suggested mention list.
    /// - Note: If you want to use a custom list, set this flag to `true` and use your user list after override `mentionManager(_:suggestedMentionUsersWith:)` dataSource in `SBUGroupChannelViewController` class.
    public var isCustomUserListUsed: Bool = false
    
    public override init() {
        super.init()
    }
}
