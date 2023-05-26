//
//  UIView+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Load Nib
public extension UIView {
    /// This loads the nib file from the Sendbird UIKit bundle.
    /// - Returns: nib object
    @objc static func sbu_loadNib() -> UINib {
        let nibName = String(NSStringFromClass(self).split(separator: ".").last ?? "")
        let nib = UINib(nibName: nibName, bundle: Bundle(identifier: SBUConstant.bundleIdentifier))
        return nib
    }
    
    /// This loads the view with the nib in the Sendbird UIKit bundle.
    /// - Returns: Loaded `UIView` object
    @objc static func sbu_loadViewFromNib() -> UIView {
        let nib = self.sbu_loadNib()
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
}

// MARK: - Constraint
extension UIView {
    // EqualTo
    @discardableResult
    public func sbu_constraint(equalTo view: UIView,
                        leading: CGFloat? = nil,
                        trailing: CGFloat? = nil,
                        left: CGFloat? = nil,
                        right: CGFloat? = nil,
                        top: CGFloat? = nil,
                        bottom: CGFloat? = nil,
                        centerX: CGFloat? = nil,
                        centerY: CGFloat? = nil,
                        priority: UILayoutPriority? = nil) -> UIView {
        
        return self.sbu_constraint_equalTo(
            leadingAnchor: view.leadingAnchor,
            leading: leading,
            trailingAnchor: view.trailingAnchor,
            trailing: trailing,
            leftAnchor: view.leftAnchor,
            left: left,
            rightAnchor: view.rightAnchor,
            right: right,
            topAnchor: view.topAnchor,
            top: top,
            bottomAnchor: view.bottomAnchor,
            bottom: bottom,
            centerXAnchor: view.centerXAnchor,
            centerX: centerX,
            centerYAnchor: view.centerYAnchor,
            centerY: centerY,
            priority: priority
        )
    }
    
    @discardableResult
    public func sbu_constraint_equalTo(
        leadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, leading: CGFloat? = nil,
        trailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, trailing: CGFloat? = nil,
        leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, left: CGFloat? = nil,
        rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, right: CGFloat? = nil,
        topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, top: CGFloat? = nil,
        bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, bottom: CGFloat? = nil,
        centerXAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, centerX: CGFloat? = nil,
        centerYAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, centerY: CGFloat? = nil,
        priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let leadingAnchor = leadingAnchor, let leading = leading {
            layoutConstraints.append(
                self.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading)
            )
        }
        
        if let trailingAnchor = trailingAnchor, let trailing = trailing {
            layoutConstraints.append(
                self.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing)
            )
        }
        
        if let leftAnchor = leftAnchor, let left = left {
            layoutConstraints.append(
                self.leftAnchor.constraint(equalTo: leftAnchor, constant: left)
            )
        }
        
        if let rightAnchor = rightAnchor, let right = right {
            layoutConstraints.append(
                self.rightAnchor.constraint(equalTo: rightAnchor, constant: -right)
            )
        }
        
        if let topAnchor = topAnchor, let top = top {
            layoutConstraints.append(
                self.topAnchor.constraint(equalTo: topAnchor, constant: top)
            )
        }
        
        if let bottomAnchor = bottomAnchor, let bottom = bottom {
            layoutConstraints.append(
                self.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottom)
            )
        }
        
        if let centerXAnchor = centerXAnchor, let centerX = centerX {
            layoutConstraints.append(
                self.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerX)
            )
        }
        
        if let centerYAnchor = centerYAnchor, let centerY = centerY {
            layoutConstraints.append(
                self.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerY)
            )
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
    
    // GreaterThanOrEqualTo
    @discardableResult
    public func sbu_constraint(greaterThanOrEqualTo view: UIView,
                        leading: CGFloat? = nil,
                        trailing: CGFloat? = nil,
                        left: CGFloat? = nil,
                        right: CGFloat? = nil,
                        top: CGFloat? = nil,
                        bottom: CGFloat? = nil,
                        centerX: CGFloat? = nil,
                        centerY: CGFloat? = nil,
                        priority: UILayoutPriority? = nil) -> UIView {
        
        return self.sbu_constraint_greater(
            leadingAnchor: view.leadingAnchor,
            leading: leading,
            trailingAnchor: view.trailingAnchor,
            trailing: trailing,
            leftAnchor: view.leftAnchor,
            left: left,
            rightAnchor: view.rightAnchor,
            right: right,
            topAnchor: view.topAnchor,
            top: top,
            bottomAnchor: view.bottomAnchor,
            bottom: bottom,
            centerXAnchor: view.centerXAnchor,
            centerX: centerX,
            centerYAnchor: view.centerYAnchor,
            centerY: centerY,
            priority: priority
        )
    }
    
    @discardableResult
    public func sbu_constraint_greater (
        leadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, leading: CGFloat? = nil,
        trailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, trailing: CGFloat? = nil,
        leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, left: CGFloat? = nil,
        rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, right: CGFloat? = nil,
        topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, top: CGFloat? = nil,
        bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, bottom: CGFloat? = nil,
        centerXAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, centerX: CGFloat? = nil,
        centerYAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, centerY: CGFloat? = nil,
        priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let leadingAnchor = leadingAnchor, let leading = leading {
            layoutConstraints.append(
                self.leadingAnchor.constraint(
                    greaterThanOrEqualTo: leadingAnchor,
                    constant: leading
                )
            )
        }
        
        if let trailingAnchor = trailingAnchor, let trailing = trailing {
            layoutConstraints.append(
                self.trailingAnchor.constraint(
                    greaterThanOrEqualTo: trailingAnchor,
                    constant: trailing
                )
            )
        }
        
        if let leftAnchor = leftAnchor, let left = left {
            layoutConstraints.append(
                self.leftAnchor.constraint(
                    greaterThanOrEqualTo: leftAnchor,
                    constant: left
                )
            )
        }
        
        if let rightAnchor = rightAnchor, let right = right {
            layoutConstraints.append(
                self.rightAnchor.constraint(
                    greaterThanOrEqualTo: rightAnchor,
                    constant: -right
                )
            )
        }
        
        if let topAnchor = topAnchor, let top = top {
            layoutConstraints.append(
                self.topAnchor.constraint(
                    greaterThanOrEqualTo: topAnchor,
                    constant: top
                )
            )
        }
        
        if let bottomAnchor = bottomAnchor, let bottom = bottom {
            layoutConstraints.append(
                self.bottomAnchor.constraint(
                    greaterThanOrEqualTo: bottomAnchor,
                    constant: -bottom
                )
            )
        }
        
        if let centerXAnchor = centerXAnchor, let centerX = centerX {
            layoutConstraints.append(
                self.centerXAnchor.constraint(
                    greaterThanOrEqualTo: centerXAnchor,
                    constant: centerX
                )
            )
        }
        
        if let centerYAnchor = centerYAnchor, let centerY = centerY {
            layoutConstraints.append(
                self.centerYAnchor.constraint(
                    greaterThanOrEqualTo: centerYAnchor,
                    constant: centerY
                )
            )
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
    
    // LessThanOrEqualTo
    @discardableResult
    public func sbu_constraint(lessThanOrEqualTo view: UIView,
                        leading: CGFloat? = nil,
                        trailing: CGFloat? = nil,
                        left: CGFloat? = nil,
                        right: CGFloat? = nil,
                        top: CGFloat? = nil,
                        bottom: CGFloat? = nil,
                        centerX: CGFloat? = nil,
                        centerY: CGFloat? = nil,
                        priority: UILayoutPriority? = nil) -> UIView {
        
        return self.sbu_constraint_less(
            leadingAnchor: view.leadingAnchor,
            leading: leading,
            trailingAnchor: view.trailingAnchor,
            trailing: trailing,
            leftAnchor: view.leftAnchor,
            left: left,
            rightAnchor: view.rightAnchor,
            right: right,
            topAnchor: view.topAnchor,
            top: top,
            bottomAnchor: view.bottomAnchor,
            bottom: bottom,
            centerXAnchor: view.centerXAnchor,
            centerX: centerX,
            centerYAnchor: view.centerYAnchor,
            centerY: centerY,
            priority: priority
        )
    }
    
    @discardableResult
    public func sbu_constraint_less (
        leadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, leading: CGFloat? = nil,
        trailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, trailing: CGFloat? = nil,
        leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, left: CGFloat? = nil,
        rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, right: CGFloat? = nil,
        topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, top: CGFloat? = nil,
        bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, bottom: CGFloat? = nil,
        centerXAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, centerX: CGFloat? = nil,
        centerYAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, centerY: CGFloat? = nil,
        priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let leadingAnchor = leadingAnchor, let leading = leading {
            layoutConstraints.append(
                self.leadingAnchor.constraint(
                    lessThanOrEqualTo: leadingAnchor,
                    constant: leading
                )
            )
        }
        
        if let trailingAnchor = trailingAnchor, let trailing = trailing {
            layoutConstraints.append(
                self.trailingAnchor.constraint(
                    lessThanOrEqualTo: trailingAnchor,
                    constant: trailing
                )
            )
        }
        
        if let leftAnchor = leftAnchor, let left = left {
            layoutConstraints.append(
                self.leftAnchor.constraint(
                    lessThanOrEqualTo: leftAnchor,
                    constant: left
                )
            )
        }
        
        if let rightAnchor = rightAnchor, let right = right {
            layoutConstraints.append(
                self.rightAnchor.constraint(
                    lessThanOrEqualTo: rightAnchor,
                    constant: -right
                )
            )
        }
        
        if let topAnchor = topAnchor, let top = top {
            layoutConstraints.append(
                self.topAnchor.constraint(
                    lessThanOrEqualTo: topAnchor,
                    constant: top
                )
            )
        }
        
        if let bottomAnchor = bottomAnchor, let bottom = bottom {
            layoutConstraints.append(
                self.bottomAnchor.constraint(
                    lessThanOrEqualTo: bottomAnchor,
                    constant: -bottom
                )
            )
        }
        
        if let centerXAnchor = centerXAnchor, let centerX = centerX {
            layoutConstraints.append(
                self.centerXAnchor.constraint(
                    lessThanOrEqualTo: centerXAnchor,
                    constant: centerX
                )
            )
        }
        
        if let centerYAnchor = centerYAnchor, let centerY = centerY {
            layoutConstraints.append(
                self.centerYAnchor.constraint(
                    lessThanOrEqualTo: centerYAnchor,
                    constant: centerY
                )
            )
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
    
    @discardableResult
    public func sbu_constraint(width: CGFloat? = nil,
                        height: CGFloat? = nil,
                        priority: UILayoutPriority? = nil) -> UIView {
        
        return self.sbu_constraint(
            widthAnchor: nil, width: width,
            heightAnchor: nil, height: height,
            priority: priority
        )
    }
    
    // Width, Height -> If Anchor set nil value, AnchorConstant set value work as equalToConstant.
    // example, (..leadingAnchor: nil, leadingAnchorConstant: 30,..) -> (..equalToConstant: 30..)
    @discardableResult
    public func sbu_constraint(
        widthAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, width: CGFloat? = nil,
        heightAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, height: CGFloat? = nil,
        priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let width = width {
            if let widthAnchor = widthAnchor {
                layoutConstraints.append(
                    self.widthAnchor.constraint(equalTo: widthAnchor, constant: width)
                )
            } else {
                layoutConstraints.append(
                    self.widthAnchor.constraint(equalToConstant: width))
            }
        }
        
        if let height = height {
            if let heightAnchor = heightAnchor {
                layoutConstraints.append(
                    self.heightAnchor.constraint(equalTo: heightAnchor, constant: height))
            } else {
                layoutConstraints.append(
                    self.heightAnchor.constraint(equalToConstant: height))
            }
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
    
    @discardableResult
    public func sbu_constraint_greaterThan(
        widthAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, width: CGFloat? = nil,
        heightAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, height: CGFloat? = nil,
        priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let width = width {
            if let widthAnchor = widthAnchor {
                layoutConstraints.append(
                    self.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, constant: width)
                )
            } else {
                layoutConstraints.append(
                    self.widthAnchor.constraint(greaterThanOrEqualToConstant: width)
                )
            }
        }
        
        if let height = height {
            if let heightAnchor = heightAnchor {
                layoutConstraints.append(
                    self.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor, constant: height))
            } else {
                layoutConstraints.append(
                    self.heightAnchor.constraint(greaterThanOrEqualToConstant: height))
            }
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
    
    @discardableResult
    public func sbu_constraint_lessThan(
        widthAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, width: CGFloat? = nil,
        heightAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, height: CGFloat? = nil,
        priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let width = width {
            if let widthAnchor = widthAnchor {
                layoutConstraints.append(
                    self.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: width)
                )
            } else {
                layoutConstraints.append(
                    self.widthAnchor.constraint(lessThanOrEqualToConstant: width)
                )
            }
        }
        
        if let height = height {
            if let heightAnchor = heightAnchor {
                layoutConstraints.append(
                    self.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: height))
            } else {
                layoutConstraints.append(
                    self.heightAnchor.constraint(lessThanOrEqualToConstant: height))
            }
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
    
    // MARK: - v2: [NSLayoutConstraint] chaining version
    // EqualTo
    @discardableResult
    public func sbu_constraint_v2(equalTo view: UIView,
                                  leading: CGFloat? = nil,
                                  trailing: CGFloat? = nil,
                                  left: CGFloat? = nil,
                                  right: CGFloat? = nil,
                                  top: CGFloat? = nil,
                                  bottom: CGFloat? = nil,
                                  centerX: CGFloat? = nil,
                                  centerY: CGFloat? = nil,
                                  priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {
        
        return self.sbu_constraint_equalTo_v2(
            leadingAnchor: view.leadingAnchor,
            leading: leading,
            trailingAnchor: view.trailingAnchor,
            trailing: trailing,
            leftAnchor: view.leftAnchor,
            left: left,
            rightAnchor: view.rightAnchor,
            right: right,
            topAnchor: view.topAnchor,
            top: top,
            bottomAnchor: view.bottomAnchor,
            bottom: bottom,
            centerXAnchor: view.centerXAnchor,
            centerX: centerX,
            centerYAnchor: view.centerYAnchor,
            centerY: centerY,
            priority: priority
        )
    }
    
    @discardableResult
    public func sbu_constraint_equalTo_v2(
        leadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, leading: CGFloat? = nil,
        trailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, trailing: CGFloat? = nil,
        leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, left: CGFloat? = nil,
        rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, right: CGFloat? = nil,
        topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, top: CGFloat? = nil,
        bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, bottom: CGFloat? = nil,
        centerXAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, centerX: CGFloat? = nil,
        centerYAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, centerY: CGFloat? = nil,
        priority: UILayoutPriority? = nil
    ) -> [NSLayoutConstraint] {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let leadingAnchor = leadingAnchor, let leading = leading {
            layoutConstraints.append(
                self.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading)
            )
        }
        
        if let trailingAnchor = trailingAnchor, let trailing = trailing {
            layoutConstraints.append(
                self.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing)
            )
        }
        
        if let leftAnchor = leftAnchor, let left = left {
            layoutConstraints.append(
                self.leftAnchor.constraint(equalTo: leftAnchor, constant: left)
            )
        }
        
        if let rightAnchor = rightAnchor, let right = right {
            layoutConstraints.append(
                self.rightAnchor.constraint(equalTo: rightAnchor, constant: -right)
            )
        }
        
        if let topAnchor = topAnchor, let top = top {
            layoutConstraints.append(
                self.topAnchor.constraint(equalTo: topAnchor, constant: top)
            )
        }
        
        if let bottomAnchor = bottomAnchor, let bottom = bottom {
            layoutConstraints.append(
                self.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottom)
            )
        }
        
        if let centerXAnchor = centerXAnchor, let centerX = centerX {
            layoutConstraints.append(
                self.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerX)
            )
        }
        
        if let centerYAnchor = centerYAnchor, let centerY = centerY {
            layoutConstraints.append(
                self.centerYAnchor.constraint(equalTo: centerYAnchor, constant: centerY)
            )
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        return layoutConstraints
    }
    
    // GreaterThanOrEqualTo
    @discardableResult
    public func sbu_constraint_v2(greaterThanOrEqualTo view: UIView,
                                  leading: CGFloat? = nil,
                                  trailing: CGFloat? = nil,
                                  left: CGFloat? = nil,
                                  right: CGFloat? = nil,
                                  top: CGFloat? = nil,
                                  bottom: CGFloat? = nil,
                                  centerX: CGFloat? = nil,
                                  centerY: CGFloat? = nil,
                                  priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {
        
        return self.sbu_constraint_greater_v2(
            leadingAnchor: view.leadingAnchor,
            leading: leading,
            trailingAnchor: view.trailingAnchor,
            trailing: trailing,
            leftAnchor: view.leftAnchor,
            left: left,
            rightAnchor: view.rightAnchor,
            right: right,
            topAnchor: view.topAnchor,
            top: top,
            bottomAnchor: view.bottomAnchor,
            bottom: bottom,
            centerXAnchor: view.centerXAnchor,
            centerX: centerX,
            centerYAnchor: view.centerYAnchor,
            centerY: centerY,
            priority: priority
        )
    }
    
    @discardableResult
    public func sbu_constraint_greater_v2(
        leadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, leading: CGFloat? = nil,
        trailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, trailing: CGFloat? = nil,
        leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, left: CGFloat? = nil,
        rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, right: CGFloat? = nil,
        topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, top: CGFloat? = nil,
        bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, bottom: CGFloat? = nil,
        centerXAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, centerX: CGFloat? = nil,
        centerYAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, centerY: CGFloat? = nil,
        priority: UILayoutPriority? = nil
    ) -> [NSLayoutConstraint] {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let leadingAnchor = leadingAnchor, let leading = leading {
            layoutConstraints.append(
                self.leadingAnchor.constraint(
                    greaterThanOrEqualTo: leadingAnchor,
                    constant: leading
                )
            )
        }
        
        if let trailingAnchor = trailingAnchor, let trailing = trailing {
            layoutConstraints.append(
                self.trailingAnchor.constraint(
                    greaterThanOrEqualTo: trailingAnchor,
                    constant: trailing
                )
            )
        }
        
        if let leftAnchor = leftAnchor, let left = left {
            layoutConstraints.append(
                self.leftAnchor.constraint(
                    greaterThanOrEqualTo: leftAnchor,
                    constant: left
                )
            )
        }
        
        if let rightAnchor = rightAnchor, let right = right {
            layoutConstraints.append(
                self.rightAnchor.constraint(
                    greaterThanOrEqualTo: rightAnchor,
                    constant: -right
                )
            )
        }
        
        if let topAnchor = topAnchor, let top = top {
            layoutConstraints.append(
                self.topAnchor.constraint(
                    greaterThanOrEqualTo: topAnchor,
                    constant: top
                )
            )
        }
        
        if let bottomAnchor = bottomAnchor, let bottom = bottom {
            layoutConstraints.append(
                self.bottomAnchor.constraint(
                    greaterThanOrEqualTo: bottomAnchor,
                    constant: -bottom
                )
            )
        }
        
        if let centerXAnchor = centerXAnchor, let centerX = centerX {
            layoutConstraints.append(
                self.centerXAnchor.constraint(
                    greaterThanOrEqualTo: centerXAnchor,
                    constant: centerX
                )
            )
        }
        
        if let centerYAnchor = centerYAnchor, let centerY = centerY {
            layoutConstraints.append(
                self.centerYAnchor.constraint(
                    greaterThanOrEqualTo: centerYAnchor,
                    constant: centerY
                )
            )
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        return layoutConstraints
    }
    
    // LessThanOrEqualTo
    @discardableResult
    public func sbu_constraint_v2(lessThanOrEqualTo view: UIView,
                                  leading: CGFloat? = nil,
                                  trailing: CGFloat? = nil,
                                  left: CGFloat? = nil,
                                  right: CGFloat? = nil,
                                  top: CGFloat? = nil,
                                  bottom: CGFloat? = nil,
                                  centerX: CGFloat? = nil,
                                  centerY: CGFloat? = nil,
                                  priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {
        
        return self.sbu_constraint_less_v2(
            leadingAnchor: view.leadingAnchor,
            leading: leading,
            trailingAnchor: view.trailingAnchor,
            trailing: trailing,
            leftAnchor: view.leftAnchor,
            left: left,
            rightAnchor: view.rightAnchor,
            right: right,
            topAnchor: view.topAnchor,
            top: top,
            bottomAnchor: view.bottomAnchor,
            bottom: bottom,
            centerXAnchor: view.centerXAnchor,
            centerX: centerX,
            centerYAnchor: view.centerYAnchor,
            centerY: centerY,
            priority: priority
        )
    }
    
    @discardableResult
    public func sbu_constraint_less_v2(
        leadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, leading: CGFloat? = nil,
        trailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, trailing: CGFloat? = nil,
        leftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, left: CGFloat? = nil,
        rightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, right: CGFloat? = nil,
        topAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, top: CGFloat? = nil,
        bottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, bottom: CGFloat? = nil,
        centerXAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>? = nil, centerX: CGFloat? = nil,
        centerYAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor>? = nil, centerY: CGFloat? = nil,
        priority: UILayoutPriority? = nil
    ) -> [NSLayoutConstraint] {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let leadingAnchor = leadingAnchor, let leading = leading {
            layoutConstraints.append(
                self.leadingAnchor.constraint(
                    lessThanOrEqualTo: leadingAnchor,
                    constant: leading
                )
            )
        }
        
        if let trailingAnchor = trailingAnchor, let trailing = trailing {
            layoutConstraints.append(
                self.trailingAnchor.constraint(
                    lessThanOrEqualTo: trailingAnchor,
                    constant: trailing
                )
            )
        }
        
        if let leftAnchor = leftAnchor, let left = left {
            layoutConstraints.append(
                self.leftAnchor.constraint(
                    lessThanOrEqualTo: leftAnchor,
                    constant: left
                )
            )
        }
        
        if let rightAnchor = rightAnchor, let right = right {
            layoutConstraints.append(
                self.rightAnchor.constraint(
                    lessThanOrEqualTo: rightAnchor,
                    constant: -right
                )
            )
        }
        
        if let topAnchor = topAnchor, let top = top {
            layoutConstraints.append(
                self.topAnchor.constraint(
                    lessThanOrEqualTo: topAnchor,
                    constant: top
                )
            )
        }
        
        if let bottomAnchor = bottomAnchor, let bottom = bottom {
            layoutConstraints.append(
                self.bottomAnchor.constraint(
                    lessThanOrEqualTo: bottomAnchor,
                    constant: -bottom
                )
            )
        }
        
        if let centerXAnchor = centerXAnchor, let centerX = centerX {
            layoutConstraints.append(
                self.centerXAnchor.constraint(
                    lessThanOrEqualTo: centerXAnchor,
                    constant: centerX
                )
            )
        }
        
        if let centerYAnchor = centerYAnchor, let centerY = centerY {
            layoutConstraints.append(
                self.centerYAnchor.constraint(
                    lessThanOrEqualTo: centerYAnchor,
                    constant: centerY
                )
            )
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        return layoutConstraints
    }
    
    @discardableResult
    public func sbu_constraint_v2(width: CGFloat? = nil,
                                  height: CGFloat? = nil,
                                  priority: UILayoutPriority? = nil) -> [NSLayoutConstraint] {
        return self.sbu_constraint_v2(
            widthAnchor: nil, width: width,
            heightAnchor: nil, height: height,
            priority: priority
        )
    }
    
    // Width, Height -> If Anchor set nil value, AnchorConstant set value work as equalToConstant.
    // example, (..leadingAnchor: nil, leadingAnchorConstant: 30,..) -> (..equalToConstant: 30..)
    @discardableResult
    public func sbu_constraint_v2(
        widthAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, width: CGFloat? = nil,
        heightAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, height: CGFloat? = nil,
        priority: UILayoutPriority? = nil
    ) -> [NSLayoutConstraint] {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let width = width {
            if let widthAnchor = widthAnchor {
                layoutConstraints.append(
                    self.widthAnchor.constraint(equalTo: widthAnchor, constant: width)
                )
            } else {
                layoutConstraints.append(
                    self.widthAnchor.constraint(equalToConstant: width))
            }
        }
        
        if let height = height {
            if let heightAnchor = heightAnchor {
                layoutConstraints.append(
                    self.heightAnchor.constraint(equalTo: heightAnchor, constant: height))
            } else {
                layoutConstraints.append(
                    self.heightAnchor.constraint(equalToConstant: height))
            }
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        return layoutConstraints
    }
    
    @discardableResult
    public func sbu_constraint_greaterThan_v2(
        widthAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, width: CGFloat? = nil,
        heightAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, height: CGFloat? = nil,
        priority: UILayoutPriority? = nil
    ) -> [NSLayoutConstraint] {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let width = width {
            if let widthAnchor = widthAnchor {
                layoutConstraints.append(
                    self.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, constant: width)
                )
            } else {
                layoutConstraints.append(
                    self.widthAnchor.constraint(greaterThanOrEqualToConstant: width)
                )
            }
        }
        
        if let height = height {
            if let heightAnchor = heightAnchor {
                layoutConstraints.append(
                    self.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor, constant: height))
            } else {
                layoutConstraints.append(
                    self.heightAnchor.constraint(greaterThanOrEqualToConstant: height))
            }
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        return layoutConstraints
    }
    
    @discardableResult
    public func sbu_constraint_lessThan_v2(
        widthAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, width: CGFloat? = nil,
        heightAnchor: NSLayoutAnchor<NSLayoutDimension>? = nil, height: CGFloat? = nil,
        priority: UILayoutPriority? = nil
    ) -> [NSLayoutConstraint] {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let width = width {
            if let widthAnchor = widthAnchor {
                layoutConstraints.append(
                    self.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: width)
                )
            } else {
                layoutConstraints.append(
                    self.widthAnchor.constraint(lessThanOrEqualToConstant: width)
                )
            }
        }
        
        if let height = height {
            if let heightAnchor = heightAnchor {
                layoutConstraints.append(
                    self.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: height))
            } else {
                layoutConstraints.append(
                    self.heightAnchor.constraint(lessThanOrEqualToConstant: height))
            }
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        return layoutConstraints
    }
    
    //////////////////////////////////////////////////////
    /// vv Will be removed. vv
    //////////////////////////////////////////////////////
    
    // Set left, right, top, bottom
    @discardableResult
    func setConstraint(from view: UIView,
                       leading: CGFloat? = nil,
                       trailing: CGFloat? = nil,
                       left: CGFloat? = nil,
                       right: CGFloat? = nil,
                       top: CGFloat? = nil,
                       bottom: CGFloat? = nil,
                       priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let leading = leading {
            layoutConstraints += [
                self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading)
            ]
        }
        
        if let trailing = trailing {
            layoutConstraints += [
                self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing)
            ]
        }
        
        if let left = left {
            layoutConstraints += [
                self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left)
            ]
        }
        if let right = right {
            layoutConstraints += [
                self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -right)
            ]
        }
        if let top = top {
            layoutConstraints += [
                self.topAnchor.constraint(equalTo: view.topAnchor, constant: top)
            ]
        }
        if let bottom = bottom {
            layoutConstraints += [
                self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottom)
            ]
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
    
    // Set width, height
    @discardableResult
    func setConstraint(width: CGFloat? = nil,
                       height: CGFloat? = nil,
                       priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if let width = width {
            layoutConstraints += [self.widthAnchor.constraint(equalToConstant: width)]
        }
        
        if let height = height {
            layoutConstraints += [self.heightAnchor.constraint(equalToConstant: height)]
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
    
    // Set CenterX, CenterY
    @discardableResult
    func setConstraint(from view: UIView,
                       centerX: Bool = false,
                       centerY: Bool = false,
                       priority: UILayoutPriority? = nil) -> UIView {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var layoutConstraints: [NSLayoutConstraint] = []
        
        if centerX {
            layoutConstraints += [self.centerXAnchor.constraint(equalTo: view.centerXAnchor)]
        }
        
        if centerY {
            layoutConstraints += [self.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
        }
        
        if let priority = priority {
            layoutConstraints.forEach { $0.priority = priority }
        }
        
        NSLayoutConstraint.activate(layoutConstraints)
        
        return self
    }
}

// Round Corners
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        
        var maskedCorners: CACornerMask = CACornerMask()
        if corners.contains(.topLeft) { maskedCorners.insert(.layerMinXMinYCorner) }
        if corners.contains(.topRight) { maskedCorners.insert(.layerMaxXMinYCorner) }
        if corners.contains(.bottomLeft) { maskedCorners.insert(.layerMinXMaxYCorner) }
        if corners.contains(.bottomRight) { maskedCorners.insert(.layerMaxXMaxYCorner) }
        
        self.layer.maskedCorners = maskedCorners
    }
}

// MARK: - Image

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
