//
//  DeviceTableViewCell.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Anchorage
import UIKit

/// 设备表格视图单元格
class DeviceTableViewCell: UITableViewCell {
    // MARK: - UI Elements

    private lazy var deviceNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        return label
    }()

    private lazy var deviceTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .default

        // 添加子视图
        contentView.addSubview(deviceNameLabel)
        contentView.addSubview(deviceTypeLabel)
        contentView.addSubview(statusLabel)

        // 设置约束
        setupConstraints()
    }

    private func setupConstraints() {
        // 使用 Anchorage 设置约束
        deviceNameLabel.topAnchor == contentView.topAnchor + 12
        deviceNameLabel.leadingAnchor == contentView.leadingAnchor + 16
        deviceNameLabel.trailingAnchor == statusLabel.leadingAnchor - 8

        deviceTypeLabel.topAnchor == deviceNameLabel.bottomAnchor + 4
        deviceTypeLabel.leadingAnchor == contentView.leadingAnchor + 16
        deviceTypeLabel.bottomAnchor == contentView.bottomAnchor - 12

        statusLabel.centerYAnchor == contentView.centerYAnchor
        statusLabel.trailingAnchor == contentView.trailingAnchor - 16
    }

    // MARK: - Configuration

    func configure(with device: Device) {
        deviceNameLabel.text = device.name
        deviceTypeLabel.text = device.type

        // 根据设备类型和状态设置状态标签
        if let isOn = device.state["on"]?.boolValue {
            statusLabel.text = isOn ? "开启" : "关闭"
            statusLabel.textColor = isOn ? .systemGreen : .systemRed
        } else if let isLocked = device.state["locked"]?.boolValue {
            statusLabel.text = isLocked ? "已锁定" : "未锁定"
            statusLabel.textColor = isLocked ? .systemRed : .systemGreen
        } else {
            statusLabel.text = "未知"
            statusLabel.textColor = .secondaryLabel
        }
    }
}
