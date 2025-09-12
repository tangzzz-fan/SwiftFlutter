//
//  FlutterBridge.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import Foundation
import Flutter

/// Flutter Bridge实现
class FlutterBridge {
    // MARK: - Properties
    
    private let engine: FlutterEngine
    private var methodChannels: [String: FlutterMethodChannel] = [:]
    private var eventChannels: [String: FlutterEventChannel] = [:]
    
    // MARK: - Initialization
    
    init(engine: FlutterEngine) {
        self.engine = engine
        setupDefaultChannels()
    }
    
    // MARK: - Setup
    
    private func setupDefaultChannels() {
        // 设置默认的方法通道
        let mainMethodChannel = FlutterMethodChannel(
            name: "com.swiftflutter.main",
            binaryMessenger: engine.binaryMessenger
        )
        methodChannels["main"] = mainMethodChannel
        
        // 设置默认的事件通道
        let mainEventChannel = FlutterEventChannel(
            name: "com.swiftflutter.events",
            binaryMessenger: engine.binaryMessenger
        )
        eventChannels["main"] = mainEventChannel
        
        // 设置方法调用处理
        setupMethodCallHandler()
    }
    
    private func setupMethodCallHandler() {
        guard let methodChannel = methodChannels["main"] else { return }
        
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
    }
    
    // MARK: - Method Calls
    
    /// 调用Flutter方法
    func callMethod(_ method: String, arguments: [String: Any]? = nil, completion: @escaping (Result<Any?, Error>) -> Void) {
        guard let methodChannel = methodChannels["main"] else {
            completion(.failure(BridgeError.bridgeNotAvailable("Flutter Method Channel")))
            return
        }
        
        methodChannel.invokeMethod(method, arguments: arguments) { result in
            if let error = result as? FlutterError {
                completion(.failure(BridgeError.methodCallFailed("\(method): \(error.message ?? "Unknown error")")))
            } else {
                completion(.success(result))
            }
        }
    }
    
    /// 处理来自Flutter的方法调用
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getNativeData":
            handleGetNativeData(arguments: call.arguments, result: result)
            
        case "navigateToNative":
            handleNavigateToNative(arguments: call.arguments, result: result)
            
        case "shareDataToNative":
            handleShareDataToNative(arguments: call.arguments, result: result)
            
        case "requestPermission":
            handleRequestPermission(arguments: call.arguments, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Method Handlers
    
    private func handleGetNativeData(arguments: Any?, result: @escaping FlutterResult) {
        // 获取原生数据
        let nativeData: [String: Any] = [
            "deviceInfo": [
                "model": UIDevice.current.model,
                "systemVersion": UIDevice.current.systemVersion,
                "name": UIDevice.current.name
            ],
            "appInfo": [
                "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown",
                "build": Bundle.main.infoDictionary?["CFBundleVersion"] ?? "Unknown"
            ],
            "timestamp": Date().timeIntervalSince1970
        ]
        
        result(nativeData)
    }
    
    private func handleNavigateToNative(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let route = args["route"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing route parameter", details: nil))
            return
        }
        
        // 通知原生进行导航
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("FlutterNavigationRequest"),
                object: nil,
                userInfo: ["route": route, "arguments": args]
            )
        }
        
        result("Navigation request sent")
    }
    
    private func handleShareDataToNative(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let data = args["data"] as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing data parameter", details: nil))
            return
        }
        
        // 处理数据共享
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("FlutterDataShare"),
                object: nil,
                userInfo: ["data": data, "source": "flutter"]
            )
        }
        
        result("Data shared successfully")
    }
    
    private func handleRequestPermission(arguments: Any?, result: @escaping FlutterResult) {
        guard let args = arguments as? [String: Any],
              let permission = args["permission"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing permission parameter", details: nil))
            return
        }
        
        // 处理权限请求
        handlePermissionRequest(permission: permission) { granted in
            result(["granted": granted])
        }
    }
    
    // MARK: - Event Channels
    
    /// 监听Flutter事件
    func listenToEvents(channel: String, handler: @escaping (Any?) -> Void) {
        let eventChannel = FlutterEventChannel(
            name: "com.swiftflutter.events.\(channel)",
            binaryMessenger: engine.binaryMessenger
        )
        
        let streamHandler = FlutterEventStreamHandler(handler: handler)
        eventChannel.setStreamHandler(streamHandler)
        
        eventChannels[channel] = eventChannel
    }
    
    /// 发送事件到Flutter
    func sendEvent(channel: String, data: Any?) {
        // 通过方法通道发送事件
        callMethod("receiveNativeEvent", arguments: ["channel": channel, "data": data]) { _ in
            // 事件发送完成
        }
    }
    
    // MARK: - Utility Methods
    
    private func handlePermissionRequest(permission: String, completion: @escaping (Bool) -> Void) {
        // 根据权限类型处理不同的权限请求
        switch permission {
        case "camera":
            // 处理相机权限
            completion(true) // 简化处理
        case "location":
            // 处理位置权限
            completion(true) // 简化处理
        case "notification":
            // 处理通知权限
            completion(true) // 简化处理
        default:
            completion(false)
        }
    }
}

// MARK: - Flutter Event Stream Handler

class FlutterEventStreamHandler: NSObject, FlutterStreamHandler {
    private let handler: (Any?) -> Void
    private var eventSink: FlutterEventSink?
    
    init(handler: @escaping (Any?) -> Void) {
        self.handler = handler
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    func sendEvent(_ event: Any?) {
        eventSink?(event)
    }
}