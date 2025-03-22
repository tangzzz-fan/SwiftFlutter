import Combine
import Foundation
import CoreBluetooth

class SharedResourceManager {
    static let shared = SharedResourceManager()

    // 共享的蓝牙连接实例
    private let bluetoothRepository: BluetoothRepositoryProtocol

    // 共享的设备缓存
    private var deviceCache = [String: BluetoothDevice]()
    private let deviceCacheLock = NSLock()

    // 服务和特征缓存
    private var serviceCache = [CBUUID: [CBUUID: BluetoothCharacteristic]]()
    private let serviceCacheLock = NSLock()

    // 订阅管理
    private var subscriptions = Set<AnyCancellable>()

    private init() {
        // 创建蓝牙仓储实例
        bluetoothRepository = CoreBluetoothRepository()

        // 设置设备更新监听
        setupDeviceSubscription()
    }

    // 获取共享的蓝牙仓储
    func getRepository() -> BluetoothRepositoryProtocol {
        return bluetoothRepository
    }

    // 设备缓存管理
    func cacheDevice(_ device: BluetoothDevice) {
        deviceCacheLock.lock()
        deviceCache[device.id.uuidString] = device
        deviceCacheLock.unlock()
    }

    func getDevice(byId id: String) -> BluetoothDevice? {
        deviceCacheLock.lock()
        defer { deviceCacheLock.unlock() }
        return deviceCache[id]
    }

    func getAllDevices() -> [BluetoothDevice] {
        deviceCacheLock.lock()
        defer { deviceCacheLock.unlock() }
        return Array(deviceCache.values)
    }

    // 清除特定设备
    func removeDevice(_ deviceId: String) {
        deviceCacheLock.lock()
        deviceCache.removeValue(forKey: deviceId)
        deviceCacheLock.unlock()
    }

    // 清除所有设备缓存
    func clearDeviceCache() {
        deviceCacheLock.lock()
        deviceCache.removeAll()
        deviceCacheLock.unlock()
    }

    // 缓存特征值
    func cacheCharacteristic(_ characteristic: BluetoothCharacteristic) {
        let serviceUUID = characteristic.service.uuid
        let characteristicUUID = characteristic.uuid

        serviceCacheLock.lock()
        if serviceCache[serviceUUID] == nil {
            serviceCache[serviceUUID] = [:]
        }
        serviceCache[serviceUUID]?[characteristicUUID] = characteristic
        serviceCacheLock.unlock()
    }

    // 获取缓存的特征值
    func getCharacteristic(serviceUUID: CBUUID, characteristicUUID: CBUUID)
        -> BluetoothCharacteristic?
    {
        serviceCacheLock.lock()
        defer { serviceCacheLock.unlock() }
        return serviceCache[serviceUUID]?[characteristicUUID]
    }

    // 监听设备更新
    private func setupDeviceSubscription() {
        bluetoothRepository.scanResultsPublisher
            .sink { [weak self] devices in
                guard let self = self else { return }

                for device in devices {
                    self.cacheDevice(device)
                }
            }
            .store(in: &subscriptions)
    }

    // 生成设备摘要数据
    func generateDeviceSummary() -> [String: Any] {
        deviceCacheLock.lock()
        defer { deviceCacheLock.unlock() }

        var summary: [String: Any] = [
            "deviceCount": deviceCache.count,
            "connectedCount": deviceCache.values.filter { $0.peripheral.state == .connected }.count,
        ]

        // 添加最近发现的5个设备信息
        let recentDevices = deviceCache.values.sorted {
            ($0.advertisementData["kCBAdvDataTimestamp"] as? Date ?? Date())
                > ($1.advertisementData["kCBAdvDataTimestamp"] as? Date ?? Date())
        }.prefix(5)

        summary["recentDevices"] = recentDevices.map { device in
            [
                "id": device.id.uuidString,
                "name": device.name ?? "Unknown",
                "rssi": device.rssi ?? 0,
            ]
        }

        return summary
    }
}
