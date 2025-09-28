//
//  HighFrequencyDataTestViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import UIKit
import Anchorage
import Flutter

/// 高频数据流测试视图控制器
class HighFrequencyDataTestViewController: UIViewController {
    
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
    
    private lazy var controlPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var frequencySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["10ms", "50ms", "100ms"])
        control.selectedSegmentIndex = 1 // 默认选择50ms
        control.addTarget(self, action: #selector(frequencyChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var startStopButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("开始测试", for: .normal)
        button.setTitle("停止测试", for: .selected)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(startStopButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var flutterResultView: TestResultView = {
        let view = TestResultView(title: "Flutter 测试结果")
        return view
    }()
    
    private lazy var comparisonView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var comparisonLabel: UILabel = {
        let label = UILabel()
        label.text = "性能对比"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var comparisonResultLabel: UILabel = {
        let label = UILabel()
        label.text = "点击开始测试查看对比结果"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Properties
    
    private var isTestRunning = false
    private var testTimer: Timer?
    private var flutterDataHandler: HighFrequencyDataStreamHandler?
    
    private var flutterStats = TestStats()
    
    private var currentFrequency: TimeInterval {
        switch frequencySegmentedControl.selectedSegmentIndex {
        case 0: return 0.01  // 10ms
        case 1: return 0.05  // 50ms
        case 2: return 0.1   // 100ms
        default: return 0.05
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataHandlers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTest()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "高频数据流测试"
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(controlPanelView)
        controlPanelView.addSubview(frequencySegmentedControl)
        controlPanelView.addSubview(startStopButton)
        
        contentView.addSubview(flutterResultView)
        contentView.addSubview(comparisonView)
        
        comparisonView.addSubview(comparisonLabel)
        comparisonView.addSubview(comparisonResultLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        scrollView.edgeAnchors == view.safeAreaLayoutGuide.edgeAnchors
        
        contentView.edgeAnchors == scrollView.edgeAnchors
        contentView.widthAnchor == scrollView.widthAnchor
        
        controlPanelView.topAnchor == contentView.topAnchor + 16
        controlPanelView.leadingAnchor == contentView.leadingAnchor + 16
        controlPanelView.trailingAnchor == contentView.trailingAnchor - 16
        controlPanelView.heightAnchor == 120
        
        frequencySegmentedControl.topAnchor == controlPanelView.topAnchor + 16
        frequencySegmentedControl.leadingAnchor == controlPanelView.leadingAnchor + 16
        frequencySegmentedControl.trailingAnchor == controlPanelView.trailingAnchor - 16
        
        startStopButton.topAnchor == frequencySegmentedControl.bottomAnchor + 16
        startStopButton.leadingAnchor == controlPanelView.leadingAnchor + 16
        startStopButton.trailingAnchor == controlPanelView.trailingAnchor - 16
        startStopButton.heightAnchor == 44
        
        flutterResultView.topAnchor == controlPanelView.bottomAnchor + 16
        flutterResultView.leadingAnchor == contentView.leadingAnchor + 16
        flutterResultView.trailingAnchor == contentView.trailingAnchor - 16

        comparisonView.topAnchor == flutterResultView.bottomAnchor + 16
        comparisonView.leadingAnchor == contentView.leadingAnchor + 16
        comparisonView.trailingAnchor == contentView.trailingAnchor - 16
        comparisonView.bottomAnchor == contentView.bottomAnchor - 16
        comparisonView.heightAnchor == 120
        
        comparisonLabel.topAnchor == comparisonView.topAnchor + 16
        comparisonLabel.centerXAnchor == comparisonView.centerXAnchor
        
        comparisonResultLabel.topAnchor == comparisonLabel.bottomAnchor + 8
        comparisonResultLabel.leadingAnchor == comparisonView.leadingAnchor + 16
        comparisonResultLabel.trailingAnchor == comparisonView.trailingAnchor - 16
        comparisonResultLabel.bottomAnchor <= comparisonView.bottomAnchor - 16
    }
    
    private func setupDataHandlers() {
        // 设置Flutter数据处理器
        if let engine = DependencyContainer.shared.resolve(FlutterEngineManager.self)?.getEngine(forKey: "main") {
            flutterDataHandler = HighFrequencyDataStreamHandler()
            let eventChannel = FlutterEventChannel(
                name: "com.swiftflutter.performance.highfrequency",
                binaryMessenger: engine.binaryMessenger
            )
            eventChannel.setStreamHandler(flutterDataHandler)
        }
    }
    
    // MARK: - Actions
    
    @objc private func frequencyChanged() {
        if isTestRunning {
            stopTest()
            startTest()
        }
    }
    
    @objc private func startStopButtonTapped() {
        if isTestRunning {
            stopTest()
        } else {
            startTest()
        }
    }
    
    private func startTest() {
        isTestRunning = true
        startStopButton.isSelected = true
        startStopButton.backgroundColor = .systemRed
        frequencySegmentedControl.isEnabled = false
        
        // 重置统计数据
        flutterStats.reset()
        
        // 更新UI
        flutterResultView.updateStats(flutterStats)
        comparisonResultLabel.text = "测试进行中..."
        
        // 启动定时器
        testTimer = Timer.scheduledTimer(withTimeInterval: currentFrequency, repeats: true) { [weak self] _ in
            self?.sendTestData()
        }
    }
    
    private func stopTest() {
        isTestRunning = false
        startStopButton.isSelected = false
        startStopButton.backgroundColor = .systemBlue
        frequencySegmentedControl.isEnabled = true
        
        testTimer?.invalidate()
        testTimer = nil
        
        // 更新对比结果
        updateComparisonResult()
    }
    
    private func sendTestData() {
        let timestamp = Date().timeIntervalSince1970
        let testData: [String: Any] = [
            "timestamp": timestamp,
            "value": Double.random(in: 0...100),
            "sequence": flutterStats.messagesSent
        ]
        
        // 发送到Flutter
        flutterDataHandler?.sendData(testData) { [weak self] success, latency in
            DispatchQueue.main.async {
                if success {
                    self?.flutterStats.recordSuccess(latency: latency)
                } else {
                    self?.flutterStats.recordFailure()
                }
                self?.flutterResultView.updateStats(self?.flutterStats ?? TestStats())
            }
        }

    }
    
    private func updateComparisonResult() {
        let flutterAvgLatency = flutterStats.averageLatency
        
        let flutterSuccessRate = flutterStats.successRate
        
        var result = "测试完成\n\n"
        result += "平均延迟对比:\n"
        result += "Flutter: \(String(format: "%.2f", flutterAvgLatency))ms\n"
        result += "成功率对比:\n"
        result += "Flutter: \(String(format: "%.1f", flutterSuccessRate))%\n"
        
        comparisonResultLabel.text = result
    }
}

// MARK: - Test Stats

struct TestStats {
    private(set) var messagesSent = 0
    private(set) var messagesReceived = 0
    private(set) var totalLatency: Double = 0
    private(set) var minLatency: Double = Double.greatestFiniteMagnitude
    private(set) var maxLatency: Double = 0
    
    var averageLatency: Double {
        return messagesReceived > 0 ? totalLatency / Double(messagesReceived) : 0
    }
    
    var successRate: Double {
        return messagesSent > 0 ? Double(messagesReceived) / Double(messagesSent) * 100 : 0
    }
    
    mutating func recordSuccess(latency: Double) {
        messagesSent += 1
        messagesReceived += 1
        totalLatency += latency
        minLatency = min(minLatency, latency)
        maxLatency = max(maxLatency, latency)
    }
    
    mutating func recordFailure() {
        messagesSent += 1
    }
    
    mutating func reset() {
        messagesSent = 0
        messagesReceived = 0
        totalLatency = 0
        minLatency = Double.greatestFiniteMagnitude
        maxLatency = 0
    }
}
