//
//  DeviceCategoryTableViewCell.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Anchorage
import UIKit

/// 设备分类表格视图单元格
class DeviceCategoryTableViewCell: UITableViewCell {
    static let identifier = "DeviceCategoryTableViewCell"
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let deviceCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemBlue
        label.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        return label
    }()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
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
        containerView.addSubview(deviceCountLabel)
        containerView.addSubview(arrowImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 使用 Anchorage 设置约束
        // Container view
        containerView.topAnchor == contentView.topAnchor + 8
        containerView.leadingAnchor == contentView.leadingAnchor + 16
        containerView.trailingAnchor == contentView.trailingAnchor - 16
        containerView.bottomAnchor == contentView.bottomAnchor - 8
        
        // Icon
        iconImageView.leadingAnchor == containerView.leadingAnchor + 16
        iconImageView.centerYAnchor == containerView.centerYAnchor
        iconImageView.widthAnchor == 32
        iconImageView.heightAnchor == 32
        
        // Title label
        titleLabel.topAnchor == containerView.topAnchor + 16
        titleLabel.leadingAnchor == iconImageView.trailingAnchor + 12
        titleLabel.trailingAnchor <= deviceCountLabel.leadingAnchor - 8
        
        // Description label
        descriptionLabel.topAnchor == titleLabel.bottomAnchor + 4
        descriptionLabel.leadingAnchor == titleLabel.leadingAnchor
        descriptionLabel.trailingAnchor <= arrowImageView.leadingAnchor - 8
        descriptionLabel.bottomAnchor == containerView.bottomAnchor - 16
        
        // Device count label
        deviceCountLabel.topAnchor == containerView.topAnchor + 16
        deviceCountLabel.trailingAnchor == arrowImageView.leadingAnchor - 12
        deviceCountLabel.widthAnchor >= 40
        deviceCountLabel.heightAnchor == 20
        
        // Arrow
        arrowImageView.centerYAnchor == containerView.centerYAnchor
        arrowImageView.trailingAnchor == containerView.trailingAnchor - 16
        arrowImageView.widthAnchor == 12
        arrowImageView.heightAnchor == 12
    }
    
    // MARK: - Configuration
    
    func configure(with category: DeviceCategory) {
        iconImageView.image = UIImage(systemName: category.iconName)
        titleLabel.text = category.name
        descriptionLabel.text = category.description
        deviceCountLabel.text = "\(category.deviceCount)"
        
        // 根据设备数量调整颜色
        if category.deviceCount > 0 {
            deviceCountLabel.textColor = .systemBlue
            deviceCountLabel.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        } else {
            deviceCountLabel.textColor = .systemGray
            deviceCountLabel.backgroundColor = .systemGray.withAlphaComponent(0.1)
        }
    }
    
    // MARK: - Animation
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.alpha = highlighted ? 0.8 : 1.0
        }
    }
}
