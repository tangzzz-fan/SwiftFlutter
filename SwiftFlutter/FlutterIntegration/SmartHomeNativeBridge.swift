//
//  SmartHomeNativeBridge.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import Foundation

// MARK: - 协议定义
protocol MQTTManagerProtocol {
    func connect(host: String, port: UInt16, clientID: String)
    func disconnect()
    func subscribe(topic: String, qos: Int)
    func unsubscribe(topic: String)
    func publish(topic: String, message: String, qos: Int)
    func setConnectionStatusCallback(_ callback: @escaping (String) -> Void)
    func setMessageCallback(_ callback: @escaping (String, String) -> Void)
}

protocol WebSocketManagerProtocol {
    func connect(url: URL, headers: [String: String]?)
    func disconnect()
    func send(message: String)
    func setConnectionStatusCallback(_ callback: @escaping (String) -> Void)
    func setMessageCallback(_ callback: @escaping (String) -> Void)
}

protocol AuthManagerProtocol {
    var currentAuthToken: String? { get }
    func saveTokens(authToken: String, refreshToken: String)
    func clearTokens()
}

/// 智能家居原生桥接接口，作为所有MethodChannel和EventChannel的统一入口
class SmartHomeNativeBridge: NSObject {
    static let shared = SmartHomeNativeBridge()

    private var flutterBridge: FlutterBridge?
    private var highFrequencyDataStreamHandler: HighFrequencyDataStreamHandler?

    // 依赖注入各种Manager
    private let mqttManager: MQTTManagerProtocol
    private let webSocketManager: WebSocketManagerProtocol
    private let authManager: AuthManagerProtocol

    // 默认初始化使用真实实现
    override init() {
        self.mqttManager = MQTTManager.shared
        self.webSocketManager = WebSocketManager.shared
        self.authManager = AuthManager.shared
        super.init()
    }

    // 用于测试的初始化方法
    init(
        mqttManager: MQTTManagerProtocol,
        webSocketManager: WebSocketManagerProtocol,
        authManager: AuthManagerProtocol
    ) {
        self.mqttManager = mqttManager
        self.webSocketManager = webSocketManager
        self.authManager = authManager
        super.init()
    }

    /// 注册所有桥接通道
    /// - Parameter engine: Flutter引擎
    func register(with engine: FlutterEngine) {
        // 初始化FlutterBridge
        flutterBridge = FlutterBridge(engine: engine)

        // 初始化高频数据流处理器
        highFrequencyDataStreamHandler = HighFrequencyDataStreamHandler()

        // 注册高频数据事件通道
        let highFrequencyDataChannel = FlutterEventChannel(
            name: "com.example.smarthome/high_frequency_data",
            binaryMessenger: engine.binaryMessenger
        )
        highFrequencyDataChannel.setStreamHandler(highFrequencyDataStreamHandler)

        // 注册MQTT事件通道
        let mqttEventChannel = FlutterEventChannel(
            name: "com.example.smarthome/mqtt_events",
            binaryMessenger: engine.binaryMessenger
        )
        mqttEventChannel.setStreamHandler(MQTTStreamHandler(mqttManager: mqttManager))

        // 注册WebSocket事件通道
        let webSocketEventChannel = FlutterEventChannel(
            name: "com.example.smarthome/websocket_events",
            binaryMessenger: engine.binaryMessenger
        )
        webSocketEventChannel.setStreamHandler(
            WebSocketStreamHandler(webSocketManager: webSocketManager))
    }
}

// MARK: - Method Call Handling
extension SmartHomeNativeBridge {
    /// 处理来自Flutter的方法调用
    /// - Parameters:
    ///   - call: 方法调用
    ///   - result: 结果回调
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getAuthToken":
            handleGetAuthToken(result: result)
        case "saveTokens":
            handleSaveTokens(call: call, result: result)
        case "clearTokens":
            handleClearTokens(result: result)
        case "connectMQTT":
            handleConnectMQTT(call: call, result: result)
        case "disconnectMQTT":
            handleDisconnectMQTT(result: result)
        case "subscribeMQTT":
            handleSubscribeMQTT(call: call, result: result)
        case "unsubscribeMQTT":
            handleUnsubscribeMQTT(call: call, result: result)
        case "publishMQTT":
            handlePublishMQTT(call: call, result: result)
        case "connectWebSocket":
            handleConnectWebSocket(call: call, result: result)
        case "disconnectWebSocket":
            handleDisconnectWebSocket(result: result)
        case "sendWebSocketMessage":
            handleSendWebSocketMessage(call: call, result: result)
        case "startHighFrequencyData":
            handleStartHighFrequencyData(call: call, result: result)
        case "stopHighFrequencyData":
            handleStopHighFrequencyData(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

// MARK: - 认证相关方法
extension SmartHomeNativeBridge {
    private func handleGetAuthToken(result: @escaping FlutterResult) {
        let authToken = authManager.currentAuthToken
        result(authToken)
    }

    private func handleSaveTokens(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let authToken = args["authToken"] as? String,
            let refreshToken = args["refreshToken"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        authManager.saveTokens(authToken: authToken, refreshToken: refreshToken)
        result(nil)
    }

    private func handleClearTokens(result: @escaping FlutterResult) {
        authManager.clearTokens()
        result(nil)
    }
}

// MARK: - MQTT相关方法
extension SmartHomeNativeBridge {
    private func handleConnectMQTT(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let host = args["host"] as? String,
            let port = args["port"] as? UInt16,
            let clientID = args["clientID"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        mqttManager.connect(host: host, port: port, clientID: clientID)
        result(nil)
    }

    private func handleDisconnectMQTT(result: @escaping FlutterResult) {
        mqttManager.disconnect()
        result(nil)
    }

    private func handleSubscribeMQTT(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let topic = args["topic"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        let qosValue = args["qos"] as? Int ?? 1
        mqttManager.subscribe(topic: topic, qos: qosValue)
        result(nil)
    }

    private func handleUnsubscribeMQTT(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let topic = args["topic"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        mqttManager.unsubscribe(topic: topic)
        result(nil)
    }

    private func handlePublishMQTT(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let topic = args["topic"] as? String,
            let message = args["message"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        let qosValue = args["qos"] as? Int ?? 1
        mqttManager.publish(topic: topic, message: message, qos: qosValue)
        result(nil)
    }
}

// MARK: - WebSocket相关方法
extension SmartHomeNativeBridge {
    private func handleConnectWebSocket(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let urlString = args["url"] as? String,
            let url = URL(string: urlString)
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        let headers = args["headers"] as? [String: String]
        webSocketManager.connect(url: url, headers: headers)
        result(nil)
    }

    private func handleDisconnectWebSocket(result: @escaping FlutterResult) {
        webSocketManager.disconnect()
        result(nil)
    }

    private func handleSendWebSocketMessage(
        call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
            let message = args["message"] as? String
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        webSocketManager.send(message: message)
        result(nil)
    }
}

// MARK: - 高频数据相关方法
extension SmartHomeNativeBridge {
    private func handleStartHighFrequencyData(
        call: FlutterMethodCall, result: @escaping FlutterResult
    ) {
        guard let args = call.arguments as? [String: Any],
            let frequency = args["frequency"] as? Int
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        // 通过FlutterBridge发送事件
        flutterBridge?.sendEvent([
            "type": "high_frequency_data_start",
            "frequency": frequency,
        ])

        result(nil)
    }

    private func handleStopHighFrequencyData(result: @escaping FlutterResult) {
        // 通过FlutterBridge发送事件
        flutterBridge?.sendEvent([
            "type": "high_frequency_data_stop"
        ])

        result(nil)
    }
}

// MARK: - MQTT事件流处理器
class MQTTStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private let mqttManager: MQTTManagerProtocol

    init(mqttManager: MQTTManagerProtocol) {
        self.mqttManager = mqttManager
        super.init()
        setupMQTTCallbacks()
    }

    private func setupMQTTCallbacks() {
        mqttManager.setConnectionStatusCallback { [weak self] status in
            self?.sendEvent(["type": "mqtt_connection_status", "status": status])
        }

        mqttManager.setMessageCallback { [weak self] topic, message in
            self?.sendEvent([
                "type": "mqtt_message",
                "topic": topic,
                "message": message,
            ])
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    private func sendEvent(_ event: [String: Any]) {
        DispatchQueue.main.async {
            self.eventSink?(event)
        }
    }
}

// MARK: - WebSocket事件流处理器
class WebSocketStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private let webSocketManager: WebSocketManagerProtocol

    init(webSocketManager: WebSocketManagerProtocol) {
        self.webSocketManager = webSocketManager
        super.init()
        setupWebSocketCallbacks()
    }

    private func setupWebSocketCallbacks() {
        webSocketManager.setConnectionStatusCallback { [weak self] status in
            self?.sendEvent(["type": "websocket_connection_status", "status": status])
        }

        webSocketManager.setMessageCallback { [weak self] message in
            self?.sendEvent([
                "type": "websocket_message",
                "message": message,
            ])
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    private func sendEvent(_ event: [String: Any]) {
        DispatchQueue.main.async {
            self.eventSink?(event)
        }
    }
}
