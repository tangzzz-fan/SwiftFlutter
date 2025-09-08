//
//  HomeViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

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

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupBindings() {
        homeViewModel = DependencyContainer.shared.resolve(HomeViewModel.self)
        mainCoordinator = DependencyContainer.shared.resolve(MainCoordinator.self)
    }

    private func loadData() {
        homeViewModel?.loadUser()
    }
}
