import CoreBluetooth
import Foundation

/// 蓝牙特征值实体
struct BluetoothCharacteristic: Identifiable, Equatable {
    let id: UUID
    let uuid: CBUUID
    let service: CBService
    let properties: CBCharacteristicProperties
    let characteristic: CBCharacteristic

    var canRead: Bool {
        return properties.contains(.read)
    }

    var canWrite: Bool {
        return properties.contains(.write) || properties.contains(.writeWithoutResponse)
    }

    var canNotify: Bool {
        return properties.contains(.notify)
    }

    static func == (lhs: BluetoothCharacteristic, rhs: BluetoothCharacteristic) -> Bool {
        return lhs.id == rhs.id
    }

    init(characteristic: CBCharacteristic) {
        self.id = UUID()
        self.uuid = characteristic.uuid
        self.service = characteristic.service!
        self.properties = characteristic.properties
        self.characteristic = characteristic
    }
}
