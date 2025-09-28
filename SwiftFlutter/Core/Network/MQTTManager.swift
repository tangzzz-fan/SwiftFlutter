//
//  MQTTManager.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import CocoaMQTT
import Foundation

/// MQTT管理器，管理MQTT连接、订阅、发布消息
class MQTTManager: NSObject, MQTTManagerProtocol {
    static let shared = MQTTManager()

    private var mqttClient: CocoaMQTT?
    private var connectionStatusCallback: ((String) -> Void)?
    private var messageCallback: ((String, String) -> Void)?

    override private init() {
        super.init()
    }

    /// 连接到MQTT服务器
    /// - Parameters:
    ///   - host: 主机地址
    ///   - port: 端口号
    ///   - clientID: 客户端ID
    func connect(host: String, port: UInt16, clientID: String) {
        mqttClient = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqttClient?.delegate = self
        _ = mqttClient?.connect()
    }

    /// 断开MQTT连接
    func disconnect() {
        mqttClient?.disconnect()
    }

    /// 订阅主题
    /// - Parameters:
    ///   - topic: 主题
    ///   - qos: 服务质量等级 (0, 1, 2)
    func subscribe(topic: String, qos: Int) {
        // 将Int类型的qos转换为CocoaMQTTQoS
        let mqttQoS: CocoaMQTTQoS
        switch qos {
        case 0:
            mqttQoS = .qos0
        case 1:
            mqttQoS = .qos1
        case 2:
            mqttQoS = .qos2
        default:
            mqttQoS = .qos1
        }
        mqttClient?.subscribe(topic, qos: mqttQoS)
    }

    /// 取消订阅主题
    /// - Parameter topic: 主题
    func unsubscribe(topic: String) {
        mqttClient?.unsubscribe(topic)
    }

    /// 发布消息
    /// - Parameters:
    ///   - topic: 主题
    ///   - message: 消息内容
    ///   - qos: 服务质量等级 (0, 1, 2)
    func publish(topic: String, message: String, qos: Int) {
        // 将Int类型的qos转换为CocoaMQTTQoS
        let mqttQoS: CocoaMQTTQoS
        switch qos {
        case 0:
            mqttQoS = .qos0
        case 1:
            mqttQoS = .qos1
        case 2:
            mqttQoS = .qos2
        default:
            mqttQoS = .qos1
        }
        let mqttMessage = CocoaMQTTMessage(topic: topic, string: message, qos: mqttQoS)
        _ = mqttClient?.publish(mqttMessage)
    }

    /// 设置连接状态回调
    /// - Parameter callback: 回调函数
    func setConnectionStatusCallback(_ callback: @escaping (String) -> Void) {
        connectionStatusCallback = callback
    }

    /// 设置消息接收回调
    /// - Parameter callback: 回调函数
    func setMessageCallback(_ callback: @escaping (String, String) -> Void) {
        messageCallback = callback
    }
}

// MARK: - CocoaMQTTDelegate
extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            connectionStatusCallback?("connected")
        } else {
            connectionStatusCallback?("connection_failed")
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        // 消息发布回调
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        // 发布确认回调
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        messageCallback?(message.topic, message.string ?? "")
    }

    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("Subscribed to topics. Success: \(success), Failed: \(failed)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("Unsubscribed from topics: \(topics)")
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        // 可选实现
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        // 可选实现
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        connectionStatusCallback?("disconnected")
    }

    // 可选方法实现
    func mqtt(
        _ mqtt: CocoaMQTT, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void
    ) {
        // SSL/TLS服务器证书验证
        completionHandler(true)
    }
}
