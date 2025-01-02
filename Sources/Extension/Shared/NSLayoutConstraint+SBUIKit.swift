//
//  NSLayoutConstraint+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/09/13.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    /// This function deactivates an existing constraint property, if any, and activates it with a new constraint property.
    /// - Parameters:
    ///   - baseView: The base view to which the constraint is applied
    ///   - constraints: Constraints to be applied (the constraint array can contain nil)
    ///
    ///   - Since: 3.10.0
    public static func sbu_activate(baseView: UIView, constraints: [NSLayoutConstraint?]) {
        let constraints = constraints.compactMap { $0 }
        var constraintMap: [String: NSLayoutConstraint] = [:]
        
        for baseConstraint in baseView.constraints {
            let identifier = baseConstraint.identifier ?? baseConstraint.generateId()
            constraintMap[identifier] = baseConstraint
        }
        
        var duplicatedConstraints: [NSLayoutConstraint] = []
        
        for constraint in constraints {
            let identifier = constraint.identifier ?? constraint.generateId()
            if constraint.identifier == nil {
                constraint.identifier = identifier
            }
            
            guard let existingConstraint = constraintMap[identifier],
                  isEqual(lhs: existingConstraint, rhs: constraint) else { continue }
            
            duplicatedConstraints.append(existingConstraint)
        }
        
        baseView.translatesAutoresizingMaskIntoConstraints = false
        
        Self.deactivate(duplicatedConstraints)
        baseView.removeConstraints(duplicatedConstraints)
        
        Self.activate(constraints)
    }
}

extension NSLayoutConstraint {
    func assignId(_ identifier: String? = nil) -> NSLayoutConstraint {
        self.identifier = identifier ?? self.generateId()
        return self
    }
    
    func generateId() -> String {
        let firstItemID = self.firstItem.map { ObjectIdentifier($0 as AnyObject).hashValue } ?? -1
        let secondItemID = self.secondItem.map { ObjectIdentifier($0 as AnyObject).hashValue } ?? -1
        let identifier = "\(firstItemID)_\(self.firstAttribute.rawValue)_\(secondItemID)_\(self.secondAttribute.rawValue)_\(self.relation.rawValue)_\(self.priority.rawValue)_\(self.multiplier)"
        return identifier
    }
    
    static internal func isEqual(lhs: NSLayoutConstraint, rhs: NSLayoutConstraint) -> Bool {
        guard lhs.firstAttribute == rhs.firstAttribute &&
              lhs.secondAttribute == rhs.secondAttribute &&
              lhs.relation == rhs.relation &&
              lhs.priority == rhs.priority &&
              lhs.multiplier == rhs.multiplier &&
              lhs.secondItem === rhs.secondItem &&
              lhs.firstItem === rhs.firstItem else {
            return false
        }
        return true
    }
}
