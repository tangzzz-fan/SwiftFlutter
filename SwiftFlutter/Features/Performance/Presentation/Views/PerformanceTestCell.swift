//
//  PerformanceTestCell.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import UIKit
import Anchorage

/// 性能测试单元格
class PerformanceTestCell: UITableViewCell {
    static let identifier = "PerformanceTestCell"
    
    // MARK: - UI Elements
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemOrange
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        return imageView
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
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(chevronImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.edgeAnchors == contentView.edgeAnchors + UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        
        iconImageView.leadingAnchor == containerView.leadingAnchor + 16
        iconImageView.centerYAnchor == containerView.centerYAnchor
        iconImageView.widthAnchor == 40
        iconImageView.heightAnchor == 40
        
        titleLabel.leadingAnchor == iconImageView.trailingAnchor + 12
        titleLabel.topAnchor == containerView.topAnchor + 12
        titleLabel.trailingAnchor == statusLabel.leadingAnchor - 8
        
        descriptionLabel.leadingAnchor == titleLabel.leadingAnchor
        descriptionLabel.topAnchor == titleLabel.bottomAnchor + 4
        descriptionLabel.trailingAnchor == titleLabel.trailingAnchor
        descriptionLabel.bottomAnchor <= containerView.bottomAnchor - 12
        
        statusLabel.trailingAnchor == chevronImageView.leadingAnchor - 8
        statusLabel.centerYAnchor == containerView.centerYAnchor
        statusLabel.widthAnchor == 60
        statusLabel.heightAnchor == 24
        
        chevronImageView.trailingAnchor == containerView.trailingAnchor - 16
        chevronImageView.centerYAnchor == containerView.centerYAnchor
        chevronImageView.widthAnchor == 12
        chevronImageView.heightAnchor == 12
    }
    
    // MARK: - Configuration
    
    func configure(with testItem: PerformanceTestItem) {
        titleLabel.text = testItem.title
        descriptionLabel.text = testItem.description
        
        // 设置图标
        let iconName = getIconName(for: testItem.testType)
        iconImageView.image = UIImage(systemName: iconName)
        
        // 设置状态
        if testItem.isAvailable {
            statusLabel.text = "可用"
            statusLabel.backgroundColor = .systemGreen.withAlphaComponent(0.2)
            statusLabel.textColor = .systemGreen
            
            containerView.alpha = 1.0
            chevronImageView.isHidden = false
        } else {
            statusLabel.text = "开发中"
            statusLabel.backgroundColor = .systemGray.withAlphaComponent(0.2)
            statusLabel.textColor = .systemGray
            
            containerView.alpha = 0.7
            chevronImageView.isHidden = true
        }
    }
    
    private func getIconName(for testType: PerformanceTestType) -> String {
        switch testType {
        case .highFrequencyDataStream:
            return "waveform.path.ecg"
        case .largeDataTransfer:
            return "doc.on.doc"
        case .complexDataStructure:
            return "tree"
        case .memoryUsage:
            return "memorychip"
        case .launchTime:
            return "stopwatch"
        case .highFrequencyData:
            return "waveform.path.ecg"
        }
    }
}