//
//  RetryAndAuthPlugin.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation
import Moya

/// 重试和认证插件，拦截401错误并尝试刷新Token
struct RetryAndAuthPlugin: PluginType {
    // 用于跟踪哪些请求已经尝试过刷新Token，避免无限重试
    private static var retriedRequests: Set<String> = []

    /// 在收到响应后调用
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        // 检查是否是智能家居API
        guard let smartHomeTarget = target as? SmartHomeAPI else {
            return
        }

        // 检查是否是401错误
        if case .success(let response) = result, response.statusCode == 401 {
            let requestKey =
                "\(target.method.rawValue) \(target.baseURL.absoluteString)\(target.path)"

            // 检查是否已经尝试过刷新Token
            if !RetryAndAuthPlugin.retriedRequests.contains(requestKey) {
                // 标记该请求已经尝试过刷新Token
                RetryAndAuthPlugin.retriedRequests.insert(requestKey)

                // 尝试刷新Token
                AuthManager.shared.tryRefreshToken { success in
                    if success {
                        // 刷新成功，可以重试原请求
                        print("Token refreshed successfully")
                    } else {
                        // 刷新失败，清除Tokens并通知用户需要重新登录
                        AuthManager.shared.clearTokens()
                        print("Token refresh failed, user needs to login again")
                        // 这里可以发送通知给跨平台层，通知用户需要重新登录
                    }

                    // 移除请求标记
                    RetryAndAuthPlugin.retriedRequests.remove(requestKey)
                }
            }
        }
    }
}
