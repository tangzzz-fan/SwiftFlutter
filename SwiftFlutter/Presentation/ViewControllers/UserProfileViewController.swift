//
//  UserProfileViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Anchorage
import UIKit

class UserProfileViewController: UIViewController {
    private let user: User

    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "User Profile"

        let label = UILabel()
        label.text = "User: \(user.name)"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        // 使用 Anchorage 设置约束
        label.centerXAnchor == view.centerXAnchor
        label.centerYAnchor == view.centerYAnchor
    }
}
