//
//  TestResultView.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import UIKit
import Anchorage

/// 测试结果显示视图
class TestResultView: UIView {
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private lazy var statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var messagesSentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "发送消息: 0"
        return label
    }()
    
    private lazy var messagesReceivedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "接收消息: 0"
        return label
    }()
    
    private lazy var successRateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "成功率: 0.0%"
        return label
    }()
    
    private lazy var averageLatencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "平均延迟: 0.00ms"
        return label
    }()
    
    private lazy var minLatencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "最小延迟: 0.00ms"
        return label
    }()
    
    private lazy var maxLatencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "最大延迟: 0.00ms"
        return label
    }()
    
    private lazy var statusIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 6
        return view
    }()
    
    // MARK: - Initialization
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1
        
        addSubview(titleLabel)
        addSubview(statusIndicator)
        addSubview(statsStackView)
        
        statsStackView.addArrangedSubview(messagesSentLabel)
        statsStackView.addArrangedSubview(messagesReceivedLabel)
        statsStackView.addArrangedSubview(successRateLabel)
        statsStackView.addArrangedSubview(averageLatencyLabel)
        statsStackView.addArrangedSubview(minLatencyLabel)
        statsStackView.addArrangedSubview(maxLatencyLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.topAnchor == topAnchor + 16
        titleLabel.leadingAnchor == leadingAnchor + 16
        
        statusIndicator.centerYAnchor == titleLabel.centerYAnchor
        statusIndicator.trailingAnchor == trailingAnchor - 16
        statusIndicator.widthAnchor == 12
        statusIndicator.heightAnchor == 12
        
        statsStackView.topAnchor == titleLabel.bottomAnchor + 16
        statsStackView.leadingAnchor == leadingAnchor + 16
        statsStackView.trailingAnchor == trailingAnchor - 16
        statsStackView.bottomAnchor == bottomAnchor - 16
        
        heightAnchor == 200
    }
    
    // MARK: - Public Methods
    
    func updateStats(_ stats: TestStats) {
        messagesSentLabel.text = "发送消息: \(stats.messagesSent)"
        messagesReceivedLabel.text = "接收消息: \(stats.messagesReceived)"
        successRateLabel.text = "成功率: \(String(format: "%.1f", stats.successRate))%"
        averageLatencyLabel.text = "平均延迟: \(String(format: "%.2f", stats.averageLatency))ms"
        
        if stats.minLatency == Double.greatestFiniteMagnitude {
            minLatencyLabel.text = "最小延迟: --"
        } else {
            minLatencyLabel.text = "最小延迟: \(String(format: "%.2f", stats.minLatency))ms"
        }
        
        maxLatencyLabel.text = "最大延迟: \(String(format: "%.2f", stats.maxLatency))ms"
        
        // 更新状态指示器颜色
        updateStatusIndicator(successRate: stats.successRate)
    }
    
    private func updateStatusIndicator(successRate: Double) {
        switch successRate {
        case 95...100:
            statusIndicator.backgroundColor = .systemGreen
        case 80..<95:
            statusIndicator.backgroundColor = .systemYellow
        case 0..<80:
            statusIndicator.backgroundColor = .systemRed
        default:
            statusIndicator.backgroundColor = .systemGray
        }
    }
    
    func reset() {
        messagesSentLabel.text = "发送消息: 0"
        messagesReceivedLabel.text = "接收消息: 0"
        successRateLabel.text = "成功率: 0.0%"
        averageLatencyLabel.text = "平均延迟: 0.00ms"
        minLatencyLabel.text = "最小延迟: 0.00ms"
        maxLatencyLabel.text = "最大延迟: 0.00ms"
        statusIndicator.backgroundColor = .systemGray
    }
}