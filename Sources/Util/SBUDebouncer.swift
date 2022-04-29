//
//  SBUDebouncer.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/04/17.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The class for debouncing.
public class SBUDebouncer: NSObject {
    /// The default value of debouncing time. The value is `0.3`.
    public static let defaultTime = 0.3
    
    private let debounceTime: TimeInterval
    private var timer: Timer?
    
    private var pendingHandler: (() -> Void)?
    
    /// Initializes with `debouceTime`.
    /// - Parameter debounceTime: A debouncing time. The default value is `0.3` which came from `SBUDebouncer.defaultTime`
    public init(debounceTime: TimeInterval = SBUDebouncer.defaultTime) {
        self.debounceTime = debounceTime
    }
    
    /// Resets a timer and adds `handler`
    /// - Parameter handler: A handler that will be executed if it's valid after the `debounceTime`.
    public func add(handler: @escaping (() -> Void)) {
        self.updateTimer()
        self.pendingHandler = handler
    }
    
    /// Updates timer.
    public func updateTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(
            withTimeInterval: self.debounceTime,
            repeats: false
        ) { [weak self] timer in
            self?.deboundTimeIntervalDidFinish(timer)
        }
    }
    
    /// Cancels `timer` and reset an added handler.
    public func cancel() {
        if self.timer?.isValid == true {
            self.timer?.invalidate()
            self.timer = nil
        }
        
        self.pendingHandler = nil
    }
    
    private func deboundTimeIntervalDidFinish(_ timer: Timer) {
        guard timer.isValid else { return }
        
        self.timer?.invalidate()
        self.timer = nil
        
        self.pendingHandler?()
        self.pendingHandler = nil
    }
}
