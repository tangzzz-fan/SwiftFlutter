//
//  FlutterBridge.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import Foundation

class FlutterBridge: NSObject, FlutterStreamHandler {
    private let channel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    private var eventSink: FlutterEventSink?

    init(engine: FlutterEngine) {
        channel = FlutterMethodChannel(
            name: "com.example.flutterbridge/native",
            binaryMessenger: engine.binaryMessenger
        )

        eventChannel = FlutterEventChannel(
            name: "com.example.flutterbridge/events",
            binaryMessenger: engine.binaryMessenger
        )

        super.init()

        setupMethodChannel()
        setupEventChannel()
    }

    private func setupMethodChannel() {
        channel.setMethodCallHandler { [weak self] (call, result) in
            self?.handleMethodCall(call, result: result)
        }
    }

    private func setupEventChannel() {
        eventChannel.setStreamHandler(self)
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getAuthToken":
            handleGetAuthToken(result: result)
        case "sendComplexData":
            handleSendComplexData(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleGetAuthToken(result: @escaping FlutterResult) {
        // 模拟从Keychain获取authToken
        let authToken = "sample_auth_token_12345"
        result(authToken)
    }

    private func handleSendComplexData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
            let data = args["data"] as? [String: Any]
        else {
            result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
            return
        }

        // 处理复杂数据
        print("Received complex data from Flutter: \(data)")
        result(["status": "success", "message": "Data received"])
    }

    // MARK: - FlutterStreamHandler

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

    /// 发送事件到Flutter
    func sendEvent(_ event: [String: Any]) {
        DispatchQueue.main.async {
            self.eventSink?(event)
        }
    }
}
