//
//  SettingsViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Anchorage
import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Settings"

        let label = UILabel()
        label.text = "Settings"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        // 使用 Anchorage 设置约束
        label.centerXAnchor == view.centerXAnchor
        label.centerYAnchor == view.centerYAnchor
    }
}
