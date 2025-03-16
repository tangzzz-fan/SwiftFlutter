import Combine
import CoreBluetooth
import Foundation

/// 蓝牙仓储的具体实现
class CoreBluetoothRepository: BluetoothRepositoryProtocol {
    // MARK: - Properties
    private let manager: CoreBluetoothManager
    private var cancellables = Set<AnyCancellable>()
    private var packetBuffer: [UUID: Data] = [:]
    private var expectedSequenceNumbers: [UUID: Int] = [:]

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

    func sendData(_ data: Data, to peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        let mtu = peripheral.maximumWriteValueLength(for: .withResponse)
        let maxPayloadSize = mtu - 4

        if data.count > maxPayloadSize {
            var sequence = 0
            var offset = 0

            while offset < data.count {
                var chunkSize = min(maxPayloadSize, data.count - offset)
                var packet = Data()

                let totalPackets =
                    (data.count / maxPayloadSize) + (data.count % maxPayloadSize > 0 ? 1 : 0)
                packet.append(0x01)
                packet.append(UInt8(sequence))
                packet.append(UInt8(totalPackets >> 8))
                packet.append(UInt8(totalPackets & 0xFF))

                packet.append(data.subdata(in: offset..<(offset + chunkSize)))

                peripheral.writeValue(packet, for: characteristic, type: .withResponse)

                offset += chunkSize
                sequence += 1
            }
        } else {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard let data = characteristic.value else { return }

        if data.count > 4 && data[0] == 0x01 {
            let sequenceNumber = Int(data[1])
            let totalPackets = (Int(data[2]) << 8) | Int(data[3])
            let payload = data.subdata(in: 4..<data.count)

            if packetBuffer[peripheral.identifier] == nil {
                packetBuffer[peripheral.identifier] = Data()
            }

            if sequenceNumber == expectedSequenceNumbers[peripheral.identifier] ?? 0 {
                packetBuffer[peripheral.identifier]?.append(payload)
                expectedSequenceNumbers[peripheral.identifier] =
                    (expectedSequenceNumbers[peripheral.identifier] ?? 0) + 1

                if expectedSequenceNumbers[peripheral.identifier] == totalPackets {
                    if let completeData = packetBuffer[peripheral.identifier] {
                        delegate?.didReceiveData(completeData, from: peripheral)
                    }
                    packetBuffer[peripheral.identifier] = nil
                    expectedSequenceNumbers[peripheral.identifier] = 0
                }
            } else {
                requestRetransmission(
                    peripheral, characteristic: characteristic,
                    fromSequence: expectedSequenceNumbers[peripheral.identifier] ?? 0)
            }
        } else {
            delegate?.didReceiveData(data, from: peripheral)
        }
    }

    private func requestRetransmission(
        _ peripheral: CBPeripheral, characteristic: CBCharacteristic, fromSequence: Int
    ) {
        let retransmitCommand = Data([0x02, UInt8(fromSequence)])
        peripheral.writeValue(retransmitCommand, for: characteristic, type: .withResponse)
    }
}
