//
//  DemoTableViewCell.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import Anchorage
import UIKit

/// Demo列表单元格
class DemoTableViewCell: UITableViewCell {
    static let identifier = "DemoTableViewCell"
    
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
        imageView.tintColor = .systemBlue
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
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
        // Container view constraints
        containerView.topAnchor == contentView.topAnchor + 8
        containerView.leadingAnchor == contentView.leadingAnchor + 16
        containerView.trailingAnchor == contentView.trailingAnchor - 16
        containerView.bottomAnchor == contentView.bottomAnchor - 8
        
        // Icon constraints
        iconImageView.leadingAnchor == containerView.leadingAnchor + 16
        iconImageView.centerYAnchor == containerView.centerYAnchor
        iconImageView.widthAnchor == 32
        iconImageView.heightAnchor == 32
        
        // Title constraints
        titleLabel.topAnchor == containerView.topAnchor + 12
        titleLabel.leadingAnchor == iconImageView.trailingAnchor + 12
        titleLabel.trailingAnchor == statusLabel.leadingAnchor - 8
        
        // Description constraints
        descriptionLabel.topAnchor == titleLabel.bottomAnchor + 4
        descriptionLabel.leadingAnchor == titleLabel.leadingAnchor
        descriptionLabel.trailingAnchor == titleLabel.trailingAnchor
        descriptionLabel.bottomAnchor <= containerView.bottomAnchor - 12
        
        // Status label constraints
        statusLabel.centerYAnchor == containerView.centerYAnchor
        statusLabel.trailingAnchor == chevronImageView.leadingAnchor - 8
        statusLabel.widthAnchor == 60
        statusLabel.heightAnchor == 24
        
        // Chevron constraints
        chevronImageView.centerYAnchor == containerView.centerYAnchor
        chevronImageView.trailingAnchor == containerView.trailingAnchor - 16
        chevronImageView.widthAnchor == 12
        chevronImageView.heightAnchor == 12
    }
    
    // MARK: - Configuration
    
    func configure(with demo: DemoItem) {
        titleLabel.text = demo.title
        descriptionLabel.text = demo.description
        
        // 设置图标
        if let iconName = demo.iconName {
            iconImageView.image = UIImage(systemName: iconName)
        } else {
            // 根据demo类型设置默认图标
            switch demo.demoType {
            case .native:
                iconImageView.image = UIImage(systemName: "swift")
                iconImageView.tintColor = .systemOrange
                iconImageView.backgroundColor = .systemOrange.withAlphaComponent(0.1)
            case .reactNative:
                iconImageView.image = UIImage(systemName: "atom")
                iconImageView.tintColor = .systemBlue
                iconImageView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            case .hybrid:
                iconImageView.image = UIImage(systemName: "link")
                iconImageView.tintColor = .systemPurple
                iconImageView.backgroundColor = .systemPurple.withAlphaComponent(0.1)
            case .flutter:
                iconImageView.image = UIImage(systemName: "bird")
                iconImageView.tintColor = .systemTeal
                iconImageView.backgroundColor = .systemTeal.withAlphaComponent(0.1)
            }
        }
        
        // 设置状态标签
        if demo.isAvailable {
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
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        descriptionLabel.text = nil
        iconImageView.image = nil
        statusLabel.text = nil
        containerView.alpha = 1.0
        chevronImageView.isHidden = false
    }
}
