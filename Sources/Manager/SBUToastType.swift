//
//  SBUFileToast.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/06/16.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

enum SBUToastType {
    case file(SBUFileToastType)
    case feedback
    
    var item: SBUToastViewItem {
        switch self {
        case .file(let type):
            return type.item
            
        case .feedback:
            return SBUToastViewItem(
                position: .bottom(padding: 72),
                title: SBUStringSet.Feedback_Update_Done,
                image: SBUIconSet.iconDone.sbu_with(tintColor: SBUTheme.componentTheme.feedbackToastUpdateDoneColor)
            )
            
        }
    }
}

enum SBUFileToastType {
    case downloadSuccess
    case downloadFailed
    case openFailed
    
    var title: String {
        switch self {
        case .downloadFailed:
            return SBUStringSet.Channel_Failure_Download_file
        case .downloadSuccess:
            return SBUStringSet.Channel_Success_Download_file
        case .openFailed:
            return SBUStringSet.Channel_Failure_Open_file
        }
    }
    
    var item: SBUToastViewItem { .init(position: .center, title: self.title) }
}
