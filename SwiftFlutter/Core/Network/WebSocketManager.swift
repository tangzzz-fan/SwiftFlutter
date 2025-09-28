//
//  WebSocketManager.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation
import Starscream

/// WebSocket管理器，管理WebSocket连接、发送和接收消息
class WebSocketManager: NSObject, WebSocketManagerProtocol {
    static let shared = WebSocketManager()

    private var webSocket: WebSocket?
    private var connectionStatusCallback: ((String) -> Void)?
    private var messageCallback: ((String) -> Void)?

    override private init() {
        super.init()
    }

    /// 连接到WebSocket服务器
    /// - Parameters:
    ///   - url: 服务器URL
    ///   - headers: 请求头
    func connect(url: URL, headers: [String: String]?) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 5

        // 添加请求头
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }

    /// 使用认证令牌连接到WebSocket服务器
    /// - Parameters:
    ///   - token: JWT认证令牌
    func connectWithToken(token: String) {
        // 连接到原生WebSocket服务器（端口3002）
        guard let url = URL(string: "ws://localhost:3002") else {
            connectionStatusCallback?("error: Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 10

        // 设置认证信息
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }

    /// 断开WebSocket连接
    func disconnect() {
        webSocket?.disconnect()
    }

    /// 发送消息
    /// - Parameter message: 消息内容
    func send(message: String) {
        webSocket?.write(string: message)
    }

    /// 设置连接状态回调
    /// - Parameter callback: 回调函数
    func setConnectionStatusCallback(_ callback: @escaping (String) -> Void) {
        connectionStatusCallback = callback
    }

    /// 设置消息接收回调
    /// - Parameter callback: 回调函数
    func setMessageCallback(_ callback: @escaping (String) -> Void) {
        messageCallback = callback
    }
}

// MARK: - WebSocketDelegate
extension WebSocketManager: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected with headers: \(headers)")
            connectionStatusCallback?("connected")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected with reason: \(reason), code: \(code)")
            connectionStatusCallback?("disconnected")
        case .text(let text):
            messageCallback?(text)
        case .binary(let data):
            if let text = String(data: data, encoding: .utf8) {
                messageCallback?(text)
            }
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(let viable):
            print("WebSocket viability changed: \(viable)")
        case .reconnectSuggested(let suggested):
            print("WebSocket reconnect suggested: \(suggested)")
        case .cancelled:
            connectionStatusCallback?("cancelled")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
            connectionStatusCallback?("error")
        @unknown default:
            break
        }
    }
}
