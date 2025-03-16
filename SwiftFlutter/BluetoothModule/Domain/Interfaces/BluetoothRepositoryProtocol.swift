import Combine
import CoreBluetooth
import Foundation

/// 蓝牙仓储接口协议
protocol BluetoothRepositoryProtocol {
    // 状态相关
    var statePublisher: AnyPublisher<CBManagerState, Never> { get }

    // 扫描相关
    var scanResultsPublisher: AnyPublisher<[BluetoothDevice], Never> { get }
    func startScan(withServices serviceUUIDs: [CBUUID]?)
    func stopScan()

    // 连接相关
    var connectedDevicePublisher: AnyPublisher<BluetoothDevice?, Error> { get }
    func connect(device: BluetoothDevice)
    func disconnect()

    // 服务和特征值
    var servicesPublisher: AnyPublisher<[CBService], Error> { get }
    var characteristicsPublisher: AnyPublisher<[BluetoothCharacteristic], Error> { get }
    func discoverServices(serviceUUIDs: [CBUUID]?)
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService)

    // 读写操作
    func readValue(for characteristic: BluetoothCharacteristic) -> AnyPublisher<Data, Error>
    func writeValue(
        _ data: Data, for characteristic: BluetoothCharacteristic, type: CBCharacteristicWriteType
    ) -> AnyPublisher<Void, Error>
    func setNotify(enabled: Bool, for characteristic: BluetoothCharacteristic) -> AnyPublisher<
        Data, Error
    >
}
