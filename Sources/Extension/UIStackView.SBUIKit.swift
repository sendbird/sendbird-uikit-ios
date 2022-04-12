//
//  UIStackView.SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UIStackView {
    // MARK: - Public
    
    /// Sets axis to horizontal and adds arranged subviews to the horizontal stack view.
    /// - Parameter views: `UIView` objects that are added to the stack view.
    /// - Returns: Return `UIStackView` containing the arranged subviews.
    ///
    /// - Important: This function sets axis to `.horizontal`
    ///
    /// ```swift
    /// self.stackView.setHStack([
    ///    self.dateView,
    ///    self.messageContentView
    /// ])
    ///
    /// // same as
    /// self.stackView.axis = .horizontal
    /// self.stackView.addArrangedSubview(dateView)
    /// self.stackView.addArrangedSubview(messageContentView)
    /// ```
    @discardableResult
    public func setHStack(_ views: [UIView?]) -> Self {
        if self.axis != .horizontal {
            self.axis = .horizontal
        }
        self.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        views.forEach {
            if let view = $0 {
                self.addArrangedSubview(view)
            }
        }
        return self
    }
    
    /// Sets axis to vertical and adds arranged subviews to the vertical stack view.
    /// - Parameter views: `UIView` objects that are added to the stack view.
    /// - Returns: Return `UIStackView` containing the arranged subviews.
    ///
    /// - Important: This function sets axis to `.vertical`
    ///
    /// ```swift
    /// self.stackView.setVStack([
    ///    self.dateView,
    ///    self.messageContentView
    /// ])
    ///
    /// // same as
    /// self.stackView.axis = .vertical
    /// self.stackView.addArrangedSubview(dateView)
    /// self.stackView.addArrangedSubview(messageContentView)
    /// ```
    @discardableResult
    public func setVStack(_ views: [UIView?]) -> Self {
        if self.axis != .vertical {
            self.axis = .vertical
        }
        self.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        views.forEach {
            if let view = $0 {
                self.addArrangedSubview(view)
            }
        }
        return self
    }
}
