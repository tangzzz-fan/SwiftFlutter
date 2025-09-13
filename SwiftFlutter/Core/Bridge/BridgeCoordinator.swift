//
//  BridgeCoordinator.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import Foundation
import Flutter

/// 跨平台Bridge协调器
/// 作为原生与各技术栈间通信的核心中介桥梁
class BridgeCoordinator {
    static let shared = BridgeCoordinator()
    
    // MARK: - Properties
    
    private var flutterBridge: FlutterBridge?
    private var hybridBridge: HybridBridge?
    
    // MARK: - Initialization
    
    private init() {
        setupBridges()
    }
    
    // MARK: - Setup
    
    private func setupBridges() {
        // 初始化Flutter Bridge
        if let flutterEngine = DependencyContainer.shared.resolve(FlutterEngineManager.self)?.getEngine(forKey: "main") {
            flutterBridge = FlutterBridge(engine: flutterEngine)
        }
        
        // 初始化Hybrid Bridge
        hybridBridge = HybridBridge()
    }
    
    // MARK: - Flutter Communication
    
    /// 调用Flutter方法
    func callFlutterMethod(_ method: String, arguments: [String: Any]? = nil, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let bridge = flutterBridge else {
            completion(.failure(BridgeError.bridgeNotAvailable("Flutter")))
            return
        }
        
        bridge.callMethod(method, arguments: arguments, completion: completion)
    }
    
    /// 监听Flutter事件
    func listenToFlutterEvents(channel: String, handler: @escaping (Any?) -> Void) {
        flutterBridge?.listenToEvents(channel: channel, handler: handler)
    }
    
    // MARK: - Hybrid Communication
    
    /// 调用混合开发方法
    func callHybridMethod(_ method: String, arguments: [String: Any]? = nil, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let bridge = hybridBridge else {
            completion(.failure(BridgeError.bridgeNotAvailable("Hybrid")))
            return
        }
        
        bridge.callMethod(method, arguments: arguments, completion: completion)
    }
    
    /// 监听混合开发事件
    func listenToHybridEvents(eventName: String, handler: @escaping (Any?) -> Void) {
        hybridBridge?.listenToEvents(eventName: eventName, handler: handler)
    }
    
    // MARK: - Data Sharing
    
    /// 在技术栈间共享数据
    func shareData(_ data: [String: Any], from source: TechStack, to target: TechStack, completion: @escaping (Result<Void, Error>) -> Void) {
        // 通过原生作为中介传递数据
        switch target {
        case .native:
            // 原生直接处理
            completion(.success(()))
            
        case .flutter:
            callFlutterMethod("receiveSharedData", arguments: ["data": data, "source": source.rawValue]) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        case .hybrid:
            callHybridMethod("receiveSharedData", arguments: ["data": data, "source": source.rawValue]) { result in
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Bridge Status
    
    /// 检查Bridge可用性
    func isBridgeAvailable(for techStack: TechStack) -> Bool {
        switch techStack {
        case .native:
            return true
        case .flutter:
            return flutterBridge != nil
        case .hybrid:
            return hybridBridge != nil
        }
    }
    
    /// 获取Bridge状态信息
    func getBridgeStatus() -> [String: Bool] {
        return [
            "native": true,
            "flutter": flutterBridge != nil,
            "hybrid": hybridBridge != nil
        ]
    }
}

// MARK: - Supporting Types

/// 技术栈枚举
enum TechStack: String, CaseIterable {
    case native = "native"
    case flutter = "flutter"
    case hybrid = "hybrid"
}

/// Bridge错误类型
enum BridgeError: Error, LocalizedError {
    case bridgeNotAvailable(String)
    case methodCallFailed(String)
    case invalidArguments
    case communicationTimeout
    
    var errorDescription: String? {
        switch self {
        case .bridgeNotAvailable(let bridge):
            return "\(bridge) Bridge不可用"
        case .methodCallFailed(let method):
            return "方法调用失败: \(method)"
        case .invalidArguments:
            return "无效的参数"
        case .communicationTimeout:
            return "通信超时"
        }
    }
}
