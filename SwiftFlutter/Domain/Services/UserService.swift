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
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchUser() -> AnyPublisher<User, Error> {
        // 使用APIClient调用真实的用户API
        return apiClient.request(.getUserProfile, responseType: User.self)
            .mapError { $0.asError }
            .eraseToAnyPublisher()
    }

    func saveUser(_ user: User) -> AnyPublisher<Void, Error> {
        // 构造用户资料更新参数
        let profile: [String: Any] = [
            "name": user.name,
            "email": user.email,
            "avatarURL": user.avatarURL ?? ""
        ]
        
        // 使用APIClient调用更新用户资料API
        return apiClient.request(.updateUserProfile(profile: profile))
            .mapError { $0.asError }
            .eraseToAnyPublisher()
    }
}
