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

        // 创建各个技术栈tab的导航控制器
        let nativeTabNavController = createNativeTabNavController()
        let reactNativeTabNavController = createReactNativeTabNavController()
        let hybridTabNavController = createHybridTabNavController()
        let flutterTabNavController = createFlutterTabNavController()
        let performanceTabNavController = createPerformanceTabNavController()

        // 设置标签栏项
        nativeTabNavController.tabBarItem = UITabBarItem(title: "Native", image: UIImage(systemName: "swift"), tag: 0)
        hybridTabNavController.tabBarItem = UITabBarItem(title: "Hybrid", image: UIImage(systemName: "globe"), tag: 2)
        flutterTabNavController.tabBarItem = UITabBarItem(title: "Flutter", image: UIImage(systemName: "bird"), tag: 3)
        reactNativeTabNavController.tabBarItem = UITabBarItem(title: "React Native", image: UIImage(systemName: "atom"), tag: 1)
        performanceTabNavController.tabBarItem = UITabBarItem(title: "Performance", image: UIImage(systemName: "speedometer"), tag: 4)

        // 设置标签栏控制器的视图控制器数组
        tabBarController.viewControllers = [
            nativeTabNavController,
            hybridTabNavController,
            flutterTabNavController,
            reactNativeTabNavController,
            performanceTabNavController
        ]
    }

    // MARK: - Tab Creation Methods
    
    private func createNativeTabNavController() -> UINavigationController {
        let nativeViewController = DemoListViewController(demoType: .native)
        let navController = UINavigationController(rootViewController: nativeViewController)
        return navController
    }
    
    private func createHybridTabNavController() -> UINavigationController {
        let hybridViewController = DemoListViewController(demoType: .hybrid)
        let navController = UINavigationController(rootViewController: hybridViewController)
        return navController
    }
    
    private func createFlutterTabNavController() -> UINavigationController {
        // 确保 Flutter 引擎已初始化
        guard let flutterEngine = DependencyContainer.shared.resolve(FlutterEngineManager.self)?.getEngine(forKey: "main") else {
            // 如果Flutter引擎不可用，创建一个错误页面
            let errorViewController = UIViewController()
            errorViewController.view.backgroundColor = .systemGroupedBackground
            errorViewController.title = "Flutter"
            
            let errorLabel = UILabel()
            errorLabel.text = "Flutter引擎不可用"
            errorLabel.textAlignment = .center
            errorLabel.textColor = .systemRed
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            errorViewController.view.addSubview(errorLabel)
            
            NSLayoutConstraint.activate([
                errorLabel.centerXAnchor.constraint(equalTo: errorViewController.view.centerXAnchor),
                errorLabel.centerYAnchor.constraint(equalTo: errorViewController.view.centerYAnchor)
            ])
            
            let navController = UINavigationController(rootViewController: errorViewController)
            return navController
        }
        
        // 直接创建 Flutter 视图控制器
        let flutterViewController = CustomFlutterViewController(
            engine: flutterEngine,
            nibName: nil,
            bundle: nil
        )
        
        flutterViewController.title = "Flutter"
        let navController = UINavigationController(rootViewController: flutterViewController)
        return navController
    }

    private func createReactNativeTabNavController() -> UINavigationController {
        // 不在这里初始化bridge，让ReactNativeViewController自己处理
        // ReactNativeBridgeManager.shared.initializeBridge()
        
        // 直接创建 React Native 视图控制器
        let reactNativeViewController = ReactNativeViewController(
            moduleName: "SmartHomeApp",
            initialProps: [
                "screenType": "demoList",
                "demoType": "reactNative"
            ]
        )
        
        reactNativeViewController.title = "React Native"
        let navController = UINavigationController(rootViewController: reactNativeViewController)
        return navController
    }
    
    private func createPerformanceTabNavController() -> UINavigationController {
        let performanceViewController = PerformanceTestViewController()
        let navController = UINavigationController(rootViewController: performanceViewController)
        return navController
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
