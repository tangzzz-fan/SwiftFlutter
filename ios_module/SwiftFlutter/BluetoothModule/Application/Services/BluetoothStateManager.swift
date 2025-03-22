import Combine
import CoreBluetooth
import Foundation

class BluetoothStateManager {
    static let shared = BluetoothStateManager()

    // 使用 Combine 发布当前状态
    private let stateSubject = CurrentValueSubject<BluetoothState, Never>(.unknown)
    var statePublisher: AnyPublisher<BluetoothState, Never> {
        return stateSubject.eraseToAnyPublisher()
    }

    // 引擎状态追踪
    private var engineStates = [String: BluetoothState]()

    // 保存订阅
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // 监听核心蓝牙状态变化
        setupCoreBluetoothStateMonitoring()
    }

    // 当状态变化时，广播到所有引擎
    func updateState(_ newState: BluetoothState) {
        let oldState = stateSubject.value

        // 如果状态没有变化，不发送更新
        if oldState == newState { return }

        // 更新存储的状态
        stateSubject.send(newState)

        // 创建状态变化消息
        let message = BluetoothMessage(
            type: .stateChanged,
            data: ["state": newState.rawValue],
            timestamp: Date()
        )

        // 使用高优先级立即广播状态变化
        broadcastStateChange(message)

        // 记录状态变化
        print("蓝牙状态变化: \(oldState.rawValue) -> \(newState.rawValue)")
    }

    // 特定引擎的状态更新
    func updateState(_ newState: BluetoothState, forEngine engineId: String) {
        engineStates[engineId] = newState

        // 创建针对特定引擎的状态消息
        let message = BluetoothMessage(
            type: .stateChanged,
            data: ["state": newState.rawValue, "engineId": engineId],
            timestamp: Date()
        )

        // 只发送到特定引擎
        sendStateToEngine(message, engineId: engineId)
    }

    // 获取特定引擎的状态
    func getState(forEngine engineId: String) -> BluetoothState {
        return engineStates[engineId] ?? stateSubject.value
    }

    // 使用 MessageRouter 广播状态变化
    private func broadcastStateChange(_ message: BluetoothMessage) {
        guard let jsonData = try? JSONEncoder().encode(message),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            print("状态消息序列化失败")
            return
        }

        BluetoothMessageRouter.shared.broadcastMessage(
            method: "onBluetoothStateChanged",
            arguments: jsonString
        )
    }

    // 发送状态到特定引擎
    private func sendStateToEngine(_ message: BluetoothMessage, engineId: String) {
        guard let jsonData = try? JSONEncoder().encode(message),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            print("状态消息序列化失败")
            return
        }

        BluetoothMessageRouter.shared.sendMessage(
            to: engineId,
            method: "onBluetoothStateChanged",
            arguments: jsonString
        )
    }

    // 监控核心蓝牙状态变化
    private func setupCoreBluetoothStateMonitoring() {
        // 获取共享的蓝牙仓储
        let repository = SharedResourceManager.shared.getRepository()

        // 订阅状态变化
        repository.statePublisher
            .sink { [weak self] cbState in
                guard let self = self else { return }

                // 将 CoreBluetooth 状态映射到我们的状态枚举
                let mappedState: BluetoothState
                switch cbState {
                case .poweredOn:
                    mappedState = .ready
                case .poweredOff:
                    mappedState = .disabled
                case .unauthorized:
                    mappedState = .unauthorized
                case .unsupported:
                    mappedState = .unsupported
                case .resetting:
                    mappedState = .resetting
                case .unknown:
                    fallthrough
                @unknown default:
                    mappedState = .unknown
                }

                // 更新状态
                self.updateState(mappedState)
            }
            .store(in: &cancellables)
    }
}
