import Flutter
import Foundation

class BluetoothMessageRouter {
    // 单例模式确保全局唯一的消息路由中心
    static let shared = BluetoothMessageRouter()

    // 存储引擎ID和对应的通信通道
    private var channelRegistry = [String: FlutterMethodChannel]()

    // 性能监控数据
    private var messageStats = [String: Int]()
    private var lastMessageTime = [String: Date]()

    private init() {}

    // 注册引擎及其通信通道
    func registerEngine(id: String, methodChannel: FlutterMethodChannel) {
        channelRegistry[id] = methodChannel
        messageStats[id] = 0
        print("已注册引擎通信通道: \(id)")
    }

    // 注销引擎及其通信通道
    func unregisterEngine(id: String) {
        channelRegistry.removeValue(forKey: id)
        messageStats.removeValue(forKey: id)
        lastMessageTime.removeValue(forKey: id)
        print("已注销引擎通信通道: \(id)")
    }

    // 发送消息到特定引擎
    @discardableResult
    func sendMessage(to engineId: String, method: String, arguments: Any?) -> Bool {
        guard let channel = channelRegistry[engineId] else {
            print("错误: 尝试发送消息到未注册的引擎 \(engineId)")
            return false
        }

        // 更新统计数据
        messageStats[engineId] = (messageStats[engineId] ?? 0) + 1
        lastMessageTime[engineId] = Date()

        // 发送消息
        channel.invokeMethod(method, arguments: arguments)
        return true
    }

    // 广播消息到所有引擎
    func broadcastMessage(method: String, arguments: Any?) {
        if channelRegistry.isEmpty {
            print("警告: 没有已注册的引擎，广播消息将不会发送")
            return
        }

        channelRegistry.forEach { (engineId, channel) in
            // 更新统计数据
            messageStats[engineId] = (messageStats[engineId] ?? 0) + 1
            lastMessageTime[engineId] = Date()

            // 发送消息
            channel.invokeMethod(method, arguments: arguments)
        }
    }

    // 发送消息到特定引擎组
    func sendMessageToGroup(engineIds: [String], method: String, arguments: Any?) {
        for engineId in engineIds {
            sendMessage(to: engineId, method: method, arguments: arguments)
        }
    }

    // 根据消息类型路由到适当的引擎
    func routeMessageByType(_ message: BluetoothMessage) {
        switch message.type {
        case .scanResult, .scanStarted, .scanStopped:
            // 扫描相关消息路由到扫描引擎
            sendMessage(
                to: "bluetooth_scanner", method: "onBluetoothMessage",
                arguments: message.toJsonString())

        case .connecting, .connected, .disconnecting, .disconnected:
            // 连接相关消息路由到连接引擎
            sendMessage(
                to: "bluetooth_connection", method: "onBluetoothMessage",
                arguments: message.toJsonString())

        case .dataReceived, .dataSent, .notification:
            // 数据交换相关消息路由到数据交换引擎
            sendMessage(
                to: "bluetooth_data_exchange", method: "onBluetoothMessage",
                arguments: message.toJsonString())

        case .stateChanged, .error:
            // 状态和错误广播到所有引擎
            broadcastMessage(method: "onBluetoothMessage", arguments: message.toJsonString())

        case .devicesUpdated:
            // 设备更新可能需要发送到多个引擎
            sendMessageToGroup(
                engineIds: ["bluetooth_scanner", "bluetooth_connection"],
                method: "onBluetoothMessage",
                arguments: message.toJsonString()
            )
        }
    }

    // 获取性能统计数据
    func getMessageStats() -> [String: Any] {
        var stats: [String: Any] = [:]

        for (engineId, count) in messageStats {
            var engineStats: [String: Any] = ["messageCount": count]

            if let lastTime = lastMessageTime[engineId] {
                engineStats["lastMessageTime"] = Int(lastTime.timeIntervalSince1970)
                engineStats["secondsSinceLastMessage"] = Int(Date().timeIntervalSince(lastTime))
            }

            stats[engineId] = engineStats
        }

        return stats
    }
}
