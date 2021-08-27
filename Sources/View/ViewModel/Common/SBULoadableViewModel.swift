//
//  SBULoadableViewModel.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/25.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

class SBULoadableViewModel: NSObject, SBUViewModelDelegate  {
    
    // MARK: - Properties
    
    let loadingObservable = SBUObservable<Bool>(debug: true, forcedDelay: 0)
    let errorObservable = SBUObservable<SBDError>()
    
    
    // MARK: - SBUViewModelDelegate
    
    func dispose() {
        self.loadingObservable.dispose()
        self.errorObservable.dispose()
    }
}
