import Foundation

/// 蓝牙消息类型
enum BluetoothMessageType: String, Codable {
    case stateChanged = "STATE_CHANGED"
    case scanStarted = "SCAN_STARTED"
    case scanStopped = "SCAN_STOPPED"
    case scanResult = "SCAN_RESULT"
    case connecting = "CONNECTING"
    case connected = "CONNECTED"
    case disconnecting = "DISCONNECTING"
    case disconnected = "DISCONNECTED"
    case dataReceived = "DATA_RECEIVED"
    case dataSent = "DATA_SENT"
    case notification = "NOTIFICATION"
    case error = "ERROR"
    case devicesUpdated = "DEVICES_UPDATED"
}

/// 蓝牙消息实体，用于与Flutter交互
struct BluetoothMessage: Codable {
    let type: BluetoothMessageType
    let data: [String: Any]?
    let timestamp: Date

    init(type: BluetoothMessageType, data: [String: Any]?, timestamp: Date = Date()) {
        self.type = type
        self.data = data
        self.timestamp = timestamp
    }

    // 转换为JSON字符串
    func toJsonString() -> String? {
        var jsonObj: [String: Any] = [
            "type": type.rawValue,
            "timestamp": Int(timestamp.timeIntervalSince1970 * 1000),
        ]

        if let data = data {
            jsonObj["data"] = data
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonObj) else {
            return nil
        }

        return String(data: jsonData, encoding: .utf8)
    }
}
