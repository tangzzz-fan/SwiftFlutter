//
//  ReactNativeViewController.swift
//  SwiftFlutter
//
//  Created by AI Assistant on 2025/06/10.
//

import UIKit
import React

/// React Native 页面控制器
class ReactNativeViewController: UIViewController {
    
    // MARK: - Properties
    
    private var reactRootView: RCTRootView?
    private var moduleName: String = "SmartHomeApp"
    private var initialProps: [String: Any] = [:]
    
    // MARK: - Initialization
    
    init(moduleName: String = "SmartHomeApp", initialProps: [String: Any] = [:]) {
        self.moduleName = moduleName
        self.initialProps = initialProps
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBridgeStateObserver()
        loadReactNativeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保导航栏保持隐藏状态
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // 检查bridge状态
        checkBridgeHealth()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 再次确保导航栏保持隐藏状态
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // 使用与其他原生页面相同的背景色
        view.backgroundColor = .systemGroupedBackground
        // 隐藏导航栏
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func loadReactNativeView() {
        // 检查 React Native bridge 状态
        let bridgeManager = ReactNativeBridgeManager.shared
        
        switch bridgeManager.getBridgeState() {
        case .notInitialized:
            // 如果未初始化，先初始化bridge
            showLoadingIndicator()
            bridgeManager.initializeBridge()
            
            // 等待bridge就绪
            bridgeManager.waitForBridgeReady(timeout: 15.0) { [weak self] success in
                DispatchQueue.main.async {
                    self?.hideLoadingIndicator()
                    if success {
                        self?.createReactNativeView()
                    } else {
                        self?.showFallbackView(message: "React Native bridge 初始化超时")
                    }
                }
            }
            return
        case .initializing:
            showLoadingIndicator()
            // 等待bridge就绪
            bridgeManager.waitForBridgeReady(timeout: 15.0) { [weak self] success in
                DispatchQueue.main.async {
                    self?.hideLoadingIndicator()
                    if success {
                        self?.createReactNativeView()
                    } else {
                        self?.showFallbackView(message: "React Native bridge 初始化超时")
                    }
                }
            }
            return
        case .ready:
            createReactNativeView()
        case .failed(let error):
            showFallbackView(message: "React Native bridge 初始化失败: \(error.localizedDescription)")
        case .invalidated:
            showFallbackView(message: "React Native bridge 已失效")
        }
    }
    
    private func createReactNativeView() {
        guard let bridge = ReactNativeBridgeManager.shared.bridge else {
            showFallbackView(message: "React Native bridge 不可用")
            return
        }
        
        // 创建 React Native 根视图
        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: moduleName,
            initialProperties: initialProps
        )
        
        // 设置 React Native 根视图背景色与原生保持一致
        rootView.backgroundColor = .systemGroupedBackground
        
        self.reactRootView = rootView
        
        // 添加 React Native 视图到控制器
        view.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        
        // 修复安全区适配：直接使用 view 的边界，让 React Native 内部处理安全区
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        print("React Native 视图创建成功")
    }
    
    private func setupLoadingObserver() {
        // 监听 React Native 视图的加载状态
        // 注意：RCTRootView 的 contentDidAppear 和 contentDidDisappear 在新版本中可能需要通过其他方式监听
        
        // 显示加载指示器
        showLoadingIndicator()
        
        // 使用延迟来模拟加载完成（实际项目中应该监听正确的加载事件）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.hideLoadingIndicator()
        }
    }
    
    private func setupBridgeStateObserver() {
        // 监听bridge状态变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bridgeStateChanged(_:)),
            name: .bridgeStateChanged,
            object: nil
        )
    }
    
    @objc private func bridgeStateChanged(_ notification: Notification) {
        guard let state = notification.userInfo?["state"] as? BridgeState else { return }
        
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .ready:
                // 如果当前显示的是fallback view，尝试重新加载
                if self?.reactRootView == nil {
                    self?.loadReactNativeView()
                }
            case .failed(let error):
                self?.showFallbackView(message: "Bridge失败: \(error.localizedDescription)")
            case .invalidated:
                self?.showFallbackView(message: "Bridge已失效，请重试")
            default:
                break
            }
        }
    }
    
    private func checkBridgeHealth() {
        let bridgeManager = ReactNativeBridgeManager.shared
        
        // 如果bridge不健康，显示fallback
        if !bridgeManager.performHealthCheck() {
            showFallbackView(message: "React Native bridge 状态异常")
        }
    }
    
    // MARK: - Loading Indicator
    
    private func showLoadingIndicator() {
        // 这里可以实现自定义的加载指示器
        // 暂时使用系统自带的
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - Error Handling & Fallback
    
    private func showFallbackView(message: String) {
        // 创建占位视图
        let fallbackView = createFallbackView(message: message)
        view.addSubview(fallbackView)
        fallbackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            fallbackView.topAnchor.constraint(equalTo: view.topAnchor),
            fallbackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fallbackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fallbackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createFallbackView(message: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .systemGroupedBackground
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 错误图标
        let iconImageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        iconImageView.tintColor = .systemOrange
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 错误标题
        let titleLabel = UILabel()
        titleLabel.text = "React Native 加载失败"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        
        // 错误描述
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        // 重试按钮
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("重试", for: .normal)
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        retryButton.backgroundColor = .systemBlue
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 8
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        retryButton.addTarget(self, action: #selector(retryLoadReactNative), for: .touchUpInside)
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(retryButton)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -32)
        ])
        
        return containerView
    }
    
    @objc private func retryLoadReactNative() {
        // 清除现有视图
        view.subviews.forEach { $0.removeFromSuperview() }
        
        // 重新初始化 React Native Bridge
        ReactNativeBridgeManager.shared.initializeBridge()
        
        // 重新加载 React Native 视图
        loadReactNativeView()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(
            title: "错误",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Memory Management
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 不再在这里清理bridge，让ReactNativeBridgeManager管理bridge生命周期
        print("ReactNativeViewController viewDidDisappear")
    }
    
    deinit {
        // 清理通知监听
        NotificationCenter.default.removeObserver(self)
        
        // 清理 React Native 视图
        reactRootView?.removeFromSuperview()
        reactRootView = nil
        
        print("ReactNativeViewController 已释放")
    }
}
