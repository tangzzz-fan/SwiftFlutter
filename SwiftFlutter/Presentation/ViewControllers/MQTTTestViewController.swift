//
//  MQTTTestViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Anchorage
import UIKit

/// MQTT测试视图控制器
class MQTTTestViewController: UIViewController {
    // MARK: - Properties
    
    private var isConnected = false
    private let defaultHost = "broker.hivemq.com"
    private let defaultPort: UInt16 = 1883
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var connectionSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var hostTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "MQTT Broker地址"
        textField.text = defaultHost
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var portTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "端口"
        textField.text = "\(defaultPort)"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private lazy var clientIdTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "客户端ID (可选)"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("连接", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        button.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var connectionStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "未连接"
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // 订阅部分
    private lazy var subscribeSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var subscribeTopicTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "订阅主题 (如: test/topic)"
        textField.text = "test/topic"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("订阅", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // 发布部分
    private lazy var publishSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var publishTopicTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "发布主题 (如: test/topic)"
        textField.text = "test/topic"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var publishMessageTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Hello from iOS MQTT client!"
        return textView
    }()
    
    private lazy var publishButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("发布消息", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(publishButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // 消息显示部分
    private lazy var messagesSection: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var messagesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "接收到的消息"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var clearMessagesButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("清空", for: .normal)
        button.addTarget(self, action: #selector(clearMessagesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var messagesTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 8
        textView.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isEditable = false
        textView.text = "等待接收消息...\n"
        return textView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMQTT()
        
        // 生成默认客户端ID
        clientIdTextField.text = "iOS_Client_\(UUID().uuidString.prefix(8))"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isConnected {
            MQTTManager.shared.disconnect()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "MQTT测试"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加所有section
        contentView.addSubview(connectionSection)
        contentView.addSubview(subscribeSection)
        contentView.addSubview(publishSection)
        contentView.addSubview(messagesSection)
        
        setupConnectionSection()
        setupSubscribeSection()
        setupPublishSection()
        setupMessagesSection()
        setupConstraints()
    }
    
    private func setupConnectionSection() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "连接设置"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        connectionSection.addSubview(titleLabel)
        connectionSection.addSubview(hostTextField)
        connectionSection.addSubview(portTextField)
        connectionSection.addSubview(clientIdTextField)
        connectionSection.addSubview(connectButton)
        connectionSection.addSubview(connectionStatusLabel)
        
        // 使用 Anchorage 设置约束
        titleLabel.topAnchor == connectionSection.topAnchor + 16
        titleLabel.leadingAnchor == connectionSection.leadingAnchor + 16
        titleLabel.trailingAnchor == connectionSection.trailingAnchor - 16
        
        hostTextField.topAnchor == titleLabel.bottomAnchor + 16
        hostTextField.leadingAnchor == connectionSection.leadingAnchor + 16
        hostTextField.trailingAnchor == connectionSection.trailingAnchor - 16
        
        portTextField.topAnchor == hostTextField.bottomAnchor + 12
        portTextField.leadingAnchor == connectionSection.leadingAnchor + 16
        portTextField.widthAnchor == 120
        
        clientIdTextField.topAnchor == portTextField.bottomAnchor + 12
        clientIdTextField.leadingAnchor == connectionSection.leadingAnchor + 16
        clientIdTextField.trailingAnchor == connectionSection.trailingAnchor - 16
        
        connectButton.topAnchor == clientIdTextField.bottomAnchor + 16
        connectButton.centerXAnchor == connectionSection.centerXAnchor
        
        connectionStatusLabel.topAnchor == connectButton.bottomAnchor + 12
        connectionStatusLabel.leadingAnchor == connectionSection.leadingAnchor + 16
        connectionStatusLabel.trailingAnchor == connectionSection.trailingAnchor - 16
        connectionStatusLabel.bottomAnchor == connectionSection.bottomAnchor - 16
    }
    
    private func setupSubscribeSection() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "订阅主题"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        subscribeSection.addSubview(titleLabel)
        subscribeSection.addSubview(subscribeTopicTextField)
        subscribeSection.addSubview(subscribeButton)
        
        // 使用 Anchorage 设置约束
        titleLabel.topAnchor == subscribeSection.topAnchor + 16
        titleLabel.leadingAnchor == subscribeSection.leadingAnchor + 16
        titleLabel.trailingAnchor == subscribeSection.trailingAnchor - 16
        
        subscribeTopicTextField.topAnchor == titleLabel.bottomAnchor + 16
        subscribeTopicTextField.leadingAnchor == subscribeSection.leadingAnchor + 16
        subscribeTopicTextField.trailingAnchor == subscribeButton.leadingAnchor - 12
        
        subscribeButton.topAnchor == titleLabel.bottomAnchor + 16
        subscribeButton.trailingAnchor == subscribeSection.trailingAnchor - 16
        subscribeButton.widthAnchor == 80
        
        subscribeButton.bottomAnchor == subscribeSection.bottomAnchor - 16
    }
    
    private func setupPublishSection() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "发布消息"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        publishSection.addSubview(titleLabel)
        publishSection.addSubview(publishTopicTextField)
        publishSection.addSubview(publishMessageTextView)
        publishSection.addSubview(publishButton)
        
        // 使用 Anchorage 设置约束
        titleLabel.topAnchor == publishSection.topAnchor + 16
        titleLabel.leadingAnchor == publishSection.leadingAnchor + 16
        titleLabel.trailingAnchor == publishSection.trailingAnchor - 16
        
        publishTopicTextField.topAnchor == titleLabel.bottomAnchor + 16
        publishTopicTextField.leadingAnchor == publishSection.leadingAnchor + 16
        publishTopicTextField.trailingAnchor == publishSection.trailingAnchor - 16
        
        publishMessageTextView.topAnchor == publishTopicTextField.bottomAnchor + 12
        publishMessageTextView.leadingAnchor == publishSection.leadingAnchor + 16
        publishMessageTextView.trailingAnchor == publishSection.trailingAnchor - 16
        publishMessageTextView.heightAnchor == 80
        
        publishButton.topAnchor == publishMessageTextView.bottomAnchor + 16
        publishButton.centerXAnchor == publishSection.centerXAnchor
        publishButton.bottomAnchor == publishSection.bottomAnchor - 16
    }
    
    private func setupMessagesSection() {
        messagesSection.addSubview(messagesLabel)
        messagesSection.addSubview(clearMessagesButton)
        messagesSection.addSubview(messagesTextView)
        
        // 使用 Anchorage 设置约束
        messagesLabel.topAnchor == messagesSection.topAnchor + 16
        messagesLabel.leadingAnchor == messagesSection.leadingAnchor + 16
        
        clearMessagesButton.centerYAnchor == messagesLabel.centerYAnchor
        clearMessagesButton.trailingAnchor == messagesSection.trailingAnchor - 16
        
        messagesTextView.topAnchor == messagesLabel.bottomAnchor + 12
        messagesTextView.leadingAnchor == messagesSection.leadingAnchor + 16
        messagesTextView.trailingAnchor == messagesSection.trailingAnchor - 16
        messagesTextView.heightAnchor == 200
        messagesTextView.bottomAnchor == messagesSection.bottomAnchor - 16
    }
    
    private func setupConstraints() {
        // 使用 Anchorage 设置约束
        scrollView.topAnchor == view.safeAreaLayoutGuide.topAnchor
        scrollView.leadingAnchor == view.leadingAnchor
        scrollView.trailingAnchor == view.trailingAnchor
        scrollView.bottomAnchor == view.bottomAnchor
        
        contentView.topAnchor == scrollView.topAnchor
        contentView.leadingAnchor == scrollView.leadingAnchor
        contentView.trailingAnchor == scrollView.trailingAnchor
        contentView.bottomAnchor == scrollView.bottomAnchor
        contentView.widthAnchor == scrollView.widthAnchor
        
        connectionSection.topAnchor == contentView.topAnchor + 16
        connectionSection.leadingAnchor == contentView.leadingAnchor + 16
        connectionSection.trailingAnchor == contentView.trailingAnchor - 16
        
        subscribeSection.topAnchor == connectionSection.bottomAnchor + 16
        subscribeSection.leadingAnchor == contentView.leadingAnchor + 16
        subscribeSection.trailingAnchor == contentView.trailingAnchor - 16
        
        publishSection.topAnchor == subscribeSection.bottomAnchor + 16
        publishSection.leadingAnchor == contentView.leadingAnchor + 16
        publishSection.trailingAnchor == contentView.trailingAnchor - 16
        
        messagesSection.topAnchor == publishSection.bottomAnchor + 16
        messagesSection.leadingAnchor == contentView.leadingAnchor + 16
        messagesSection.trailingAnchor == contentView.trailingAnchor - 16
        messagesSection.bottomAnchor == contentView.bottomAnchor - 16
    }
    
    private func setupMQTT() {
        // 设置MQTT连接状态回调
        MQTTManager.shared.setConnectionStatusCallback { [weak self] status in
            DispatchQueue.main.async {
                self?.handleConnectionStatus(status)
            }
        }
        
        // 设置MQTT消息接收回调
        MQTTManager.shared.setMessageCallback { [weak self] topic, message in
            DispatchQueue.main.async {
                self?.handleReceivedMessage(topic: topic, message: message)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func connectButtonTapped() {
        if isConnected {
            // 断开连接
            MQTTManager.shared.disconnect()
        } else {
            // 建立连接
            guard let host = hostTextField.text, !host.isEmpty,
                  let portText = portTextField.text, !portText.isEmpty,
                  let port = UInt16(portText) else {
                appendMessage("错误: 请填写有效的主机地址和端口")
                return
            }
            
            let clientId = clientIdTextField.text?.isEmpty == false ? clientIdTextField.text! : "iOS_Client_\(UUID().uuidString.prefix(8))"
            
            appendMessage("正在连接到 \(host):\(port)...")
            MQTTManager.shared.connect(host: host, port: port, clientID: clientId)
        }
    }
    
    @objc private func subscribeButtonTapped() {
        guard isConnected else {
            appendMessage("错误: 请先连接MQTT服务器")
            return
        }
        
        guard let topic = subscribeTopicTextField.text, !topic.isEmpty else {
            appendMessage("错误: 请输入订阅主题")
            return
        }
        
        MQTTManager.shared.subscribe(topic: topic, qos: 1)
        appendMessage("已订阅主题: \(topic)")
    }
    
    @objc private func publishButtonTapped() {
        guard isConnected else {
            appendMessage("错误: 请先连接MQTT服务器")
            return
        }
        
        guard let topic = publishTopicTextField.text, !topic.isEmpty else {
            appendMessage("错误: 请输入发布主题")
            return
        }
        
        let message = publishMessageTextView.text ?? ""
        MQTTManager.shared.publish(topic: topic, message: message, qos: 1)
        appendMessage("已发布消息到 \(topic): \(message)")
    }
    
    @objc private func clearMessagesButtonTapped() {
        messagesTextView.text = ""
    }
    
    // MARK: - Helper Methods
    
    private func handleConnectionStatus(_ status: String) {
        switch status {
        case "connected":
            isConnected = true
            connectionStatusLabel.text = "已连接"
            connectionStatusLabel.textColor = .systemGreen
            connectButton.setTitle("断开连接", for: .normal)
            connectButton.backgroundColor = .systemRed
            subscribeButton.isEnabled = true
            publishButton.isEnabled = true
            appendMessage("✅ MQTT连接成功")
            
        case "disconnected":
            isConnected = false
            connectionStatusLabel.text = "已断开"
            connectionStatusLabel.textColor = .systemRed
            connectButton.setTitle("连接", for: .normal)
            connectButton.backgroundColor = .systemBlue
            subscribeButton.isEnabled = false
            publishButton.isEnabled = false
            appendMessage("❌ MQTT连接已断开")
            
        case "connection_failed":
            isConnected = false
            connectionStatusLabel.text = "连接失败"
            connectionStatusLabel.textColor = .systemRed
            connectButton.setTitle("连接", for: .normal)
            connectButton.backgroundColor = .systemBlue
            subscribeButton.isEnabled = false
            publishButton.isEnabled = false
            appendMessage("❌ MQTT连接失败")
            
        default:
            connectionStatusLabel.text = status
            connectionStatusLabel.textColor = .systemOrange
            appendMessage("MQTT状态: \(status)")
        }
    }
    
    private func handleReceivedMessage(topic: String, message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        appendMessage("📨 [\(timestamp)] 主题: \(topic)\n    消息: \(message)")
    }
    
    private func appendMessage(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let formattedMessage = "[\(timestamp)] \(message)\n"
        messagesTextView.text += formattedMessage
        
        // 滚动到底部
        let bottom = NSMakeRange(messagesTextView.text.count - 1, 1)
        messagesTextView.scrollRangeToVisible(bottom)
    }
}
