//
//  NSObject+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/11.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation

public extension NSObject {
    /// This gets the class name of object.
    static var sbu_className: String {
        guard let className = String(describing: self).components(separatedBy: ".").last else {
            SBULog.error(String(describing: self))
            fatalError("Class name couldn't find.")
        }
        return className
    }
    
    /// This gets the class name of object.
    var sbu_className: String {
        guard let className = String(describing: self)
            .components(separatedBy: ":").first?
            .components(separatedBy: ".").last else {
                
            SBULog.error(String(describing: self))
            fatalError("Class name couldn't find.")
        }
        return className
    }
}
