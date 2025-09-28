//
//  DeviceCategoryViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Anchorage
import Combine
import UIKit

/// 设备分类视图控制器
class DeviceCategoryViewController: UIViewController {
    // MARK: - Properties
    
    private var categories: [DeviceCategory] = []
    private let deviceViewModel: DeviceViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.register(DeviceCategoryTableViewCell.self, forCellReuseIdentifier: DeviceCategoryTableViewCell.identifier)
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
    
    init(deviceViewModel: DeviceViewModel = DeviceViewModel()) {
        self.deviceViewModel = deviceViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDeviceCounts()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "智能设备"
        view.backgroundColor = .systemGroupedBackground
        
        // 添加右侧导航按钮
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addDeviceTapped)
        )
        navigationItem.rightBarButtonItem = addButton
        
        // 设置视图
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
    
    private func setupBindings() {
        // 监听设备列表变化以更新设备数量
        deviceViewModel.$devices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDeviceCounts()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    private func loadData() {
        categories = DeviceCategory.getDefaultCategories()
        deviceViewModel.loadDevices()
        tableView.reloadData()
    }
    
    @objc private func refreshData() {
        deviceViewModel.loadDevices()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl.endRefreshing()
        }
    }
    
    private func updateDeviceCounts() {
        let devices = deviceViewModel.devices
        
        // 重新计算每个分类的设备数量
        for (index, category) in categories.enumerated() {
            let count: Int
            switch category.id {
            case "lighting":
                count = devices.filter { $0.type.lowercased().contains("light") || $0.type.lowercased().contains("lamp") }.count
            case "climate":
                count = devices.filter { $0.type.lowercased().contains("climate") || $0.type.lowercased().contains("thermometer") || $0.type.lowercased().contains("fan") }.count
            case "security":
                count = devices.filter { $0.type.lowercased().contains("camera") || $0.type.lowercased().contains("lock") || $0.type.lowercased().contains("sensor") }.count
            case "entertainment":
                count = devices.filter { $0.type.lowercased().contains("speaker") || $0.type.lowercased().contains("tv") || $0.type.lowercased().contains("media") }.count
            case "appliances":
                count = devices.filter { $0.type.lowercased().contains("appliance") || $0.type.lowercased().contains("switch") }.count
            case "network":
                count = devices.filter { $0.type.lowercased().contains("router") || $0.type.lowercased().contains("gateway") || $0.type.lowercased().contains("network") }.count
            default:
                count = 0
            }
            
            categories[index] = DeviceCategory(
                id: category.id,
                name: category.name,
                description: category.description,
                iconName: category.iconName,
                deviceCount: count
            )
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @objc private func addDeviceTapped() {
        let alert = UIAlertController(title: "添加设备", message: "选择添加设备的方式", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "扫描二维码", style: .default) { _ in
            // 实现扫描二维码功能
            self.showAlert(title: "功能开发中", message: "扫描二维码添加设备功能正在开发中")
        })
        
        alert.addAction(UIAlertAction(title: "手动添加", style: .default) { _ in
            // 实现手动添加功能
            self.showAlert(title: "功能开发中", message: "手动添加设备功能正在开发中")
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // iPad支持
        if let popover = alert.popoverPresentationController {
            popover.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension DeviceCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeviceCategoryTableViewCell.identifier, for: indexPath) as? DeviceCategoryTableViewCell else {
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        cell.configure(with: category)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DeviceCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        switch category.id {
        case "mqtt_test":
            navigateToMQTTTest()
        case "websocket_test":
            navigateToWebSocketTest()
        default:
            navigateToCategoryDevices(category: category)
        }
    }
    
    private func navigateToMQTTTest() {
        // 直接跳转到专门的MQTT测试页面
        let mqttTestVC = MQTTTestViewController()
        navigationController?.pushViewController(mqttTestVC, animated: true)
    }
    
    private func navigateToWebSocketTest() {
        // 直接跳转到专门的WebSocket测试页面
        let webSocketTestVC = WebSocketTestViewController()
        navigationController?.pushViewController(webSocketTestVC, animated: true)
    }
    
    private func navigateToCategoryDevices(category: DeviceCategory) {
        // 过滤该分类下的设备
        let devices = deviceViewModel.devices.filter { device in
            switch category.id {
            case "lighting":
                return device.type.lowercased().contains("light") || device.type.lowercased().contains("lamp")
            case "climate":
                return device.type.lowercased().contains("climate") || device.type.lowercased().contains("thermometer") || device.type.lowercased().contains("fan")
            case "security":
                return device.type.lowercased().contains("camera") || device.type.lowercased().contains("lock") || device.type.lowercased().contains("sensor")
            case "entertainment":
                return device.type.lowercased().contains("speaker") || device.type.lowercased().contains("tv") || device.type.lowercased().contains("media")
            case "appliances":
                return device.type.lowercased().contains("appliance") || device.type.lowercased().contains("switch")
            case "network":
                return device.type.lowercased().contains("router") || device.type.lowercased().contains("gateway") || device.type.lowercased().contains("network")
            default:
                return false
            }
        }
        
        if devices.isEmpty {
            showAlert(title: "暂无设备", message: "该分类下暂时没有设备")
        } else {
            // 创建带过滤设备的设备列表页面
            let deviceListVC = DeviceListViewController(viewModel: deviceViewModel)
            deviceListVC.title = category.name
            navigationController?.pushViewController(deviceListVC, animated: true)
        }
    }
    
}
