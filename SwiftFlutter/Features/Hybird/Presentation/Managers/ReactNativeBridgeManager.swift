//
//  ReactNativeBridgeManager.swift
//  SwiftFlutter
//
//  Created by AI Assistant on 2025/06/10.
//

import Foundation
import React

/// Bridge状态枚举
enum BridgeState {
    case notInitialized
    case initializing
    case ready
    case failed(Error)
    case invalidated
}

/// Bridge状态变化通知
extension Notification.Name {
    static let bridgeStateChanged = Notification.Name("BridgeStateChanged")
}

/// React Native 桥接管理器
class ReactNativeBridgeManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = ReactNativeBridgeManager()
    
    // MARK: - Properties
    
    private var _bridge: RCTBridge?
    private let bridgeQueue = DispatchQueue(label: "com.swiftflutter.bridge", qos: .userInitiated)
    private let stateQueue = DispatchQueue(label: "com.swiftflutter.bridge.state", qos: .userInitiated)
    
    private var _state: BridgeState = .notInitialized
    private var state: BridgeState {
        get {
            return stateQueue.sync { _state }
        }
        set {
            stateQueue.async { [weak self] in
                self?._state = newValue
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .bridgeStateChanged,
                        object: self,
                        userInfo: ["state": newValue]
                    )
                }
            }
        }
    }
    
    var bridge: RCTBridge? {
        return bridgeQueue.sync { _bridge }
    }
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        setupBridgeStateObserver()
    }
    
    // MARK: - Public Methods
    
    /// 初始化 React Native 桥接
    func initializeBridge(launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        guard case .notInitialized = state else {
            print("React Native bridge 已经初始化或正在初始化中，当前状态: \(state)")
            return
        }
        
        state = .initializing
        print("开始初始化 React Native bridge...")
        
        DispatchQueue.main.async { [weak self] in
            self?.setupBridge(launchOptions: launchOptions)
        }
    }
    
    /// 检查桥接是否可用
    func isBridgeReady() -> Bool {
        if case .ready = state {
            return bridge != nil && bridge?.isValid == true
        }
        return false
    }
    
    /// 获取当前bridge状态
    func getBridgeState() -> BridgeState {
        return state
    }
    
    /// 重新加载 React Native
    func reloadBridge() {
        guard isBridgeReady(), let bridge = bridge else {
            print("Bridge 未就绪，无法重载")
            return
        }
        
        print("重新加载 React Native bridge...")
        bridge.reload()
    }
    
    /// 强制重新初始化bridge
    func forceReinitialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        print("强制重新初始化 React Native bridge...")
        cleanupBridge()
        
        // 等待cleanup完成后再重新初始化
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.initializeBridge(launchOptions: launchOptions)
        }
    }
    
    /// 清理桥接资源
    func cleanupBridge() {
        bridgeQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let bridge = self._bridge {
                DispatchQueue.main.async {
                    bridge.invalidate()
                }
                self._bridge = nil
            }
            
            DispatchQueue.main.async {
                self.state = .notInitialized
                print("React Native bridge 已清理")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBridgeStateObserver() {
        // 监听应用生命周期事件
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillTerminate),
            name: UIApplication.willTerminateNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
    }
    
    private func setupBridge(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard case .initializing = state else {
            print("Bridge状态不正确，无法初始化")
            return
        }
        
        // 获取bundle URL
        guard let bundleURL = getBundleURL() else {
            state = .failed(ReactNativeBridgeError.bundleURLNotFound)
            return
        }
        
        do {
            // 创建桥接
            let bridge = RCTBridge(delegate: self, launchOptions: launchOptions)
            
            guard let bridge = bridge else {
                throw ReactNativeBridgeError.bridgeCreationFailed
            }
            
            // 验证bridge是否有效
            guard bridge.isValid else {
                throw ReactNativeBridgeError.bridgeInvalid
            }
            
            bridgeQueue.async { [weak self] in
                self?._bridge = bridge
                
                DispatchQueue.main.async {
                    self?.state = .ready
                    print("React Native bridge 初始化成功")
                    print("Bundle URL: \(bundleURL)")
                }
            }
            
        } catch {
            state = .failed(error)
            print("React Native bridge 初始化失败: \(error.localizedDescription)")
        }
    }
    
    private func getBundleURL() -> URL? {
        #if DEBUG
            // 开发模式 - 使用 Metro bundler
            var urlString = "localhost"
            
            #if targetEnvironment(simulator)
            urlString = "localhost"
            #else
            urlString = "192.168.2.241"
            #endif
            
            guard let bundleURL = URL(string: "http://\(urlString):8081/index.bundle?platform=ios&dev=true&minify=false") else {
                print("无法创建开发模式的 bundle URL")
                return nil
            }
            return bundleURL
        #else
            // 生产模式 - 使用本地 bundle
            guard let bundlePath = Bundle.main.path(forResource: "main", ofType: "jsbundle") else {
                print("无法找到生产环境的 bundle 文件")
                return nil
            }
            return URL(fileURLWithPath: bundlePath)
        #endif
    }
    
    // MARK: - Application Lifecycle
    
    @objc private func applicationWillTerminate() {
        cleanupBridge()
    }
    
    @objc private func applicationDidEnterBackground() {
        // 在后台时不清理bridge，但可以添加其他逻辑
        print("应用进入后台，bridge状态: \(state)")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        cleanupBridge()
    }
}

// MARK: - Bridge Errors

enum ReactNativeBridgeError: Error, LocalizedError {
    case bundleURLNotFound
    case bridgeCreationFailed
    case bridgeInvalid
    case bridgeNotReady
    
    var errorDescription: String? {
        switch self {
        case .bundleURLNotFound:
            return "无法找到Bundle URL"
        case .bridgeCreationFailed:
            return "Bridge创建失败"
        case .bridgeInvalid:
            return "Bridge无效"
        case .bridgeNotReady:
            return "Bridge未就绪"
        }
    }
}

// MARK: - RCTBridgeDelegate

extension ReactNativeBridgeManager: RCTBridgeDelegate {
    
    func sourceURL(for bridge: RCTBridge) -> URL? {
        return getBundleURL()
    }
    
    func extraModules(for bridge: RCTBridge) -> [any RCTBridgeModule] {
        // 注册额外的原生模块
        var modules: [any RCTBridgeModule] = []
        
        // 添加自定义的原生模块
        modules.append(SmartHomeNativeModule())
        
        return modules
    }
    
    func shouldBridgeUseCxxBridge(_ bridge: RCTBridge!) -> Bool {
        return true
    }
    
    // MARK: - Bridge Delegate Callbacks
    
    func bridge(_ bridge: RCTBridge, didNotFindModule moduleName: String) {
        print("Bridge未找到模块: \(moduleName)")
    }
    
    func bridge(_ bridge: RCTBridge, didFailToLoadBundle error: Error) {
        print("Bridge加载Bundle失败: \(error.localizedDescription)")
        state = .failed(error)
    }
    
    func bridgeDidFinishLoading(_ bridge: RCTBridge) {
        print("Bridge加载完成")
        // 确保状态正确
        if case .initializing = state {
            state = .ready
        }
    }
    
    func bridgeWillReload(_ bridge: RCTBridge) {
        print("Bridge即将重新加载")
    }
    
    func bridgeDidReload(_ bridge: RCTBridge) {
        print("Bridge重新加载完成")
        state = .ready
    }
}

// MARK: - Health Check Extension

extension ReactNativeBridgeManager {
    
    /// 执行bridge健康检查
    func performHealthCheck() -> Bool {
        guard let bridge = bridge else {
            print("Health Check: Bridge为空")
            return false
        }
        
        guard bridge.isValid else {
            print("Health Check: Bridge无效")
            state = .invalidated
            return false
        }
        
        guard case .ready = state else {
            print("Health Check: Bridge状态不正确 - \(state)")
            return false
        }
        
        // 检查bundle是否加载
        guard bridge.bundleURL != nil else {
            print("Health Check: Bundle URL为空")
            return false
        }
        
        print("Health Check: Bridge健康")
        return true
    }
    
    /// 启动定期健康检查
    func startHealthMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.performHealthCheck()
        }
    }
    
    /// 等待bridge就绪
    func waitForBridgeReady(timeout: TimeInterval = 10.0, completion: @escaping (Bool) -> Void) {
        let startTime = Date()
        
        func checkReady() {
            if isBridgeReady() {
                completion(true)
                return
            }
            
            if Date().timeIntervalSince(startTime) > timeout {
                completion(false)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                checkReady()
            }
        }
        
        checkReady()
    }
}

// MARK: - RCTBridgeModule (可选)

/// 示例原生模块，用于与 React Native 通信
@objc(SmartHomeNativeModule)
class SmartHomeNativeModule: NSObject, RCTBridgeModule {
    
    static func moduleName() -> String! {
        return "SmartHomeNativeModule"
    }
    
    static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    /// 获取设备信息
    @objc func getDeviceInfo(_ resolve: @escaping RCTPromiseResolveBlock,
                             rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            let deviceInfo = [
                "model": UIDevice.current.model,
                "systemName": UIDevice.current.systemName,
                "systemVersion": UIDevice.current.systemVersion,
                "deviceIdentifier": UIDevice.current.identifierForVendor?.uuidString ?? ""
            ]
            resolve(deviceInfo)
        }
    }
    
    /// 打开原生设置
    @objc func openSettings(_ resolve: @escaping RCTPromiseResolveBlock,
                           rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: { success in
                    resolve(["success": success])
                })
            } else {
                reject("SETTINGS_ERROR", "无法打开设置", nil)
            }
        }
    }
}
