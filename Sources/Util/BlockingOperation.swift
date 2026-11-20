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
@objc(SBUBlockingOperation)
class BlockingOperation: Operation, @unchecked Sendable {
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

    // main() 과 markReady() 가 누가 task 를 실행할지 정하는 값. 아래 세 값은 stateQueue 의 barrier 블록 안에서만 읽고 쓴다.
    // markReady() 가 이미 불렸는지. 두 번째 호출을 무시하는 데 쓴다.
    private var didRequestReady: Bool
    // ready 표시를 마쳤는지. main() 은 이 값으로 바로 실행할지 정한다.
    private var isMarkedReady: Bool
    // main() 이 실행을 미뤄 두었는지. markReady() 는 이 값으로 대신 실행할지 정한다.
    private var didAttemptRun = false
    /// 테스트 전용. `main()` 이 실행 여부를 확정하기 직전에 불린다. production 에서는 nil 이다.
    var willCommitRunDecision: (() -> Void)?
    
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
        self.didRequestReady = !requireExplicity
        self.isMarkedReady = !requireExplicity
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
        // 두 번째 호출은 무시한다. 실행 중이거나 끝난 상태를 ready 로 되돌리거나 task 를 다시 돌리지 않는다.
        let isFirstRequest = stateQueue.sync(flags: .barrier) { () -> Bool in
            defer { didRequestReady = true }
            return !didRequestReady
        }
        guard isFirstRequest else { return }

        // KVO 를 barrier 블록 밖에서 보내려고 상태는 먼저 바꾼다. isMarkedReady 가 아직 false 라 main() 은 이 사이에 실행하지 않는다.
        state = .ready

        // main() 과 같은 barrier 블록 안에서 ready 표시와 실행 여부를 함께 정한다. main() 이 먼저 실행을 미뤄 두었으면 여기서 실행한다.
        let shouldRun = stateQueue.sync(flags: .barrier) { () -> Bool in
            isMarkedReady = true
            return didAttemptRun
        }
        if shouldRun {
            execute()
        }
    }
    
    override func main() {
        if isCancelled {
            provisionalComplete()
            return
        }

        willCommitRunDecision?()
        // markReady() 와 같은 barrier 블록 안에서 정한다. ready 표시가 먼저 끝났으면 바로 실행하고, 아니면 markReady() 가 실행하게 남긴다.
        let shouldRun = stateQueue.sync(flags: .barrier) { () -> Bool in
            didAttemptRun = true
            return isMarkedReady
        }
        if shouldRun {
            execute()
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
