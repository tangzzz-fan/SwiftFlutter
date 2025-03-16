import Foundation

/// 蓝牙状态枚举
enum BluetoothState: String {
    case unknown = "unknown"
    case resetting = "resetting"
    case unsupported = "unsupported"
    case unauthorized = "unauthorized"
    case disabled = "disabled"
    case ready = "ready"
}
