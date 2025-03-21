import CoreBluetooth
import Flutter
import Foundation

// 定义PeripheralIdentifier类型，通常为CBPeripheral的标识符
typealias PeripheralIdentifier = String

// 定义Logger协议
protocol BluetoothLogger {
    func log(_ message: String)
}

// 定义MTU更新的委托协议
protocol MTUUpdateDelegate: AnyObject {
    func didUpdateMTU(size: Int, for peripheral: CBPeripheral)
}

protocol BluetoothMessageSender {
    func sendStateUpdate(_ state: BluetoothState)
    func sendDeviceDiscovered(_ device: BluetoothDevice)
    func sendConnectionResult(success: Bool, deviceId: String)
    func sendDataReceived(data: Data, characteristicId: String)
    func sendError(_ error: BluetoothError)
}

protocol PacketHandler {
    // 处理接收到的数据包
    func handleReceivedData(_ data: Data, from peripheral: PeripheralIdentifier)

    // 准备要发送的数据包
    func prepareDataForSending(_ data: Data) -> [Data]

    // 校验数据包完整性
    func validatePacket(_ data: Data) -> Bool

    // 请求MTU协商
    func requestMTU(for peripheral: CBPeripheral, mtu: Int)
}

// 具体实现类
class FlutterBluetoothMessageSender: BluetoothMessageSender {
    func sendDeviceDiscovered(_ device: BluetoothDevice) {

    }

    func sendConnectionResult(success: Bool, deviceId: String) {

    }

    func sendDataReceived(data: Data, characteristicId: String) {

    }

    func sendError(_ error: BluetoothError) {

    }

    private let engineId: String
    private let messageRouter: BluetoothMessageRouter

    init(engineId: String, messageRouter: BluetoothMessageRouter = .shared) {
        self.engineId = engineId
        self.messageRouter = messageRouter
    }

    func sendStateUpdate(_ state: BluetoothState) {
        let message = BluetoothMessage(
            type: .stateChanged,
            data: ["state": state.rawValue],
            timestamp: Date()
        )
        sendMessage(message)
    }

    // 其他方法实现...

    private func sendMessage(_ message: BluetoothMessage) {
        // 序列化消息
        guard let jsonData = try? JSONEncoder().encode(message),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return
        }

        // 发送到对应引擎
        messageRouter.sendMessage(to: engineId, method: "onBluetoothMessage", arguments: jsonString)
    }
}

// 实现一个默认的PacketHandler
class DefaultPacketHandler: PacketHandler {
    private let logger: BluetoothLogger
    weak var delegate: MTUUpdateDelegate?

    init(logger: BluetoothLogger) {
        self.logger = logger
    }

    func handleReceivedData(_ data: Data, from peripheral: PeripheralIdentifier) {
        logger.log("收到来自设备 \(peripheral) 的数据: \(data.count) 字节")
        // 实现数据处理逻辑
    }

    func prepareDataForSending(_ data: Data) -> [Data] {
        // 根据需要分割数据包
        return [data]
    }

    func validatePacket(_ data: Data) -> Bool {
        // 实现数据包验证逻辑
        return true
    }

    func requestMTU(for peripheral: CBPeripheral, mtu: Int) {
        // 在iOS中，无法直接请求MTU
        // 但可以通过maximumWriteValueLength获取支持的MTU大小
        let currentMTU = peripheral.maximumWriteValueLength(for: .withResponse)
        logger.log("当前MTU大小：\(currentMTU)")

        // 通知上层MTU大小
        delegate?.didUpdateMTU(size: currentMTU, for: peripheral)
    }
}

// 一个简单的Logger实现
class ConsoleBluetoothLogger: BluetoothLogger {
    func log(_ message: String) {
        print("[蓝牙模块] \(message)")
    }
}
