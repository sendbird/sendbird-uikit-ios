//
//  BlockingOperation.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2023/08/03.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation

/**
 Operation object that is used to sequentialize asynchronous tasks in a blocking manner.
 No two tasks are run at the same time, and the order of tasks inserted to a `OperationQueue` is guaranteed.
 */
class BlockingOperation: Operation {
    let identifier: String
    
    enum State: String {
        case waiting = "Waiting"
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        
        fileprivate var keyPath: String { "is" + rawValue }
    }
    
    var state: State {
        get {
            stateQueue.sync {
                return internalState
            }
        }
        set {
            guard state != newValue else {
                return
            }

            let oldValue = state
            
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            
            stateQueue.sync(flags: .barrier) {
                internalState = newValue
            }
            
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    private let stateQueue = DispatchQueue(label: "com.sendbird.uikit.operation.state.\(UUID().uuidString)", attributes: .concurrent)
    private var internalState: State
    
    private var task: ((BlockingOperation) -> Void)?
    private var synchronous: Bool
    
    var userInfo: [String: Any]
    var didAttemptRun = false
    
    /**
     Initializes `BlockingOperation`.
     - Parameters:
        - taskBlock: closure to be run
        - synchronous: indicates whether the closure includes synchronous work or not. If synchronous is `false`, you must explicitly call `complete()` when finishing the task inside the taskBlock.
        - requireExplicity: indicates whether the closure should wait for explicit call of `markReady()`. If this flag is disabled, the taskBlock runs as soon as the queue is cleared, and the said taskBlock is ready to run. If the flag is enabled, the taskBlock does not run when the queue is cleared, but also waits for the explicit call of `markReady()`, in order to guarantee running certain tasks before running the said task.
     */
    init(taskBlock: @escaping ((BlockingOperation) -> Void), synchronous: Bool, requireExplicity: Bool) {
        self.task = taskBlock
        self.synchronous = synchronous
        self.identifier = UUID().uuidString
        self.userInfo = [:]
        self.internalState = requireExplicity ? .waiting : .ready
    }
    
    convenience init(
        syncTask: @escaping ((BlockingOperation) -> Void),
        requireExplicity: Bool = false
    ) {
        self.init(
            taskBlock: syncTask,
            synchronous: true,
            requireExplicity: requireExplicity
        )
    }
    
    convenience init(
        asyncTask: @escaping ((BlockingOperation) -> Void),
        requireExplicity: Bool = false
    ) {
        self.init(
            taskBlock: asyncTask,
            synchronous: false,
            requireExplicity: requireExplicity
        )
    }
    
    // MARK: Operation
    override var isAsynchronous: Bool { !synchronous }
    
    override var isExecuting: Bool { state == .executing }
    
    override var isFinished: Bool { state == .finished }
    
    /**
     Mark the task as ready when `requireExplicity` was set `true`.
     
     If this task was already ready to be run by the parent `OperationQueue` but did not run because it was not mark as ready, calling this method will run the task immediately.
     */
    func markReady() {
        state = .ready
        if didAttemptRun {
            execute()
        }
    }
    
    override func main() {
        if isCancelled {
            provisionalComplete()
            return
        }
        
        if state == .ready {
            execute()
        } else {
            didAttemptRun = true
        }
    }
    
    func execute() {
        state = .executing
        task?(self)
        if synchronous {
            complete()
        }
    }
    
    func provisionalComplete() {
        state = .finished
    }
    
    func complete() {
        if !isFinished {
            provisionalComplete()
        }
        
        task = nil
    }
}
