//
//  AuthManager.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Combine
import Foundation

/// 认证管理器，用于管理用户认证Token
class AuthManager: AuthManagerProtocol {
    static let shared = AuthManager()

    private let keychainManager = KeychainManager.shared

    // Token相关的键名
    private let authTokenKey = "auth_token"
    private let refreshTokenKey = "refresh_token"

    private init() {}

    /// 当前认证Token
    var currentAuthToken: String? {
        return keychainManager.get(key: authTokenKey)
    }

    /// 当前刷新Token
    var currentRefreshToken: String? {
        return keychainManager.get(key: refreshTokenKey)
    }

    /// 保存Tokens到Keychain
    /// - Parameters:
    ///   - authToken: 认证Token
    ///   - refreshToken: 刷新Token
    func saveTokens(authToken: String, refreshToken: String) {
        keychainManager.save(key: authTokenKey, value: authToken)
        keychainManager.save(key: refreshTokenKey, value: refreshToken)
    }

    /// 清除Tokens
    func clearTokens() {
        keychainManager.delete(key: authTokenKey)
        keychainManager.delete(key: refreshTokenKey)
    }

    /// 尝试刷新Token
    /// - Parameter completion: 完成回调，参数表示是否刷新成功
    func tryRefreshToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = currentRefreshToken else {
            completion(false)
            return
        }

        // 模拟Token刷新过程
        // 在实际应用中，这里应该调用刷新Token的API
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // 模拟网络请求成功
            let newAuthToken = "new_auth_token_\(UUID().uuidString)"
            let newRefreshToken = "new_refresh_token_\(UUID().uuidString)"

            // 保存新的Tokens
            self.saveTokens(authToken: newAuthToken, refreshToken: newRefreshToken)

            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}
