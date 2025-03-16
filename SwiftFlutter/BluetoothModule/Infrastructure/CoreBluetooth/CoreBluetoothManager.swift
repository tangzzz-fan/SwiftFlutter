import Combine
import CoreBluetooth
import Foundation

/// CoreBluetooth 实现类
class CoreBluetoothManager: NSObject {
    // MARK: - Properties
    internal var covcentralManager: CBCentralManager!

    // MARK: - Publishers
    internal let stateSubject = CurrentValueSubject<CBManagerState, Never>(.unknown)
    internal let scanResultsSubject = CurrentValueSubject<[BluetoothDevice], Never>([])
    internal let connectedDeviceSubject = PassthroughSubject<BluetoothDevice?, Error>()
    internal let servicesSubject = PassthroughSubject<[CBService], Error>()
    internal let characteristicsSubject = PassthroughSubject<[BluetoothCharacteristic], Error>()
    internal let readValueSubject = PassthroughSubject<(Data, CBCharacteristic), Error>()
    internal let writeValueSubject = PassthroughSubject<CBCharacteristic, Error>()
    internal let notifyValueSubject = PassthroughSubject<(Data, CBCharacteristic), Error>()

    // MARK: - Private Properties
    internal var scanResults: [UUID: BluetoothDevice] = [:]
    internal var readCharacteristicSubjects: [CBUUID: PassthroughSubject<Data, Error>] = [:]
    internal var writeCharacteristicSubjects: [CBUUID: PassthroughSubject<Void, Error>] = [:]
    internal var notifyCharacteristicSubjects: [CBUUID: PassthroughSubject<Data, Error>] = [:]

    internal var connectedPeripheral: CBPeripheral?

    // MARK: - Initialization
    override init() {
        super.init()
        covcentralManager = CBCentralManager(delegate: nil, queue: .main)
        covcentralManager.delegate = self
    }
}

// MARK: - CBCentralManagerDelegate
extension CoreBluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        let device = BluetoothDevice(
            peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
        scanResults[peripheral.identifier] = device
        scanResultsSubject.send(Array(scanResults.values))
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        if let device = scanResults[peripheral.identifier] {
            connectedDeviceSubject.send(device)
        }
    }

    func centralManager(
        _ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?
    ) {
        if let error = error {
            connectedDeviceSubject.send(completion: .failure(error))
        } else {
            connectedDeviceSubject.send(completion: .failure(BluetoothError.connectionFailed))
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
        connectedPeripheral = nil
        connectedDeviceSubject.send(nil)
    }
}

// MARK: - CBPeripheralDelegate
extension CoreBluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            servicesSubject.send(completion: .failure(error))
            return
        }

        if let services = peripheral.services {
            servicesSubject.send(services)
        } else {
            servicesSubject.send([])
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?
    ) {
        if let error = error {
            characteristicsSubject.send(completion: .failure(error))
            return
        }

        if let characteristics = service.characteristics {
            let btCharacteristics = characteristics.map {
                BluetoothCharacteristic(characteristic: $0)
            }
            characteristicsSubject.send(btCharacteristics)
        } else {
            characteristicsSubject.send([])
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            readValueSubject.send(completion: .failure(error))
            readCharacteristicSubjects[characteristic.uuid]?.send(completion: .failure(error))
            notifyCharacteristicSubjects[characteristic.uuid]?.send(completion: .failure(error))
            return
        }

        if let value = characteristic.value {
            readValueSubject.send((value, characteristic))
            readCharacteristicSubjects[characteristic.uuid]?.send(value)
            notifyCharacteristicSubjects[characteristic.uuid]?.send(value)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?
    ) {
        if let error = error {
            writeValueSubject.send(completion: .failure(error))
            writeCharacteristicSubjects[characteristic.uuid]?.send(completion: .failure(error))
            return
        }

        writeValueSubject.send(characteristic)
        writeCharacteristicSubjects[characteristic.uuid]?.send(())
    }

    func peripheral(
        _ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            notifyCharacteristicSubjects[characteristic.uuid]?.send(completion: .failure(error))
            return
        }

        // 只有当启用通知成功时才创建新的Subject
        if characteristic.isNotifying {
            if notifyCharacteristicSubjects[characteristic.uuid] == nil {
                notifyCharacteristicSubjects[characteristic.uuid] = PassthroughSubject<
                    Data, Error
                >()
            }
        } else {
            // 当禁用通知时，完成现有的Subject
            notifyCharacteristicSubjects[characteristic.uuid]?.send(completion: .finished)
            notifyCharacteristicSubjects.removeValue(forKey: characteristic.uuid)
        }
    }

    // 添加MTU协商方法
    func requestMTU(for peripheral: CBPeripheral, mtu: Int) {
        // 在iOS中，无法直接请求MTU
        // 但可以通过maximumWriteValueLength获取支持的MTU大小
        let currentMTU = peripheral.maximumWriteValueLength(for: .withResponse)
        logger.log("当前MTU大小：\(currentMTU)")

        // 通知上层MTU大小，可通过委托或回调
        delegate?.didUpdateMTU(size: currentMTU, for: peripheral)
    }
}
