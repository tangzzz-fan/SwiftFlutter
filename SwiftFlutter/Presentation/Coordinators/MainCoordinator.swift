//
//  MainCoordinator.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import UIKit

class MainCoordinator: Coordinator {
    weak var navigationController: UINavigationController?
    var tabBarController: UITabBarController?

    init() {
    }

    func start() {
        // 创建标签栏控制器
        tabBarController = UITabBarController()

        // 初始化各个tab的视图控制器
        setupTabBar()
    }

    private func setupTabBar() {
        guard let tabBarController = self.tabBarController else { return }

        // 创建各个tab的导航控制器
        let deviceNavController = createDeviceNavigationController()
        let wmallNavController = createWMallNavigationController()
        let omallNavController = createOMallNavigationController()
        let performanceNavController = createPerformanceNavigationController()
        let profileNavController = createProfileNavigationController()

        // 设置标签栏项
        deviceNavController.tabBarItem = UITabBarItem(title: "设备", image: nil, tag: 0)
        wmallNavController.tabBarItem = UITabBarItem(title: "WMall", image: nil, tag: 1)
        omallNavController.tabBarItem = UITabBarItem(title: "OMall", image: nil, tag: 2)
        performanceNavController.tabBarItem = UITabBarItem(title: "性能优化", image: nil, tag: 3)
        profileNavController.tabBarItem = UITabBarItem(title: "个人中心", image: nil, tag: 4)

        // 设置标签栏控制器的视图控制器数组
        tabBarController.viewControllers = [
            deviceNavController,
            wmallNavController,
            omallNavController,
            performanceNavController,
            profileNavController,
        ]
    }

    // 创建设备tab的导航控制器
    private func createDeviceNavigationController() -> UINavigationController {
        let deviceCategoryViewController = DeviceCategoryViewController()
        let navigationController = UINavigationController(
            rootViewController: deviceCategoryViewController)
        return navigationController
    }

    // 创建WMalltab的导航控制器
    private func createWMallNavigationController() -> UINavigationController {
        let wmallViewController = UIViewController()
        wmallViewController.view.backgroundColor = .systemBackground
        wmallViewController.title = "WMall"

        let label = UILabel()
        label.text = "WMall Tab"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        wmallViewController.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: wmallViewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: wmallViewController.view.centerYAnchor),
        ])

        let navigationController = UINavigationController(rootViewController: wmallViewController)
        return navigationController
    }

    // 创建OMalltab的导航控制器
    private func createOMallNavigationController() -> UINavigationController {
        let omallViewController = UIViewController()
        omallViewController.view.backgroundColor = .systemBackground
        omallViewController.title = "OMall"

        let label = UILabel()
        label.text = "OMall Tab"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        omallViewController.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: omallViewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: omallViewController.view.centerYAnchor),
        ])

        let navigationController = UINavigationController(rootViewController: omallViewController)
        return navigationController
    }

    // 创建性能优化tab的导航控制器
    private func createPerformanceNavigationController() -> UINavigationController {
        let networkTestViewController = NetworkTestViewController()
        let navigationController = UINavigationController(
            rootViewController: networkTestViewController)
        return navigationController
    }

    // 创建个人中心tab的导航控制器
    private func createProfileNavigationController() -> UINavigationController {
        // 个人中心使用Flutter模块
        guard
            let flutterEngine = DependencyContainer.shared.resolve(FlutterEngineManager.self)?
                .getEngine(forKey: "main")
        else {
            print("Flutter engine not available")

            // 如果Flutter引擎不可用，创建一个简单的原生视图控制器
            let profileViewController = UIViewController()
            profileViewController.view.backgroundColor = .systemBackground
            profileViewController.title = "个人中心"

            let label = UILabel()
            label.text = "个人中心 Tab (Flutter引擎不可用)"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            profileViewController.view.addSubview(label)

            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: profileViewController.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: profileViewController.view.centerYAnchor),
            ])

            let navigationController = UINavigationController(
                rootViewController: profileViewController)
            return navigationController
        }

        let flutterViewController = CustomFlutterViewController(
            engine: flutterEngine, nibName: nil, bundle: nil)
        flutterViewController.title = "个人中心"

        let navigationController = UINavigationController(rootViewController: flutterViewController)
        // 默认隐藏导航栏
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }

    func navigate(to route: String, with data: Any?) {

    }

    private func getCurrentNavigationController() -> UINavigationController? {
        guard let tabBarController = self.tabBarController else { return nil }
        return tabBarController.selectedViewController as? UINavigationController
    }

    private func navigateToFlutterModule() {
        // 导航到Flutter模块的实现
        guard
            let flutterEngine = DependencyContainer.shared.resolve(FlutterEngineManager.self)?
                .getEngine(forKey: "main")
        else {
            print("Flutter engine not available")
            return
        }

        let flutterViewController = CustomFlutterViewController(
            engine: flutterEngine, nibName: nil, bundle: nil)
        flutterViewController.modalPresentationStyle = .fullScreen
        getCurrentNavigationController()?.present(flutterViewController, animated: true)
    }
}
