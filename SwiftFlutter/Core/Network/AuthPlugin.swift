//
//  AuthPlugin.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation
import Moya

/// 认证插件，自动为需要认证的请求添加Authorization头
struct AuthPlugin: PluginType {

    /// 准备请求，在发送前修改请求
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        // 检查是否是智能家居API
        guard let smartHomeTarget = target as? SmartHomeAPI else {
            return request
        }

        // 为需要认证的API添加Authorization头
        switch smartHomeTarget {
        case .getDevices, .updateDeviceState, .getDeviceDetails, .getUserProfile,
            .updateUserProfile:
            var modifiedRequest = request
            if let token = AuthManager.shared.currentAuthToken {
                modifiedRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            return modifiedRequest
        default:
            return request
        }
    }
}
