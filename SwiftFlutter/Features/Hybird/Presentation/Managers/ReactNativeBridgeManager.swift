//
//  ReactNativeBridgeManager.swift
//  SwiftFlutter
//
//  Created by AI Assistant on 2025/06/10.
//

import Foundation
import React

/// React Native 桥接管理器
class ReactNativeBridgeManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = ReactNativeBridgeManager()
    
    // MARK: - Properties
    
    private var _bridge: RCTBridge?
    var bridge: RCTBridge? {
        return _bridge
    }
    
    private var isInitialized = false
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// 初始化 React Native 桥接
    func initializeBridge(launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        guard !isInitialized else {
            print("React Native bridge 已经初始化")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.setupBridge(launchOptions: launchOptions)
        }
    }
    
    /// 检查桥接是否可用
    func isBridgeReady() -> Bool {
        return _bridge != nil && isInitialized
    }
    
    /// 重新加载 React Native
    func reloadBridge() {
        guard let bridge = _bridge else {
            print("Bridge 未初始化，无法重载")
            return
        }
        
        bridge.reload()
        print("React Native bridge 已重载")
    }
    
    /// 清理桥接资源
    func cleanupBridge() {
        _bridge?.invalidate()
        _bridge = nil
        isInitialized = false
        print("React Native bridge 已清理")
    }
    
    // MARK: - Private Methods
    
    private func setupBridge(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        do {
            // 配置 React Native
            let bundleURL = getBundleURL()
            
            // 创建桥接
            let bridge = RCTBridge(delegate: self, launchOptions: launchOptions)
            
            guard let bridge = bridge else {
                print("创建 RCTBridge 失败")
                return
            }
            
            _bridge = bridge
            isInitialized = true
            
            print("React Native bridge 初始化成功")
            print("Bundle URL: \(bundleURL)")
            
        } catch {
            print("初始化 React Native bridge 失败: \(error)")
        }
    }
    
    private func getBundleURL() -> URL? {
        #if DEBUG
            // 开发模式 - 使用 Metro bundler
            // 使用本机IP地址而非localhost，解决iOS模拟器连接问题
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
}

// MARK: - RCTBridgeDelegate

extension ReactNativeBridgeManager: RCTBridgeDelegate {
    
    func sourceURL(for bridge: RCTBridge) -> URL? {
        return getBundleURL()
    }
    
    func extraModules(for bridge: RCTBridge) -> [any RCTBridgeModule] {
        // 注册额外的原生模块
        var modules: [any RCTBridgeModule] = []
        
        // 这里可以添加自定义的原生模块
        // modules.append(MyCustomNativeModule())
        
        return modules
    }
    
    func shouldBridgeUseCxxBridge(_ bridge: RCTBridge!) -> Bool {
        return true
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
