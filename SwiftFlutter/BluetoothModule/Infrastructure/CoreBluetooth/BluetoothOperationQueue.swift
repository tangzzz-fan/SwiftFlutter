import Flutter
import Foundation

class BluetoothOperationQueue {
    private let operationQueue = OperationQueue()

    init() {
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInitiated
    }

    // 添加异步蓝牙操作
    func addOperation(_ operation: @escaping () -> Void) {
        operationQueue.addOperation(operation)
    }

    // 添加带超时的异步操作
    func addOperationWithTimeout(
        _ operation: @escaping (@escaping (Bool) -> Void) -> Void,
        timeout: TimeInterval,
        completion: @escaping (Bool) -> Void
    ) {
        // 创建操作
        let bluetoothOperation = BlockOperation()

        // 操作结果标识
        let resultRef = AtomicReference<Bool?>(nil)

        // 设置操作内容
        bluetoothOperation.addExecutionBlock {
            // 创建信号量
            let semaphore = DispatchSemaphore(value: 0)

            // 执行操作
            operation { success in
                resultRef.value = success
                semaphore.signal()
            }

            // 等待操作完成或超时
            let _ = semaphore.wait(timeout: .now() + timeout)

            // 如果超时，设置结果为失败
            if resultRef.value == nil {
                resultRef.value = false
            }
        }

        // 完成回调
        bluetoothOperation.completionBlock = {
            DispatchQueue.main.async {
                completion(resultRef.value ?? false)
            }
        }

        // 添加到队列
        operationQueue.addOperation(bluetoothOperation)
    }
}

// 辅助类：原子引用
class AtomicReference<T> {
    private let queue = DispatchQueue(label: "com.example.atomicReference")
    private var _value: T

    init(_ value: T) {
        self._value = value
    }

    var value: T {
        get {
            return queue.sync { _value }
        }
        set {
            queue.sync { _value = newValue }
        }
    }
}
