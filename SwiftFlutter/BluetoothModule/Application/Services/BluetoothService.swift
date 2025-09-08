import Combine
import CoreBluetooth
import Foundation

/// 蓝牙服务类 - 对外提供统一的API接口
class BluetoothService {
    // MARK: - Properties
    private let repository: BluetoothRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Publishers
    private let bluetoothStateSubject = CurrentValueSubject<BluetoothState, Never>(.unknown)
    private let devicesSubject = CurrentValueSubject<[BluetoothDevice], Never>([])
    private let connectedDeviceSubject = CurrentValueSubject<BluetoothDevice?, Never>(nil)
    private let messagesSubject = PassthroughSubject<BluetoothMessage, Never>()

    // 公开的Publishers
    var statePublisher: AnyPublisher<BluetoothState, Never> {
        return bluetoothStateSubject.eraseToAnyPublisher()
    }

    var devicesPublisher: AnyPublisher<[BluetoothDevice], Never> {
        return devicesSubject.eraseToAnyPublisher()
    }

    var connectedDevicePublisher: AnyPublisher<BluetoothDevice?, Never> {
        return connectedDeviceSubject.eraseToAnyPublisher()
    }

    var messagesPublisher: AnyPublisher<BluetoothMessage, Never> {
        return messagesSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    init(repository: BluetoothRepositoryProtocol = CoreBluetoothRepository()) {
        self.repository = repository
        setupSubscriptions()
    }

    // MARK: - Private Methods
    private func setupSubscriptions() {
        // 监听蓝牙状态变化
        repository.statePublisher
            .map { state -> BluetoothState in
                switch state {
                case .poweredOn: return .ready
                case .poweredOff: return .disabled
                case .unauthorized: return .unauthorized
                case .unsupported: return .unsupported
                case .resetting: return .resetting
                default: return .unknown
                }
            }
            .sink { [weak self] state in
                self?.bluetoothStateSubject.send(state)

                // 当蓝牙状态变化时发送消息
                let message = BluetoothMessage(type: .stateChanged, data: ["state": state.rawValue])
                self?.messagesSubject.send(message)
            }
            .store(in: &cancellables)

        // 监听扫描结果
        repository.scanResultsPublisher
            .sink { [weak self] devices in
                self?.devicesSubject.send(devices)

                // 发送扫描结果消息
                let message = BluetoothMessage(type: .scanResult, data: ["count": devices.count])
                self?.messagesSubject.send(message)
            }
            .store(in: &cancellables)

        // 监听连接状态
        repository.connectedDevicePublisher
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.connectedDeviceSubject.send(nil)

                        // 发送连接错误消息
                        let message = BluetoothMessage(
                            type: .error,
                            data: ["error": error.localizedDescription]
                        )
                        self?.messagesSubject.send(message)
                    }
                },
                receiveValue: { [weak self] device in
                    self?.connectedDeviceSubject.send(device)

                    // 发送连接状态变化消息
                    let message = BluetoothMessage(
                        type: device != nil ? .connected : .disconnected,
                        data: ["deviceName": device?.name ?? "未知设备"]
                    )
                    self?.messagesSubject.send(message)
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// 开始扫描蓝牙设备
    /// - Parameter serviceUUIDs: 要扫描的服务UUID，如果为nil则扫描所有设备
    func startScan(withServices serviceUUIDs: [CBUUID]? = nil) {
        guard bluetoothStateSubject.value == .ready else {
            messagesSubject.send(
                BluetoothMessage(
                    type: .error,
                    data: ["error": BluetoothError.notReady.localizedDescription]
                ))
            return
        }

        repository.startScan(withServices: serviceUUIDs)
        messagesSubject.send(BluetoothMessage(type: .scanStarted, data: nil))
    }

    /// 停止扫描蓝牙设备
    func stopScan() {
        repository.stopScan()
        messagesSubject.send(BluetoothMessage(type: .scanStopped, data: nil))
    }

    /// 连接到蓝牙设备
    /// - Parameter device: 要连接的蓝牙设备
    func connect(to device: BluetoothDevice) {
        // 确保先断开已有连接
        if connectedDeviceSubject.value != nil {
            repository.disconnect()
        }

        // 连接到新设备
        repository.connect(device: device)

        // 发送连接中消息
        let message = BluetoothMessage(
            type: .connecting,
            data: ["deviceId": device.id.uuidString, "deviceName": device.name ?? "未知设备"]
        )
        messagesSubject.send(message)
    }

    /// 断开当前连接的蓝牙设备
    func disconnect() {
        repository.disconnect()
        messagesSubject.send(BluetoothMessage(type: .disconnecting, data: nil))
    }

    /// 发现服务
    /// - Parameter serviceUUIDs: 要发现的服务UUID，如果为nil则发现所有服务
    /// - Returns: 发现的服务列表Publisher
    func discoverServices(serviceUUIDs: [CBUUID]? = nil) -> AnyPublisher<[CBService], Error> {
        repository.discoverServices(serviceUUIDs: serviceUUIDs)
        return repository.servicesPublisher
    }

    /// 发现特征值
    /// - Parameters:
    ///   - characteristicUUIDs: 要发现的特征值UUID，如果为nil则发现所有特征值
    ///   - service: 要发现特征值的服务
    /// - Returns: 发现的特征值列表Publisher
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]? = nil, for service: CBService)
        -> AnyPublisher<[BluetoothCharacteristic], Error>
    {
        repository.discoverCharacteristics(characteristicUUIDs, for: service)
        return repository.characteristicsPublisher
    }

    /// 读取特征值
    /// - Parameter characteristic: 要读取的特征值
    /// - Returns: 读取到的数据Publisher
    func readValue(for characteristic: BluetoothCharacteristic) -> AnyPublisher<Data, Error> {
        return repository.readValue(for: characteristic)
            .handleEvents(receiveOutput: { [weak self] data in
                // 发送读取数据成功消息
                let message = BluetoothMessage(
                    type: .dataReceived,
                    data: [
                        "uuid": characteristic.uuid.uuidString,
                        "length": data.count,
                    ]
                )
                self?.messagesSubject.send(message)
            })
            .eraseToAnyPublisher()
    }

    /// 写入特征值
    /// - Parameters:
    ///   - data: 要写入的数据
    ///   - characteristic: 要写入的特征值
    ///   - type: 写入类型，有响应或无响应
    /// - Returns: 写入操作结果Publisher
    func writeValue(
        _ data: Data, for characteristic: BluetoothCharacteristic,
        type: CBCharacteristicWriteType = .withResponse
    ) -> AnyPublisher<Void, Error> {
        return repository.writeValue(data, for: characteristic, type: type)
            .handleEvents(receiveOutput: { [weak self] _ in
                // 发送写入数据成功消息
                let message = BluetoothMessage(
                    type: .dataSent,
                    data: [
                        "uuid": characteristic.uuid.uuidString,
                        "length": data.count,
                    ]
                )
                self?.messagesSubject.send(message)
            })
            .eraseToAnyPublisher()
    }

    /// 设置特征值通知
    /// - Parameters:
    ///   - enabled: 是否启用通知
    ///   - characteristic: 要设置通知的特征值
    /// - Returns: 通知数据Publisher
    func setNotify(enabled: Bool, for characteristic: BluetoothCharacteristic) -> AnyPublisher<
        Data, Error
    > {
        return repository.setNotify(enabled: enabled, for: characteristic)
            .handleEvents(receiveOutput: { [weak self] data in
                // 发送通知数据消息
                let message = BluetoothMessage(
                    type: .notification,
                    data: [
                        "uuid": characteristic.uuid.uuidString,
                        "length": data.count,
                    ]
                )
                self?.messagesSubject.send(message)
            })
            .eraseToAnyPublisher()
    }

    /// 向Flutter发送蓝牙状态或数据
    /// - Parameter message: 要发送的消息
    func sendMessageToFlutter(_ message: BluetoothMessage) {
        messagesSubject.send(message)
    }

    var currentConnectedDevice: BluetoothDevice? {
        return connectedDeviceSubject.value
    }
}
