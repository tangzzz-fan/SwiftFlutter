import Foundation

/// 蓝牙操作相关的错误类型
enum BluetoothError: Error {
    case notReady
    case scanningInProgress
    case scanningFailed
    case deviceNotFound
    case connectionFailed
    case serviceDiscoveryFailed
    case characteristicDiscoveryFailed
    case readFailed
    case writeFailed
    case notificationSetupFailed
    case timeout
    case cancelled
    case bluetoothUnavailable
    case bluetoothUnauthorized
    case unknown

    var localizedDescription: String {
        switch self {
        case .notReady:
            return "蓝牙管理器未准备就绪"
        case .scanningInProgress:
            return "蓝牙扫描已在进行中"
        case .scanningFailed:
            return "蓝牙扫描失败"
        case .deviceNotFound:
            return "未找到指定的蓝牙设备"
        case .connectionFailed:
            return "连接蓝牙设备失败"
        case .serviceDiscoveryFailed:
            return "服务发现失败"
        case .characteristicDiscoveryFailed:
            return "特征值发现失败"
        case .readFailed:
            return "读取特征值失败"
        case .writeFailed:
            return "写入特征值失败"
        case .notificationSetupFailed:
            return "设置通知失败"
        case .timeout:
            return "操作超时"
        case .cancelled:
            return "操作已取消"
        case .bluetoothUnavailable:
            return "蓝牙不可用"
        case .bluetoothUnauthorized:
            return "蓝牙未授权"
        case .unknown:
            return "未知错误"
        }
    }
}
