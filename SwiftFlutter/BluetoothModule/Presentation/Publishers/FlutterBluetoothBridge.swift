import Combine
import CoreBluetooth
import Flutter
import Foundation

/// Flutter与蓝牙模块的桥接类
class FlutterBluetoothBridge {
    // MARK: - Properties
    private let methodChannel: FlutterMethodChannel
    private let bluetoothService: BluetoothService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init(
        binaryMessenger: FlutterBinaryMessenger,
        bluetoothService: BluetoothService = BluetoothService()
    ) {
        self.methodChannel = FlutterMethodChannel(
            name: "com.example.swiftflutter/bluetooth", binaryMessenger: binaryMessenger)
        self.bluetoothService = bluetoothService

        setupMethodCallHandler()
        setupBluetoothSubscriptions()
    }

    // MARK: - Private Methods
    private func setupMethodCallHandler() {
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            switch call.method {
            case "getBluetoothState":
                self.handleGetBluetoothState(result: result)

            case "startScan":
                let serviceUUIDs = call.arguments as? [String]
                self.handleStartScan(serviceUUIDs: serviceUUIDs, result: result)

            case "stopScan":
                self.handleStopScan(result: result)

            case "getDevices":
                self.handleGetDevices(result: result)

            case "connect":
                guard let deviceId = call.arguments as? String,
                    let uuid = UUID(uuidString: deviceId)
                else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "设备ID无效", details: nil))
                    return
                }
                self.handleConnect(deviceId: uuid, result: result)

            case "disconnect":
                self.handleDisconnect(result: result)

            case "readCharacteristic":
                guard let args = call.arguments as? [String: Any],
                    let serviceUUID = args["serviceUuid"] as? String,
                    let characteristicUUID = args["characteristicUuid"] as? String
                else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "参数无效", details: nil))
                    return
                }
                self.handleReadCharacteristic(
                    serviceUUID: serviceUUID, characteristicUUID: characteristicUUID, result: result
                )

            case "writeCharacteristic":
                guard let args = call.arguments as? [String: Any],
                    let serviceUUID = args["serviceUuid"] as? String,
                    let characteristicUUID = args["characteristicUuid"] as? String,
                    let dataString = args["data"] as? String,
                    let data = Data(base64Encoded: dataString)
                else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "参数无效", details: nil))
                    return
                }
                let writeType =
                    (args["withResponse"] as? Bool ?? true)
                    ? CBCharacteristicWriteType.withResponse : .withoutResponse
                self.handleWriteCharacteristic(
                    serviceUUID: serviceUUID, characteristicUUID: characteristicUUID, data: data,
                    type: writeType, result: result)

            case "setNotification":
                guard let args = call.arguments as? [String: Any],
                    let serviceUUID = args["serviceUuid"] as? String,
                    let characteristicUUID = args["characteristicUuid"] as? String,
                    let enable = args["enable"] as? Bool
                else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "参数无效", details: nil))
                    return
                }
                self.handleSetNotification(
                    serviceUUID: serviceUUID, characteristicUUID: characteristicUUID,
                    enable: enable, result: result)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func setupBluetoothSubscriptions() {
        // 监听蓝牙消息并发送给Flutter
        bluetoothService.messagesPublisher
            .sink { [weak self] message in
                guard let jsonString = message.toJsonString() else { return }
                self?.methodChannel.invokeMethod("onBluetoothMessage", arguments: jsonString)
            }
            .store(in: &cancellables)
    }

    // MARK: - Method Handlers
    private func handleGetBluetoothState(result: @escaping FlutterResult) {
        bluetoothService.statePublisher
            .first()
            .map { $0.rawValue }
            .sink { state in
                result(state)
            }
            .store(in: &cancellables)
    }

    private func handleStartScan(serviceUUIDs: [String]?, result: @escaping FlutterResult) {
        let uuids = serviceUUIDs?.compactMap { CBUUID(string: $0) }
        bluetoothService.startScan(withServices: uuids)
        result(true)
    }

    private func handleStopScan(result: @escaping FlutterResult) {
        bluetoothService.stopScan()
        result(true)
    }

    private func handleGetDevices(result: @escaping FlutterResult) {
        bluetoothService.devicesPublisher
            .first()
            .map { devices -> [[String: Any]] in
                return devices.map { device in
                    var deviceMap: [String: Any] = [
                        "id": device.id.uuidString,
                        "hasName": device.hasName,
                    ]

                    if let name = device.name {
                        deviceMap["name"] = name
                    }

                    if let rssi = device.rssi {
                        deviceMap["rssi"] = rssi
                    }

                    return deviceMap
                }
            }
            .sink { devicesMap in
                result(devicesMap)
            }
            .store(in: &cancellables)
    }

    private func handleConnect(deviceId: UUID, result: @escaping FlutterResult) {
        bluetoothService.devicesPublisher
            .first()
            .flatMap { devices -> AnyPublisher<BluetoothDevice?, Error> in
                if let device = devices.first(where: { $0.id == deviceId }) {
                    self.bluetoothService.connect(to: device)
                    return self.bluetoothService.connectedDevicePublisher
                        .filter { $0?.id == deviceId }
                        .first()
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: BluetoothError.deviceNotFound)
                        .eraseToAnyPublisher()
                }
            }
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        result(
                            FlutterError(
                                code: "CONNECTION_FAILED", message: error.localizedDescription,
                                details: nil))
                    }
                },
                receiveValue: { _ in
                    result(true)
                }
            )
            .store(in: &cancellables)
    }

    private func handleDisconnect(result: @escaping FlutterResult) {
        bluetoothService.disconnect()
        result(true)
    }

    private func handleReadCharacteristic(
        serviceUUID: String, characteristicUUID: String, result: @escaping FlutterResult
    ) {
        // 这个处理需要先发现特征，然后读取值
        // 简化版实现，实际应用中需要更健壮的错误处理

        guard let device = bluetoothService.currentConnectedDevice,
            let service = device.peripheral.services?.first(where: {
                $0.uuid == CBUUID(string: serviceUUID)
            })
        else {
            result(FlutterError(code: "SERVICE_NOT_FOUND", message: "未找到指定的服务", details: nil))
            return
        }

        bluetoothService.discoverCharacteristics([CBUUID(string: characteristicUUID)], for: service)
            .first()
            .flatMap { characteristics -> AnyPublisher<Data, Error> in
                guard
                    let characteristic = characteristics.first(where: {
                        $0.uuid == CBUUID(string: characteristicUUID)
                    })
                else {
                    return Fail(error: BluetoothError.characteristicDiscoveryFailed)
                        .eraseToAnyPublisher()
                }

                return self.bluetoothService.readValue(for: characteristic)
            }
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        result(
                            FlutterError(
                                code: "READ_FAILED", message: error.localizedDescription,
                                details: nil))
                    }
                },
                receiveValue: { data in
                    result(data.base64EncodedString())
                }
            )
            .store(in: &cancellables)
    }

    private func handleWriteCharacteristic(
        serviceUUID: String, characteristicUUID: String, data: Data,
        type: CBCharacteristicWriteType, result: @escaping FlutterResult
    ) {
        guard let device = bluetoothService.currentConnectedDevice,
            let service = device.peripheral.services?.first(where: {
                $0.uuid == CBUUID(string: serviceUUID)
            })
        else {
            result(FlutterError(code: "SERVICE_NOT_FOUND", message: "未找到指定的服务", details: nil))
            return
        }

        bluetoothService.discoverCharacteristics([CBUUID(string: characteristicUUID)], for: service)
            .first()
            .flatMap { characteristics -> AnyPublisher<Void, Error> in
                guard
                    let characteristic = characteristics.first(where: {
                        $0.uuid == CBUUID(string: characteristicUUID)
                    })
                else {
                    return Fail(error: BluetoothError.characteristicDiscoveryFailed)
                        .eraseToAnyPublisher()
                }

                return self.bluetoothService.writeValue(data, for: characteristic, type: type)
            }
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        result(
                            FlutterError(
                                code: "WRITE_FAILED", message: error.localizedDescription,
                                details: nil))
                    }
                },
                receiveValue: { _ in
                    result(true)
                }
            )
            .store(in: &cancellables)
    }

    private func handleSetNotification(
        serviceUUID: String, characteristicUUID: String, enable: Bool,
        result: @escaping FlutterResult
    ) {
        guard let device = bluetoothService.currentConnectedDevice,
            let service = device.peripheral.services?.first(where: {
                $0.uuid == CBUUID(string: serviceUUID)
            })
        else {
            result(FlutterError(code: "SERVICE_NOT_FOUND", message: "未找到指定的服务", details: nil))
            return
        }

        bluetoothService.discoverCharacteristics([CBUUID(string: characteristicUUID)], for: service)
            .first()
            .flatMap { characteristics -> AnyPublisher<Data, Error> in
                guard
                    let characteristic = characteristics.first(where: {
                        $0.uuid == CBUUID(string: characteristicUUID)
                    })
                else {
                    return Fail(error: BluetoothError.characteristicDiscoveryFailed)
                        .eraseToAnyPublisher()
                }

                return self.bluetoothService.setNotify(enabled: enable, for: characteristic)
                    .first()  // 只取第一个值，表示设置成功
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        result(
                            FlutterError(
                                code: "NOTIFICATION_SETUP_FAILED",
                                message: error.localizedDescription, details: nil))
                    }
                },
                receiveValue: { _ in
                    result(true)
                }
            )
            .store(in: &cancellables)
    }
}
