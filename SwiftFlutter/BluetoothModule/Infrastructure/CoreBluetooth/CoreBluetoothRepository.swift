import Combine
import CoreBluetooth
import Foundation

/// 蓝牙仓储的具体实现
class CoreBluetoothRepository: BluetoothRepositoryProtocol {
    // MARK: - Properties
    private let manager: CoreBluetoothManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Publishers
    var statePublisher: AnyPublisher<CBManagerState, Never> {
        return manager.statePublisher
    }

    var scanResultsPublisher: AnyPublisher<[BluetoothDevice], Never> {
        return manager.scanResultsPublisher
    }

    var connectedDevicePublisher: AnyPublisher<BluetoothDevice?, Error> {
        return manager.connectedDevicePublisher
    }

    var servicesPublisher: AnyPublisher<[CBService], Error> {
        return manager.servicesPublisher
    }

    var characteristicsPublisher: AnyPublisher<[BluetoothCharacteristic], Error> {
        return manager.characteristicsPublisher
    }

    // MARK: - Initialization
    init(manager: CoreBluetoothManager = CoreBluetoothManager()) {
        self.manager = manager
    }

    // MARK: - BluetoothRepositoryProtocol Methods
    func startScan(withServices serviceUUIDs: [CBUUID]?) {
        manager.startScan(withServices: serviceUUIDs)
    }

    func stopScan() {
        manager.stopScan()
    }

    func connect(device: BluetoothDevice) {
        manager.connect(device: device)
    }

    func disconnect() {
        manager.disconnect()
    }

    func discoverServices(serviceUUIDs: [CBUUID]?) {
        manager.discoverServices(serviceUUIDs: serviceUUIDs)
    }

    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        manager.discoverCharacteristics(characteristicUUIDs, for: service)
    }

    func readValue(for characteristic: BluetoothCharacteristic) -> AnyPublisher<Data, Error> {
        return manager.readValue(for: characteristic)
    }

    func writeValue(
        _ data: Data, for characteristic: BluetoothCharacteristic, type: CBCharacteristicWriteType
    ) -> AnyPublisher<Void, Error> {
        return manager.writeValue(data, for: characteristic, type: type)
    }

    func setNotify(enabled: Bool, for characteristic: BluetoothCharacteristic) -> AnyPublisher<
        Data, Error
    > {
        return manager.setNotify(enabled: enabled, for: characteristic)
    }
}
