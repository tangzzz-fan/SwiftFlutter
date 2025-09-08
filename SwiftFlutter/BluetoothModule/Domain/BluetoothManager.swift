import CoreBluetooth
import Foundation

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, MTUUpdateDelegate,
    BluetoothDataReceptionDelegate
{

    // 单例模式
    static let shared = BluetoothManager()

    // 核心蓝牙组件
    private var centralManager: CBCentralManager!
    private var connectedPeripherals: [String: CBPeripheral] = [:]

    // 通信组件
    private let logger: BluetoothLogger
    private let packetHandler: PacketHandler
    private let messageSender: BluetoothMessageSender

    // 蓝牙仓储
    private let repository: CoreBluetoothRepository

    // 初始化
    private override init() {
        // 初始化logger
        self.logger = ConsoleBluetoothLogger()

        // 初始化PacketHandler并设置logger
        let handler = DefaultPacketHandler(logger: self.logger)
        self.packetHandler = handler

        // 初始化消息发送器
        self.messageSender = FlutterBluetoothMessageSender(engineId: "main")

        // 初始化仓储
        self.repository = CoreBluetoothRepository()

        super.init()

        // 设置自己为各种delegate
        handler.delegate = self
        repository.delegate = self

        // 初始化中央管理器
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // MTUUpdateDelegate实现
    func didUpdateMTU(size: Int, for peripheral: CBPeripheral) {
        logger.log("MTU更新：设备 \(peripheral.identifier.uuidString) 的MTU大小为 \(size)")
        // 可以在这里处理MTU更新后的逻辑
    }

    // 实现BluetoothDataReceptionDelegate协议
    func didReceiveData(_ data: Data, from peripheral: CBPeripheral) {
        // 使用packetHandler处理接收到的数据
        packetHandler.handleReceivedData(data, from: peripheral.identifier.uuidString)

        // 如果需要，通知上层应用
        messageSender.sendDataReceived(data: data, characteristicId: "接收特征值ID")
    }

    // 请求MTU大小更新
    func requestMTUUpdate(for peripheralId: String, mtu: Int) {
        guard let peripheral = connectedPeripherals[peripheralId] else {
            logger.log("错误：尝试为未连接的设备请求MTU")
            return
        }

        packetHandler.requestMTU(for: peripheral, mtu: mtu)
    }

    // CBCentralManagerDelegate方法...
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state: BluetoothState

        switch central.state {
        case .poweredOn:
            state = .poweredOn
            logger.log("蓝牙已启用")
        case .poweredOff:
            state = .poweredOff
            logger.log("蓝牙已关闭")
        case .unauthorized:
            state = .unauthorized
            logger.log("蓝牙使用未授权")
        case .unsupported:
            state = .unsupported
            logger.log("设备不支持蓝牙")
        default:
            state = .unknown
            logger.log("蓝牙状态未知: \(central.state.rawValue)")
        }

        messageSender.sendStateUpdate(state)
    }
}
