//
//  UserService.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Combine
import Foundation

protocol UserServiceProtocol {
    func fetchUser() -> AnyPublisher<User, Error>
    func saveUser(_ user: User) -> AnyPublisher<Void, Error>
}

class UserService: UserServiceProtocol {
    private let networking: Networking

    init(networking: Networking) {
        self.networking = networking
    }

    func fetchUser() -> AnyPublisher<User, Error> {
        // 模拟网络请求
        guard let url = URL(string: "https://api.example.com/user") else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        return networking.request(url: url, type: User.self)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func saveUser(_ user: User) -> AnyPublisher<Void, Error> {
        // 模拟保存用户
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
