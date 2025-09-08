import Combine
import CoreBluetooth
import Foundation

// MARK: - Public Methods
extension CoreBluetoothManager {
    // MARK: - Publishers
    var statePublisher: AnyPublisher<CBManagerState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    var scanResultsPublisher: AnyPublisher<[BluetoothDevice], Never> {
        return scanResultsSubject.eraseToAnyPublisher()
    }

    var connectedDevicePublisher: AnyPublisher<BluetoothDevice?, Error> {
        return connectedDeviceSubject.eraseToAnyPublisher()
    }

    var servicesPublisher: AnyPublisher<[CBService], Error> {
        return servicesSubject.eraseToAnyPublisher()
    }

    var characteristicsPublisher: AnyPublisher<[BluetoothCharacteristic], Error> {
        return characteristicsSubject.eraseToAnyPublisher()
    }

    // MARK: - Scanning Methods
    func startScan(withServices serviceUUIDs: [CBUUID]?) {
        // 清空之前的扫描结果
        scanResults.removeAll()
        scanResultsSubject.send([])

        // 开始扫描 - 使用类型转换和明确的选项类型
        let scanOptions: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        covcentralManager.scanForPeripherals(
            withServices: serviceUUIDs,
            options: scanOptions)
    }

    func stopScan() {
        // 使用类型转换
        covcentralManager.stopScan()
    }

    // MARK: - Connection Methods
    func connect(device: BluetoothDevice) {
        // 使用类型转换和明确的options类型
        let options: [String: Any]? = nil
        covcentralManager.connect(device.peripheral, options: options)
        device.peripheral.delegate = self
    }

    func disconnect() {
        if let peripheral = self.connectedPeripheral {
            // 使用类型转换
            covcentralManager.cancelPeripheralConnection(peripheral)
        }
    }

    // MARK: - Service Discovery Methods
    func discoverServices(serviceUUIDs: [CBUUID]?) {
        self.connectedPeripheral?.discoverServices(serviceUUIDs)
    }

    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        self.connectedPeripheral?.discoverCharacteristics(characteristicUUIDs, for: service)
    }

    // MARK: - Characteristic Operations
    func readValue(for characteristic: BluetoothCharacteristic) -> AnyPublisher<Data, Error> {
        let uuid = characteristic.uuid
        let subject = readCharacteristicSubjects[uuid] ?? PassthroughSubject<Data, Error>()

        readCharacteristicSubjects[uuid] = subject
        self.connectedPeripheral?.readValue(for: characteristic.characteristic)

        return
            subject
            .timeout(.seconds(10), scheduler: RunLoop.main)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .finished = completion {
                    self?.readCharacteristicSubjects.removeValue(forKey: uuid)
                }
            })
            .eraseToAnyPublisher()
    }

    func writeValue(
        _ data: Data, for characteristic: BluetoothCharacteristic, type: CBCharacteristicWriteType
    ) -> AnyPublisher<Void, Error> {
        let subject = PassthroughSubject<Void, Error>()

        // 只有在需要响应的情况下才存储subject
        if type == .withResponse {
            writeCharacteristicSubjects[characteristic.uuid] = subject
        }

        self.connectedPeripheral?.writeValue(data, for: characteristic.characteristic, type: type)

        // 如果不需要响应，立即发送完成
        if type == .withoutResponse {
            subject.send(())
            subject.send(completion: .finished)
            return subject.eraseToAnyPublisher()
        }

        return
            subject
            .timeout(.seconds(10), scheduler: RunLoop.main)
            .handleEvents(receiveCompletion: { [weak self] completion in
                if case .finished = completion {
                    self?.writeCharacteristicSubjects.removeValue(forKey: characteristic.uuid)
                }
            })
            .eraseToAnyPublisher()
    }

    func setNotify(enabled: Bool, for characteristic: BluetoothCharacteristic) -> AnyPublisher<
        Data, Error
    > {
        let uuid = characteristic.uuid
        let existing = notifyCharacteristicSubjects[uuid]

        let subject = existing ?? PassthroughSubject<Data, Error>()

        if existing == nil && enabled {
            notifyCharacteristicSubjects[uuid] = subject
        }

        self.connectedPeripheral?.setNotifyValue(enabled, for: characteristic.characteristic)

        return subject.eraseToAnyPublisher()
    }
}
