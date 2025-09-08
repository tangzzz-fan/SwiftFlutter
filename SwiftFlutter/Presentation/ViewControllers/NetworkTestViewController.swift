//
//  NetworkTestViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Anchorage
import UIKit
import Combine

class NetworkTestViewController: UIViewController {

    private let apiClient = APIClient.shared
    private var cancellables = Set<AnyCancellable>()

    // UI元素
    private let stackView = UIStackView()
    private let loginButton = UIButton(type: .system)
    private let getDevicesButton = UIButton(type: .system)
    private let connectWebSocketButton = UIButton(type: .system)
    private let connectMQTTButton = UIButton(type: .system)
    private let resultTextView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // 配置StackView
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .fill

        // 配置按钮
        loginButton.setTitle("测试登录API", for: .normal)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        loginButton.backgroundColor = .systemBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 8
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        getDevicesButton.setTitle("测试获取设备列表", for: .normal)
        getDevicesButton.addTarget(self, action: #selector(getDevicesTapped), for: .touchUpInside)
        getDevicesButton.backgroundColor = .systemGreen
        getDevicesButton.setTitleColor(.white, for: .normal)
        getDevicesButton.layer.cornerRadius = 8
        getDevicesButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        connectWebSocketButton.setTitle("测试WebSocket连接", for: .normal)
        connectWebSocketButton.addTarget(
            self, action: #selector(connectWebSocketTapped), for: .touchUpInside)
        connectWebSocketButton.backgroundColor = .systemOrange
        connectWebSocketButton.setTitleColor(.white, for: .normal)
        connectWebSocketButton.layer.cornerRadius = 8
        connectWebSocketButton.contentEdgeInsets = UIEdgeInsets(
            top: 10, left: 20, bottom: 10, right: 20)

        connectMQTTButton.setTitle("测试MQTT连接", for: .normal)
        connectMQTTButton.addTarget(self, action: #selector(connectMQTTTapped), for: .touchUpInside)
        connectMQTTButton.backgroundColor = .systemPurple
        connectMQTTButton.setTitleColor(.white, for: .normal)
        connectMQTTButton.layer.cornerRadius = 8
        connectMQTTButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        // 配置结果文本视图
        resultTextView.isEditable = false
        resultTextView.backgroundColor = .systemGray6
        resultTextView.layer.cornerRadius = 8
        resultTextView.font = UIFont.systemFont(ofSize: 14)

        // 添加子视图
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(getDevicesButton)
        stackView.addArrangedSubview(connectWebSocketButton)
        stackView.addArrangedSubview(connectMQTTButton)
        stackView.addArrangedSubview(resultTextView)

        view.addSubview(stackView)

        // 使用Anchorage设置约束
        stackView.centerXAnchor == view.centerXAnchor
        stackView.topAnchor == view.safeAreaLayoutGuide.topAnchor + 50
        stackView.leadingAnchor >= view.leadingAnchor + 20
        stackView.trailingAnchor <= view.trailingAnchor - 20

        loginButton.widthAnchor == 200
        getDevicesButton.widthAnchor == 200
        connectWebSocketButton.widthAnchor == 200
        connectMQTTButton.widthAnchor == 200

        resultTextView.heightAnchor == 300
        resultTextView.leadingAnchor == view.leadingAnchor + 20
        resultTextView.trailingAnchor == view.trailingAnchor - 20
        resultTextView.bottomAnchor <= view.safeAreaLayoutGuide.bottomAnchor - 20
    }

    @objc private func loginTapped() {
        appendToResult("开始测试登录API...")

        // 先清空之前的token
        AuthManager.shared.clearTokens()

        // 使用新的APIClient进行登录
        apiClient.loginAndSaveToken(email: "user@example.com", password: "password123")
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.appendToResult("Token已保存")
                    case .failure(let error):
                        self?.appendToResult("登录失败: \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] user in
                    self?.appendToResult("登录成功: \(user.name)")
                }
            )
            .store(in: &cancellables)
    }

    @objc private func getDevicesTapped() {
        appendToResult("开始测试获取设备列表...")

        // 检查是否有token并输出调试信息
        if let token = AuthManager.shared.currentAuthToken {
            appendToResult("✓ 找到认证token (长度: \(token.count))")
            appendToResult("Token内容: \(token)")
        } else {
            appendToResult("✗ 错误: 请先登录以获取认证token")
            return
        }

        // 使用新的APIClient获取设备列表
        apiClient.getDevices()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        if case APIError.unauthorized = error {
                            self?.appendToResult("认证失败: 请重新登录")
                            // 通知用户需要重新登录
                            NotificationCenter.default.post(
                                name: NSNotification.Name("UserNeedsRelogin"), object: nil)
                        } else {
                            self?.appendToResult("获取设备列表失败: \(error.localizedDescription)")
                        }
                    }
                },
                receiveValue: { [weak self] devices in
                    self?.appendToResult("获取设备列表成功，共 \(devices.count) 个设备:")
                    for device in devices {
                        self?.appendToResult("- \(device.name) (\(device.type))")
                    }
                }
            )
            .store(in: &cancellables)
    }

    @objc private func connectWebSocketTapped() {
        appendToResult("开始测试WebSocket连接...")

        // 检查是否有token
        guard let token = AuthManager.shared.currentAuthToken else {
            appendToResult("错误: 请先登录以获取认证token")
            return
        }

        // 设置连接状态回调
        WebSocketManager.shared.setConnectionStatusCallback { [weak self] status in
            DispatchQueue.main.async {
                self?.appendToResult("WebSocket连接状态: \(status)")
            }
        }

        // 设置消息接收回调
        WebSocketManager.shared.setMessageCallback { [weak self] message in
            DispatchQueue.main.async {
                self?.appendToResult("WebSocket收到消息: \(message)")
            }
        }

        // 使用认证令牌连接WebSocket
        WebSocketManager.shared.connectWithToken(token: token)

        // 延迟发送测试消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            WebSocketManager.shared.send(message: "Hello from iOS client!")
        }

        appendToResult("已发起WebSocket连接请求")
    }

    @objc private func connectMQTTTapped() {
        appendToResult("开始测试MQTT连接...")

        // 设置MQTT连接状态回调
        MQTTManager.shared.setConnectionStatusCallback { [weak self] status in
            DispatchQueue.main.async {
                self?.appendToResult("MQTT连接状态: \(status)")
            }
        }

        // 设置MQTT消息接收回调
        MQTTManager.shared.setMessageCallback { [weak self] topic, message in
            DispatchQueue.main.async {
                self?.appendToResult("MQTT收到消息 - 主题: \(topic), 内容: \(message)")
            }
        }

        // 连接到MQTT服务器 (broker.emqx.io:8084)
        MQTTManager.shared.connect(
            host: "broker.emqx.io", port: 8084, clientID: "iOS_Client_\(UUID().uuidString)")

        // 延迟订阅主题和发送消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // 修复：添加缺失的qos参数
            MQTTManager.shared.subscribe(topic: "test/topic", qos: 1)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                MQTTManager.shared.publish(
                    topic: "test/topic", message: "Hello from iOS MQTT client!", qos: 1)
            }
        }

        appendToResult("已发起MQTT连接请求")
    }

    private func appendToResult(_ text: String) {
        let formattedText = "[\(Date())] \(text)\n"
        resultTextView.text += formattedText
        print(formattedText)

        // 滚动到底部
        let bottom = NSMakeRange(resultTextView.text.count - 1, 1)
        resultTextView.scrollRangeToVisible(bottom)
    }
}
