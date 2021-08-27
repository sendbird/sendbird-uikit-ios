//
//  CommonProtocols.swift
//  SendBirdUIKit
//
//  Created by Wooyoung Chung on 7/8/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

protocol Selectable {
    var isSelected: Bool { get set }
}

protocol LoadingIndicatorDelegate {
    func shouldShowLoadingIndicator() -> Bool
    func shouldDismissLoadingIndicator()
}
