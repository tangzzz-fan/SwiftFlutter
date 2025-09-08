import Flutter
import Foundation
import CoreBluetooth

class BluetoothEngineManager {
    // 引擎组和引擎缓存
    private let engineGroup: FlutterEngineGroup
    private var engineCache = [String: FlutterEngine]()

    // 跟踪引擎使用情况
    private var engineUsage = [String: Date]()

    // 使用依赖注入原则，接收外部创建的引擎组
    init(engineGroup: FlutterEngineGroup) {
        self.engineGroup = engineGroup
    }

    // 惰性创建引擎，避免不必要的资源消耗
    func getOrCreateEngine(for moduleId: String, entrypoint: String? = nil) -> FlutterEngine {
        if let cachedEngine = engineCache[moduleId] {
            // 更新使用时间戳
            engineUsage[moduleId] = Date()
            return cachedEngine
        }

        // 创建新引擎并指定入口点
        let engine = engineGroup.makeEngine(
            withEntrypoint: entrypoint,
            libraryURI: nil
        )

        // 注册必要的插件
        registerPlugins(for: engine)

        // 创建并注册通信通道
        registerCommunicationChannel(for: engine, moduleId: moduleId)

        // 缓存引擎并记录使用时间
        engineCache[moduleId] = engine
        engineUsage[moduleId] = Date()

        print("已创建新的Flutter引擎: \(moduleId)")
        return engine
    }

    // 负责任地释放引擎资源
    func releaseEngine(for moduleId: String) {
        guard let engine = engineCache[moduleId] else { return }

        // 从路由中注销通信通道
        BluetoothMessageRouter.shared.unregisterEngine(id: moduleId)

        // 销毁引擎
        engine.destroyContext()
        engineCache.removeValue(forKey: moduleId)
        engineUsage.removeValue(forKey: moduleId)

        print("已释放Flutter引擎: \(moduleId)")
    }

    // 执行引擎维护 - 清理长时间未使用的引擎
    func performMaintenance(olderThan minutes: Double = 5.0) {
        let now = Date()
        let staleEngines = engineUsage.filter {
            now.timeIntervalSince($0.value) > minutes * 60
        }.map { $0.key }

        for engineId in staleEngines {
            print("清理长时间未使用的引擎: \(engineId)")
            releaseEngine(for: engineId)
        }
    }

    // 注册插件
    private func registerPlugins(for engine: FlutterEngine) {
        // 注册蓝牙插件
        let binaryMessenger = engine.binaryMessenger
        BluetoothPlugin.register(binaryMessenger: binaryMessenger)
    }

    // 为引擎创建并注册通信通道
    private func registerCommunicationChannel(for engine: FlutterEngine, moduleId: String) {
        let binaryMessenger = engine.binaryMessenger

        // 创建Method Channel
        let channelName = "com.swiftflutter.bluetooth.\(moduleId)"
        let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)

        // 注册到路由器
        BluetoothMessageRouter.shared.registerEngine(id: moduleId, methodChannel: channel)
    }

    // 获取当前活动的引擎数量
    var activeEngineCount: Int {
        return engineCache.count
    }

    // 获取当前活动的引擎ID列表
    var activeEngineIds: [String] {
        return Array(engineCache.keys)
    }
}
