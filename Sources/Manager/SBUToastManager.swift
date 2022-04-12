//
//  SBUToastManager.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/06/16.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

enum ToastType {
    case fileDownloadSuccess
    case fileDownloadFailed
    case fileOpenFailed
}

class SBUToastManager {
    static func showToast(parentVC: UIViewController?, type: ToastType) {
        var title = ""
        switch type {
        case .fileDownloadFailed:
            title = SBUStringSet.Channel_Failure_Download_file
        case .fileDownloadSuccess:
            title = SBUStringSet.Channel_Success_Download_file
        case .fileOpenFailed:
            title = SBUStringSet.Channel_Failure_Open_file
        }
        
        self.showToast(baseViewController: parentVC, title: title)
    }
    
    private static func showToast(baseViewController: UIViewController?, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: nil,
                preferredStyle: .alert
            )
            
            baseViewController?.present(alert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    alert.dismiss(animated: true)
                }
            }
        }
    }
}
