//
//  DependencyContainer.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Swinject

final class DependencyContainer {
    static let shared = DependencyContainer()
    private let container = Container()

    private init() {
        registerDependencies()
    }

    func resolve<T>(_ serviceType: T.Type) -> T? {
        return container.resolve(serviceType)
    }

    private func registerDependencies() {
        // 注册核心依赖
        registerNetworking()
        registerServices()
        registerViewModels()
        registerCoordinators()
        registerFlutterIntegration()
    }

    private func registerNetworking() {
        // 注册网络服务
        container.register(Networking.self) { _ in
            NetworkManager()
        }.inObjectScope(.container)
    }

    private func registerServices() {
        // 注册业务服务
        container.register(UserService.self) { r in
            UserService(networking: r.resolve(Networking.self)!)
        }.inObjectScope(.container)
    }

    private func registerViewModels() {
        // 注册ViewModels
        container.register(HomeViewModel.self) { r in
            HomeViewModel(userService: r.resolve(UserService.self)!)
        }
    }

    private func registerCoordinators() {
        // 注册协调器
        container.register(MainCoordinator.self) { _ in
            MainCoordinator()
        }
    }

    private func registerFlutterIntegration() {
        // 注册Flutter集成相关组件
        container.register(FlutterEngineManager.self) { _ in
            FlutterEngineManager.shared
        }.inObjectScope(.container)
    }
}
