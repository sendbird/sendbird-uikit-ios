//
//  SBUObservable.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//
import Foundation

class SBUObservable<T> {
    
    @SBUAtomic
    private var observer = [((T) -> ())]()
    
    private let postLock = NSLock()
    private var workItem: DispatchWorkItem? {
        willSet {
            workItem?.cancel()
        }
    }
    
    private let debug: Bool!
    private let forcedDelay: Double?
    
    init(debug: Bool = false, forcedDelay: Double? = nil) {
        self.debug = debug
        self.forcedDelay = forcedDelay
    }
    
    func observe(_ observer: @escaping ((T) ->())) {
        self.observer.append(observer)
    }
    
    func post(value: T, delaySec: Double = 0.1) {
        postLock.lock()
        
        if self.forcedDelay == 0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.set(value: value)
            }
        } else {
            workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                
                self.set(value: value)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (forcedDelay ?? delaySec), execute: workItem!)
        }
        
        self.postLock.unlock()
    }
    
    func set(value: T) {
        if debug {
            SBULog.info("self : \(self), set value : \(value)")
        }
        observer.forEach({ $0(value) })
    }
    
    func dispose() {
        self.workItem = nil
        self.observer.removeAll()
        self.postLock.unlock()
    }
}
