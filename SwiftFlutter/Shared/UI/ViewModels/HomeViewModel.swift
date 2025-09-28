//
//  HomeViewModel.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Combine
import Foundation

enum HomeRoute {
    case userProfile(User)
    case settings
}

class HomeViewModel: ViewModel {
    typealias Route = HomeRoute

    @Published var user: User?
    @Published var isLoading = false

    private let userService: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(userService: UserServiceProtocol) {
        self.userService = userService
    }

    func loadUser() {
        isLoading = true
        userService.fetchUser()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("Failed to load user: \(error)")
                    }
                },
                receiveValue: { [weak self] user in
                    self?.user = user
                }
            )
            .store(in: &cancellables)
    }

    func navigate(to route: HomeRoute) {
        // 处理导航逻辑
        switch route {
        case .userProfile(let user):
            print("Navigating to user profile: \(user.name)")
        case .settings:
            print("Navigating to settings")
        }
    }
}
