//
//  AuthResponse.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Foundation

/// 认证响应模型
struct AuthResponse: Codable {
    let token: String
    let user: BackendUser
    
    /// 后端用户模型
    struct BackendUser: Codable {
        let userId: String
        let email: String
        let username: String
    }
    
    // 转换为本地User模型的便捷属性
    var localUser: User {
        return User(
            id: user.userId,
            name: user.username,
            email: user.email,
            avatarURL: nil
        )
    }
}

