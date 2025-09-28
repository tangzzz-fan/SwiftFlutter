//
//  WebSocketTestViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Anchorage
import UIKit

/// WebSocket测试视图控制器
class WebSocketTestViewController: UIViewController {
    // MARK: - Properties
    
    private var isConnected = false
    private let defaultURL = "ws://localhost:3002"
    
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
    
    private lazy var urlTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "WebSocket服务器地址"
        textField.text = defaultURL
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    
    private lazy var authToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = true
        toggle.addTarget(self, action: #selector(authToggleChanged), for: .valueChanged)
        return toggle
    }()
    
    private lazy var authLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "使用认证Token"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
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
    
    // 发送消息部分
    private lazy var sendSection: UIView = {
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
    
    private lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.text = "Hello from iOS WebSocket client!"
        return textView
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("发送消息", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var quickSendStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var pingButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Ping", for: .normal)
        button.backgroundColor = .systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(pingButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var heartbeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("心跳", for: .normal)
        button.backgroundColor = .systemTeal
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(heartbeatButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var testDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("测试数据", for: .normal)
        button.backgroundColor = .systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(testDataButtonTapped), for: .touchUpInside)
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
        label.text = "消息记录"
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
        textView.text = "等待连接...\n"
        return textView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isConnected {
            WebSocketManager.shared.disconnect()
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "WebSocket测试"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 添加所有section
        contentView.addSubview(connectionSection)
        contentView.addSubview(sendSection)
        contentView.addSubview(messagesSection)
        
        setupConnectionSection()
        setupSendSection()
        setupMessagesSection()
        setupConstraints()
    }
    
    private func setupConnectionSection() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "连接设置"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        connectionSection.addSubview(titleLabel)
        connectionSection.addSubview(urlTextField)
        connectionSection.addSubview(authLabel)
        connectionSection.addSubview(authToggle)
        connectionSection.addSubview(connectButton)
        connectionSection.addSubview(connectionStatusLabel)
        
        // 使用 Anchorage 设置约束
        titleLabel.topAnchor == connectionSection.topAnchor + 16
        titleLabel.leadingAnchor == connectionSection.leadingAnchor + 16
        titleLabel.trailingAnchor == connectionSection.trailingAnchor - 16
        
        urlTextField.topAnchor == titleLabel.bottomAnchor + 16
        urlTextField.leadingAnchor == connectionSection.leadingAnchor + 16
        urlTextField.trailingAnchor == connectionSection.trailingAnchor - 16
        
        authLabel.topAnchor == urlTextField.bottomAnchor + 16
        authLabel.leadingAnchor == connectionSection.leadingAnchor + 16
        
        authToggle.centerYAnchor == authLabel.centerYAnchor
        authToggle.trailingAnchor == connectionSection.trailingAnchor - 16
        
        connectButton.topAnchor == authLabel.bottomAnchor + 20
        connectButton.centerXAnchor == connectionSection.centerXAnchor
        
        connectionStatusLabel.topAnchor == connectButton.bottomAnchor + 12
        connectionStatusLabel.leadingAnchor == connectionSection.leadingAnchor + 16
        connectionStatusLabel.trailingAnchor == connectionSection.trailingAnchor - 16
        connectionStatusLabel.bottomAnchor == connectionSection.bottomAnchor - 16
    }
    
    private func setupSendSection() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "发送消息"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        quickSendStackView.addArrangedSubview(pingButton)
        quickSendStackView.addArrangedSubview(heartbeatButton)
        quickSendStackView.addArrangedSubview(testDataButton)
        
        sendSection.addSubview(titleLabel)
        sendSection.addSubview(messageTextView)
        sendSection.addSubview(sendButton)
        sendSection.addSubview(quickSendStackView)
        
        // 使用 Anchorage 设置约束
        titleLabel.topAnchor == sendSection.topAnchor + 16
        titleLabel.leadingAnchor == sendSection.leadingAnchor + 16
        titleLabel.trailingAnchor == sendSection.trailingAnchor - 16
        
        messageTextView.topAnchor == titleLabel.bottomAnchor + 16
        messageTextView.leadingAnchor == sendSection.leadingAnchor + 16
        messageTextView.trailingAnchor == sendSection.trailingAnchor - 16
        messageTextView.heightAnchor == 80
        
        sendButton.topAnchor == messageTextView.bottomAnchor + 16
        sendButton.centerXAnchor == sendSection.centerXAnchor
        
        quickSendStackView.topAnchor == sendButton.bottomAnchor + 16
        quickSendStackView.leadingAnchor == sendSection.leadingAnchor + 16
        quickSendStackView.trailingAnchor == sendSection.trailingAnchor - 16
        quickSendStackView.heightAnchor == 32
        quickSendStackView.bottomAnchor == sendSection.bottomAnchor - 16
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
        
        sendSection.topAnchor == connectionSection.bottomAnchor + 16
        sendSection.leadingAnchor == contentView.leadingAnchor + 16
        sendSection.trailingAnchor == contentView.trailingAnchor - 16
        
        messagesSection.topAnchor == sendSection.bottomAnchor + 16
        messagesSection.leadingAnchor == contentView.leadingAnchor + 16
        messagesSection.trailingAnchor == contentView.trailingAnchor - 16
        messagesSection.bottomAnchor == contentView.bottomAnchor - 16
    }
    
    private func setupWebSocket() {
        // 设置WebSocket连接状态回调
        WebSocketManager.shared.setConnectionStatusCallback { [weak self] status in
            DispatchQueue.main.async {
                self?.handleConnectionStatus(status)
            }
        }
        
        // 设置WebSocket消息接收回调
        WebSocketManager.shared.setMessageCallback { [weak self] message in
            DispatchQueue.main.async {
                self?.handleReceivedMessage(message)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func connectButtonTapped() {
        if isConnected {
            // 断开连接
            WebSocketManager.shared.disconnect()
        } else {
            // 建立连接
            guard let urlString = urlTextField.text, !urlString.isEmpty,
                  let url = URL(string: urlString) else {
                appendMessage("错误: 请填写有效的WebSocket服务器地址")
                return
            }
            
            appendMessage("正在连接到 \(urlString)...")
            
            if authToggle.isOn {
                // 使用认证token连接
                guard let token = AuthManager.shared.currentAuthToken else {
                    appendMessage("错误: 请先登录以获取认证token")
                    return
                }
                WebSocketManager.shared.connectWithToken(token: token)
            } else {
                // 直接连接
                WebSocketManager.shared.connect(url: url, headers: nil)
            }
        }
    }
    
    @objc private func authToggleChanged() {
        // 认证开关状态改变时的处理
        if authToggle.isOn {
            appendMessage("已启用认证模式")
        } else {
            appendMessage("已禁用认证模式")
        }
    }
    
    @objc private func sendButtonTapped() {
        guard isConnected else {
            appendMessage("错误: 请先连接WebSocket服务器")
            return
        }
        
        let message = messageTextView.text ?? ""
        guard !message.isEmpty else {
            appendMessage("错误: 消息不能为空")
            return
        }
        
        WebSocketManager.shared.send(message: message)
        appendMessage("📤 发送: \(message)")
    }
    
    @objc private func pingButtonTapped() {
        guard isConnected else { return }
        let message = "ping"
        WebSocketManager.shared.send(message: message)
        appendMessage("📤 发送: \(message)")
    }
    
    @objc private func heartbeatButtonTapped() {
        guard isConnected else { return }
        let heartbeat: [String: Any] = ["type": "heartbeat", "timestamp": Date().timeIntervalSince1970]
        if let jsonData = try? JSONSerialization.data(withJSONObject: heartbeat),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            WebSocketManager.shared.send(message: jsonString)
            appendMessage("📤 发送心跳: \(jsonString)")
        }
    }
    
    @objc private func testDataButtonTapped() {
        guard isConnected else { return }
        let testData = [
            "type": "test",
            "data": ["temperature": 25.5, "humidity": 60, "timestamp": Date().timeIntervalSince1970]
        ] as [String : Any]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: testData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            WebSocketManager.shared.send(message: jsonString)
            appendMessage("📤 发送测试数据: \(jsonString)")
        }
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
            sendButton.isEnabled = true
            pingButton.isEnabled = true
            heartbeatButton.isEnabled = true
            testDataButton.isEnabled = true
            appendMessage("✅ WebSocket连接成功")
            
        case "disconnected":
            isConnected = false
            connectionStatusLabel.text = "已断开"
            connectionStatusLabel.textColor = .systemRed
            connectButton.setTitle("连接", for: .normal)
            connectButton.backgroundColor = .systemBlue
            sendButton.isEnabled = false
            pingButton.isEnabled = false
            heartbeatButton.isEnabled = false
            testDataButton.isEnabled = false
            appendMessage("❌ WebSocket连接已断开")
            
        case "cancelled":
            isConnected = false
            connectionStatusLabel.text = "已取消"
            connectionStatusLabel.textColor = .systemRed
            connectButton.setTitle("连接", for: .normal)
            connectButton.backgroundColor = .systemBlue
            sendButton.isEnabled = false
            pingButton.isEnabled = false
            heartbeatButton.isEnabled = false
            testDataButton.isEnabled = false
            appendMessage("❌ WebSocket连接已取消")
            
        case "error":
            isConnected = false
            connectionStatusLabel.text = "连接错误"
            connectionStatusLabel.textColor = .systemRed
            connectButton.setTitle("连接", for: .normal)
            connectButton.backgroundColor = .systemBlue
            sendButton.isEnabled = false
            pingButton.isEnabled = false
            heartbeatButton.isEnabled = false
            testDataButton.isEnabled = false
            appendMessage("❌ WebSocket连接错误")
            
        default:
            connectionStatusLabel.text = status
            connectionStatusLabel.textColor = .systemOrange
            appendMessage("WebSocket状态: \(status)")
        }
    }
    
    private func handleReceivedMessage(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        appendMessage("📨 [\(timestamp)] 接收: \(message)")
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
