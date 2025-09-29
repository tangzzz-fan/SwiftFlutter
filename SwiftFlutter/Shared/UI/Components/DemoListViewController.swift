//
//  DemoListViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import Anchorage
import UIKit

/// Demo列表基础视图控制器
class DemoListViewController: UIViewController {
    // MARK: - Properties
    
    internal var demos: [DemoItem] = []
    internal let demoType: DemoType
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(DemoTableViewCell.self, forCellReuseIdentifier: DemoTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: - Initialization
    
    init(demoType: DemoType) {
        self.demoType = demoType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDemos()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // 设置标题
        switch demoType {
        case .native:
            title = "原生功能"
        case .reactNative:
            title = "React Native"
        case .hybrid:
            title = "混合开发"
        case .flutter:
            title = "Flutter"
        }
        
        // 添加视图
        view.addSubview(tableView)
        tableView.refreshControl = refreshControl
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 使用 Anchorage 设置约束
        tableView.topAnchor == view.safeAreaLayoutGuide.topAnchor
        tableView.leadingAnchor == view.leadingAnchor
        tableView.trailingAnchor == view.trailingAnchor
        tableView.bottomAnchor == view.bottomAnchor
    }
    
    // MARK: - Data Loading
    
    private func loadDemos() {
        switch demoType {
        case .native:
            demos = NativeDemoProvider.getDefaultDemos()
        case .hybrid:
            demos = HybridDemoProvider.getDefaultDemos()
        case .reactNative:
            demos = ReactNativeDemoProvider.getDefaultDemos()
        case .flutter:
            demos = FlutterDemoProvider.getDefaultDemos()
        }
        
        tableView.reloadData()
    }
    
    @objc private func refreshData() {
        loadDemos()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    // MARK: - Navigation
    
    private func handleDemoSelection(_ demo: DemoItem) {
        guard demo.isAvailable else {
            showAlert(title: "功能暂未开放", message: "该功能正在开发中，敬请期待")
            return
        }
        
        guard let targetController = demo.targetController else {
            showAlert(title: "配置错误", message: "未找到对应的控制器")
            return
        }
        
        navigateToDemo(controllerName: targetController, demo: demo)
    }
    
    private func navigateToDemo(controllerName: String, demo: DemoItem) {
        switch controllerName {
        // 原生控制器
        case "NetworkTestViewController":
            let vc = NetworkTestViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        case "MQTTTestViewController":
            let vc = MQTTTestViewController()
            navigationController?.pushViewController(vc, animated: true)
            
        case "WebSocketTestViewController":
            let vc = WebSocketTestViewController()
            navigationController?.pushViewController(vc, animated: true)

        // Flutter控制器
        case "CustomFlutterViewController":
            navigateToFlutter(demo: demo)
            
        // 混合控制器
        case "HybridMallViewController",
             "HybridPaymentViewController",
             "NativeFlutterBridgeViewController":
            navigateToHybrid(demo: demo)
        
        // React Native控制器
        case "ReactNativeViewController":
            navigateToReactNative(demo: demo)

        default:
            // 其他原生控制器的通用处理
            navigateToGenericNative(controllerName: controllerName, demo: demo)
        }
    }
    
    private func navigateToReactNative(demo: DemoItem) {
        // 确保 React Native 桥接已初始化
        ReactNativeBridgeManager.shared.initializeBridge()
        
        // 创建 React Native 视图控制器
        let reactNativeVC = ReactNativeViewController(
            moduleName: "SmartHomeApp",
            initialProps: [
                "demoId": demo.id,
                "demoTitle": demo.title,
                "demoDescription": demo.description
            ]
        )
        
        reactNativeVC.title = demo.title
        navigationController?.pushViewController(reactNativeVC, animated: true)
    }
    
    private func navigateToFlutter(demo: DemoItem) {
        guard let flutterEngine = DependencyContainer.shared.resolve(FlutterEngineManager.self)?.getEngine(forKey: "main") else {
            showAlert(title: "Flutter引擎错误", message: "Flutter引擎不可用")
            return
        }
        
        let flutterViewController = CustomFlutterViewController(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )
        flutterViewController.title = demo.title
        navigationController?.pushViewController(flutterViewController, animated: true)
    }
    
    private func navigateToHybrid(demo: DemoItem) {
        // TODO: 实现混合开发导航
        showAlert(title: "混合开发", message: "\(demo.title) 功能正在开发中")
    }
    
    private func navigateToGenericNative(controllerName: String, demo: DemoItem) {
        // 通用原生控制器处理
        showAlert(title: "功能开发中", message: "\(demo.title) 功能正在开发中")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension DemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DemoTableViewCell.identifier, for: indexPath) as? DemoTableViewCell else {
            return UITableViewCell()
        }
        
        let demo = demos[indexPath.row]
        cell.configure(with: demo)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let demo = demos[indexPath.row]
        handleDemoSelection(demo)
    }
}
