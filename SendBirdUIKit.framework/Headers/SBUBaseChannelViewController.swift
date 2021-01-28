//
//  SBUBaseChannelViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/11/17.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objcMembers
open class SBUBaseChannelViewController: UIViewController {
    open func setupAutolayout() {}
    
    open func setupStyles() {}
    
    open func updateStyles() {}
}

extension SBUBaseChannelViewController: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
            -> Bool {
       return true
    }
}
