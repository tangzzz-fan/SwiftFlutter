//
//  CustomFlutterViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import UIKit

class CustomFlutterViewController: FlutterViewController {

    // 定义回调闭包类型
    typealias ViewLifecycleCallback = () -> Void

    // 生命周期回调
    var onViewDidLoad: ViewLifecycleCallback?
    var onViewWillAppear: ViewLifecycleCallback?
    var onViewDidAppear: ViewLifecycleCallback?
    var onViewWillDisappear: ViewLifecycleCallback?
    var onViewDidDisappear: ViewLifecycleCallback?
    var onDeinit: ViewLifecycleCallback?

    // 方法通道名称
    private let channelName: String

    // 初始化方法
    init(
        engine: FlutterEngine, channelName: String, nibName nibNameOrNil: String? = nil,
        bundle nibBundleOrNil: Bundle? = nil
    ) {
        self.channelName = channelName
        super.init(engine: engine, nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        self.channelName = "com.example.swiftflutter/channel"
        super.init(coder: aDecoder)
    }

    // MARK: - 生命周期方法

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置UI
        setupUI()

        // 调用回调
        onViewDidLoad?()

        // 记录日志
        print("CustomFlutterViewController - viewDidLoad")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onViewWillAppear?()
        print("CustomFlutterViewController - viewWillAppear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        onViewDidAppear?()
        print("CustomFlutterViewController - viewDidAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onViewWillDisappear?()
        print("CustomFlutterViewController - viewWillDisappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onViewDidDisappear?()
        print("CustomFlutterViewController - viewDidDisappear")
    }

    deinit {
        onDeinit?()
        print("CustomFlutterViewController - deinit")
    }

    // MARK: - 私有方法

    private func setupUI() {
        // 设置导航栏
        navigationItem.title = "Flutter 页面"

        // 添加关闭按钮
        let closeButton = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        navigationItem.rightBarButtonItem = closeButton
    }

    // MARK: - 操作方法

    @objc private func closeButtonTapped() {
        // 通知 Flutter 页面即将关闭
        notifyFlutterWillClose()

        // 关闭页面
        dismiss(animated: true, completion: nil)
    }

    // 通知 Flutter 页面即将关闭
    func notifyFlutterWillClose() {
        if let binaryMessenger = engine?.binaryMessenger {
            let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
            channel.invokeMethod("willCloseFromNative", arguments: nil)
        }
    }

    // 发送消息到 Flutter
    func sendMessage(to method: String, arguments: Any?, completion: ((Any?) -> Void)? = nil) {
        if let binaryMessenger = engine?.binaryMessenger {
            let channel = FlutterMethodChannel(name: channelName, binaryMessenger: binaryMessenger)
            channel.invokeMethod(method, arguments: arguments, result: completion)
        }
    }
}
