import CoreBluetooth
import Foundation

/// 蓝牙设备实体
struct BluetoothDevice: Identifiable, Equatable {
    let id: UUID
    let name: String?
    let rssi: Int?
    let advertisementData: [String: Any]
    let peripheral: CBPeripheral

    var hasName: Bool {
        return name != nil && !name!.isEmpty
    }

    static func == (lhs: BluetoothDevice, rhs: BluetoothDevice) -> Bool {
        return lhs.id == rhs.id
    }
    
    func toCompactDictionary() {
        
    }

    init(peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        self.id = peripheral.identifier
        self.name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
        self.rssi = rssi.intValue
        self.advertisementData = advertisementData
        self.peripheral = peripheral
    }
}
