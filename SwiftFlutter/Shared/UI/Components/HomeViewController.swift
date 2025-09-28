//
//  HomeViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Anchorage
import SwiftUI
import UIKit

class HomeViewController: UIViewController {
    private var homeViewModel: HomeViewModel?
    private var mainCoordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Home"

        // 创建SwiftUI视图并嵌入
        let homeView = HomeView()
        let hostingController = UIHostingController(rootView: homeView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // 使用 Anchorage 设置约束
        hostingController.view.topAnchor == view.safeAreaLayoutGuide.topAnchor
        hostingController.view.leadingAnchor == view.leadingAnchor
        hostingController.view.trailingAnchor == view.trailingAnchor
        hostingController.view.bottomAnchor == view.bottomAnchor
    }

    private func setupBindings() {
        homeViewModel = DependencyContainer.shared.resolve(HomeViewModel.self)
        mainCoordinator = DependencyContainer.shared.resolve(MainCoordinator.self)
    }

    private func loadData() {
        homeViewModel?.loadUser()
    }
}
