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
        loadReactNativeView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "React Native 页面"
        
        // 添加返回按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "返回",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
    }
    
    private func loadReactNativeView() {
        // 确保 React Native 已经初始化
        guard let bridge = ReactNativeBridgeManager.shared.bridge else {
            showError(message: "React Native bridge 未初始化")
            return
        }
        
        // 创建 React Native 根视图
        let rootView = RCTRootView(
            bridge: bridge,
            moduleName: moduleName,
            initialProperties: initialProps
        )
        
        self.reactRootView = rootView
        
        // 添加 React Native 视图到控制器
        view.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置约束
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 监听 React Native 加载状态
        setupLoadingObserver()
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
    
    // MARK: - Loading Indicator
    
    private func showLoadingIndicator() {
        // 这里可以实现自定义的加载指示器
        // 暂时使用系统自带的
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoadingIndicator() {
        view.isUserInteractionEnabled = true
    }
    
    // MARK: - Error Handling
    
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
        // 清理 React Native 视图
        if isMovingFromParent {
            reactRootView?.removeFromSuperview()
            reactRootView = nil
        }
    }
    
    deinit {
        print("ReactNativeViewController 被释放")
    }
}