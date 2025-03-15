//
//  ViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import FlutterPluginRegistrant
import UIKit

class ViewController: UIViewController {

    var flutterEngine: FlutterEngine?
    private let channel = "com.example.swiftflutter/channel"
    private var messageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 创建 Flutter 引擎实例
        self.flutterEngine = FlutterEngine(name: "my_flutter_engine")
        self.flutterEngine?.run()
        // 注册所有插件
        GeneratedPluginRegistrant.register(with: self.flutterEngine!)

        // 设置界面
        setupUI()

        // 设置平台通信
        setupMethodChannel()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // 创建标题标签
        let titleLabel = UILabel()
        titleLabel.text = "Swift 与 Flutter 集成示例"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // 创建打开 Flutter 页面的按钮
        let openFlutterButton = UIButton(type: .system)
        openFlutterButton.setTitle("打开 Flutter 页面", for: .normal)
        openFlutterButton.backgroundColor = .systemBlue
        openFlutterButton.setTitleColor(.white, for: .normal)
        openFlutterButton.layer.cornerRadius = 8
        openFlutterButton.addTarget(self, action: #selector(openFlutterPage), for: .touchUpInside)
        openFlutterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(openFlutterButton)

        // 创建发送消息到 Flutter 的按钮
        let sendMessageButton = UIButton(type: .system)
        sendMessageButton.setTitle("发送消息到 Flutter", for: .normal)
        sendMessageButton.backgroundColor = .systemGreen
        sendMessageButton.setTitleColor(.white, for: .normal)
        sendMessageButton.layer.cornerRadius = 8
        sendMessageButton.addTarget(
            self, action: #selector(sendMessageToFlutter), for: .touchUpInside)
        sendMessageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendMessageButton)

        // 创建显示来自 Flutter 消息的标签
        messageLabel = UILabel()
        messageLabel.text = "来自 Flutter 的消息将显示在这里"
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)

        // 设置约束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            openFlutterButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            openFlutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openFlutterButton.widthAnchor.constraint(equalToConstant: 200),
            openFlutterButton.heightAnchor.constraint(equalToConstant: 44),

            sendMessageButton.topAnchor.constraint(
                equalTo: openFlutterButton.bottomAnchor, constant: 20),
            sendMessageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 200),
            sendMessageButton.heightAnchor.constraint(equalToConstant: 44),

            messageLabel.topAnchor.constraint(
                equalTo: sendMessageButton.bottomAnchor, constant: 40),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
        ])
    }

    private func setupMethodChannel() {
        // 创建方法通道
        guard let flutterEngine = flutterEngine else { return }
        let methodChannel = FlutterMethodChannel(
            name: channel, binaryMessenger: flutterEngine.binaryMessenger)

        // 处理来自 Flutter 的方法调用
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }

            switch call.method {
            case "sendMessageToNative":
                if let message = call.arguments as? String {
                    self.handleMessageFromFlutter(message)
                    result("消息已成功接收")
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "参数无效", details: nil))
                }
            case "willCloseFlutterView":
                // 处理 Flutter 页面即将关闭的通知
                DispatchQueue.main.async {
                    // 如果当前有展示的 FlutterViewController，关闭它
                    if let presentedVC = self.presentedViewController as? FlutterViewController {
                        presentedVC.dismiss(animated: true, completion: nil)
                    }
                }
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    @objc private func openFlutterPage() {
        // 创建自定义 FlutterViewController
        guard let flutterEngine = flutterEngine else { return }
        let flutterViewController = CustomFlutterViewController(
            engine: flutterEngine,
            channelName: channel
        )

        // 设置生命周期回调
        flutterViewController.onViewDidLoad = {
            print("Flutter 页面已加载")
        }

        flutterViewController.onViewDidAppear = {
            print("Flutter 页面已显示")
        }

        flutterViewController.onViewDidDisappear = {
            print("Flutter 页面已消失")
        }

        flutterViewController.onDeinit = {
            print("Flutter 页面已释放")
        }

        // 设置展示样式
        flutterViewController.modalPresentationStyle = .fullScreen

        // 导航到 Flutter 页面
        present(flutterViewController, animated: true, completion: nil)
    }

    @objc private func sendMessageToFlutter() {
        guard let flutterEngine = flutterEngine else { return }
        let methodChannel = FlutterMethodChannel(
            name: channel, binaryMessenger: flutterEngine.binaryMessenger)

        // 发送消息到 Flutter
        let message = "来自 iOS 的消息: \(Date())"
        methodChannel.invokeMethod("sendMessageToFlutter", arguments: message) { (result) in
            if let error = result as? FlutterError {
                print("发送消息到 Flutter 失败: \(error.message ?? "未知错误")")
            } else if let response = result as? String {
                print("Flutter 响应: \(response)")
            }
        }
    }

    private func handleMessageFromFlutter(_ message: String) {
        // 在主线程更新 UI
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = "收到来自 Flutter 的消息: \(message)"
        }
    }
}
