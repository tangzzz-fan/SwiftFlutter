//
//  PerformanceTestViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import UIKit
import Anchorage

/// 性能测试视图控制器
class PerformanceTestViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .systemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PerformanceTestCell.self, forCellReuseIdentifier: PerformanceTestCell.identifier)
        return tableView
    }()
    
    // MARK: - Properties
    
    private let testItems: [PerformanceTestItem] = [
        PerformanceTestItem(
            title: "高频数据流传输测试",
            description: "测试Flutter和React Native的高频数据传输性能",
            testType: .highFrequencyDataStream,
            isAvailable: true
        ),
        PerformanceTestItem(
            title: "大数据量传输测试",
            description: "测试大型JSON数据在跨平台间的传输性能",
            testType: .largeDataTransfer,
            isAvailable: false
        ),
        PerformanceTestItem(
            title: "复杂数据结构传递测试",
            description: "测试复杂嵌套对象的序列化和反序列化性能",
            testType: .complexDataStructure,
            isAvailable: false
        ),
        PerformanceTestItem(
            title: "内存使用监控",
            description: "监控各技术栈的内存使用情况",
            testType: .memoryUsage,
            isAvailable: false
        ),
        PerformanceTestItem(
            title: "启动时间对比",
            description: "对比不同技术栈的页面启动时间",
            testType: .launchTime,
            isAvailable: false
        ),
        PerformanceTestItem(
            title: "高频数据流测试",
            description: "测试高频数据传输的延迟和成功率",
            testType: .highFrequencyData,
            isAvailable: true
        )
    ]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "性能测试"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(tableView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        tableView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
    }
    
    // MARK: - Actions
    
    private func handleTestSelection(_ testItem: PerformanceTestItem) {
        guard testItem.isAvailable else {
            showAlert(title: "功能开发中", message: "\(testItem.title) 功能正在开发中")
            return
        }
        
        switch testItem.testType {
        case .highFrequencyDataStream:
            navigateToHighFrequencyTest()
        case .largeDataTransfer:
            navigateToLargeDataTest()
        case .complexDataStructure:
            navigateToComplexDataTest()
        case .memoryUsage:
            navigateToMemoryUsageTest()
        case .launchTime:
            navigateToLaunchTimeTest()
        case .highFrequencyData:
            navigateToHighFrequencyDataTest()
        }
    }
    
    private func navigateToHighFrequencyTest() {
        let highFrequencyTestVC = HighFrequencyDataTestViewController()
        navigationController?.pushViewController(highFrequencyTestVC, animated: true)
    }
    
    private func navigateToHighFrequencyDataTest() {
        let highFrequencyTestVC = HighFrequencyDataTestViewController()
        navigationController?.pushViewController(highFrequencyTestVC, animated: true)
    }
    
    private func navigateToLargeDataTest() {
        // TODO: 实现大数据量传输测试
        showAlert(title: "功能开发中", message: "大数据量传输测试功能正在开发中")
    }
    
    private func navigateToComplexDataTest() {
        // TODO: 实现复杂数据结构测试
        showAlert(title: "功能开发中", message: "复杂数据结构测试功能正在开发中")
    }
    
    private func navigateToMemoryUsageTest() {
        // TODO: 实现内存使用监控
        showAlert(title: "功能开发中", message: "内存使用监控功能正在开发中")
    }
    
    private func navigateToLaunchTimeTest() {
        // TODO: 实现启动时间对比
        showAlert(title: "功能开发中", message: "启动时间对比功能正在开发中")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension PerformanceTestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PerformanceTestCell.identifier, for: indexPath) as? PerformanceTestCell else {
            return UITableViewCell()
        }
        
        let testItem = testItems[indexPath.row]
        cell.configure(with: testItem)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PerformanceTestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let testItem = testItems[indexPath.row]
        handleTestSelection(testItem)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Models

struct PerformanceTestItem {
    let title: String
    let description: String
    let testType: PerformanceTestType
    let isAvailable: Bool
}

enum PerformanceTestType {
    case highFrequencyDataStream
    case largeDataTransfer
    case complexDataStructure
    case memoryUsage
    case launchTime
    case highFrequencyData
}