import Flutter
import Foundation

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
