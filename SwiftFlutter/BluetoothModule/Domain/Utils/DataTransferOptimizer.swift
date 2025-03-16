import Combine
import Foundation
import zlib

class DataTransferOptimizer {
    // 单例模式，便于全局访问
    static let shared = DataTransferOptimizer()

    // 防抖动配置
    private var debounceTimers = [String: Timer]()
    private let debounceInterval: TimeInterval = 0.5  // 500ms

    // 队列系统
    private let messageQueue = DispatchQueue(label: "com.swiftflutter.bluetooth.messageQueue")
    private var pendingMessages = [String: [BluetoothMessage]]()
    private var isProcessingQueue = false

    private init() {
        // 私有初始化方法，防止外部直接实例化
    }

    // 使用批处理机制减少通信次数
    func batchDeviceUpdates(_ devices: [BluetoothDevice], forEngine engineId: String) {
        // 批量处理设备更新
        let deviceData: [()] = devices.map { $0.toCompactDictionary() }

        let message = BluetoothMessage(
            type: .devicesUpdated,
            data: ["devices": deviceData],
            timestamp: Date()
        )

        // 使用防抖动发送机制
        debouncedSend(message, to: engineId, identifier: "deviceUpdates")
    }

    // 根据消息优先级决定是否需要防抖
    func sendMessage(
        _ message: BluetoothMessage, to engineId: String, priority: MessagePriority = .normal
    ) {
        switch priority {
        case .high:
            // 高优先级消息，立即发送
            sendBatchUpdate(message, to: engineId)
        case .normal:
            // 普通优先级，加入队列批处理
            enqueueMessage(message, for: engineId)
        case .low:
            // 低优先级，使用防抖动
            debouncedSend(message, to: engineId, identifier: message.type.rawValue)
        }
    }

    // 立即将所有队列中的消息发送出去
    func flushMessages(for engineId: String) {
        messageQueue.async { [weak self] in
            guard let self = self,
                let messages = self.pendingMessages[engineId],
                !messages.isEmpty
            else {
                return
            }

            // 根据消息类型分组
            let groupedMessages = Dictionary(grouping: messages) { $0.type }

            // 处理每种类型的最新消息
            for (type, messagesOfType) in groupedMessages {
                if let latestMessage = messagesOfType.last {
                    self.sendBatchUpdate(latestMessage, to: engineId)
                }
            }

            // 清空该引擎的待处理消息
            self.pendingMessages[engineId] = []
        }
    }

    // 真正的数据压缩实现
    private func compressData(_ data: Data) -> Data {
        // 小数据不压缩
        if data.count < 1024 {
            return data
        }

        // 将数据复制到可变缓冲区
        var sourceBuffer = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &sourceBuffer, count: data.count)

        // 计算压缩缓冲区大小
        let destinationCapacity = sourceBuffer.count * 2  // 确保足够大
        var destinationBuffer = [UInt8](repeating: 0, count: destinationCapacity)

        // 压缩数据
        var compressionStream = z_stream()
        compressionStream.avail_in = uInt(sourceBuffer.count)
        compressionStream.next_in = UnsafeMutablePointer<Bytef>(mutating: sourceBuffer)
        compressionStream.avail_out = uInt(destinationCapacity)
        compressionStream.next_out = UnsafeMutablePointer<Bytef>(mutating: destinationBuffer)

        // 初始化压缩算法
        deflateInit2_(
            &compressionStream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 15, 8, Z_DEFAULT_STRATEGY,
            ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))

        // 执行压缩
        deflate(&compressionStream, Z_FINISH)

        // 完成压缩
        deflateEnd(&compressionStream)

        // 创建数据对象并返回
        let compressedSize = destinationCapacity - Int(compressionStream.avail_out)
        let compressedData = Data(bytes: destinationBuffer, count: compressedSize)

        // 记录压缩率
        let compressionRatio = Double(data.count) / Double(compressedSize)
        print("数据压缩率: \(compressionRatio)x (\(data.count) -> \(compressedSize) 字节)")

        return compressedData
    }

    // 添加消息到队列
    private func enqueueMessage(_ message: BluetoothMessage, for engineId: String) {
        messageQueue.async { [weak self] in
            guard let self = self else { return }

            // 初始化引擎消息数组（如果需要）
            if self.pendingMessages[engineId] == nil {
                self.pendingMessages[engineId] = []
            }

            // 添加消息到队列
            self.pendingMessages[engineId]?.append(message)

            // 如果队列处理未在进行中，则启动
            if !self.isProcessingQueue {
                self.processMessageQueue()
            }
        }
    }

    // 处理消息队列
    private func processMessageQueue() {
        messageQueue.async { [weak self] in
            guard let self = self else { return }

            // 标记正在处理
            self.isProcessingQueue = true

            // 遍历所有引擎的队列
            for (engineId, messages) in self.pendingMessages {
                guard !messages.isEmpty else { continue }

                // 根据消息类型分组
                let groupedMessages = Dictionary(grouping: messages) { $0.type }

                // 处理每种类型的最新消息
                for (type, messagesOfType) in groupedMessages {
                    if let latestMessage = messagesOfType.last {
                        self.sendBatchUpdate(latestMessage, to: engineId)
                    }
                }

                // 清空该引擎的待处理消息
                self.pendingMessages[engineId] = []
            }

            // 标记处理完成
            self.isProcessingQueue = false

            // 检查是否有新消息到达，需要继续处理
            if self.pendingMessages.values.contains(where: { !$0.isEmpty }) {
                DispatchQueue.main.async {
                    self.processMessageQueue()
                }
            }
        }
    }

    // 发送批量更新
    private func sendBatchUpdate(_ message: BluetoothMessage, to engineId: String) {
        guard let jsonData = try? JSONEncoder().encode(message) else {
            print("消息序列化失败")
            return
        }

        // 对大数据量进行压缩
        let compressedData = compressData(jsonData)

        guard let jsonString = String(data: compressedData, encoding: .utf8) else {
            print("压缩数据转换为字符串失败")
            return
        }

        // 发送压缩后的数据
        let sent = BluetoothMessageRouter.shared.sendMessage(
            to: engineId,
            method: "onBatchBluetoothUpdate",
            arguments: jsonString
        )

        if !sent {
            print("警告: 消息发送失败，引擎ID: \(engineId)")
        }
    }

    // 防抖动发送机制
    private func debouncedSend(_ message: BluetoothMessage, to engineId: String, identifier: String)
    {
        let debouncerId = "\(engineId)_\(identifier)"

        // 取消之前的定时器
        debounceTimers[debouncerId]?.invalidate()

        // 创建新的定时器
        let timer = Timer.scheduledTimer(withTimeInterval: debounceInterval, repeats: false) {
            [weak self] _ in
            self?.sendBatchUpdate(message, to: engineId)
            self?.debounceTimers.removeValue(forKey: debouncerId)
        }

        debounceTimers[debouncerId] = timer
    }
}

// 消息优先级枚举
enum MessagePriority {
    case high  // 立即发送，无防抖无队列
    case normal  // 通过队列批处理
    case low  // 使用防抖动机制
}
