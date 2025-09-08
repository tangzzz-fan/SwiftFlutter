//
//  SmartHomeAPI.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation
import Moya

/// 智能家居API枚举，包含所有RESTful API的Target
enum SmartHomeAPI {
    case login(email: String, password: String)
    case getDevices
    case updateDeviceState(id: String, state: [String: Any])
    case getDeviceDetails(id: String)
    case getUserProfile
    case updateUserProfile(profile: [String: Any])
}

extension SmartHomeAPI: TargetType {
    /// API基础URL
    var baseURL: URL {
        // 使用本地服务器地址，后端运行在3001端口
        return URL(string: "http://localhost:3001/api")!
    }

    /// 各个API的具体路径
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .getDevices:
            return "/devices"
        case .updateDeviceState(let id, _):
            return "/devices/\(id)/state"
        case .getDeviceDetails(let id):
            return "/devices/\(id)"
        case .getUserProfile:
            return "/auth/me"
        case .updateUserProfile:
            return "/user/profile"
        }
    }

    /// HTTP方法
    var method: Moya.Method {
        switch self {
        case .login, .updateDeviceState, .updateUserProfile:
            return .post
        case .getDevices, .getDeviceDetails, .getUserProfile:
            return .get
        }
    }

    /// 任务（请求体）
    var task: Task {
        switch self {
        case .login(let email, let password):
            return .requestParameters(
                parameters: ["email": email, "password": password],
                encoding: JSONEncoding.default
            )
        case .updateDeviceState(_, let state):
            // 将[Any]类型的state转换为可编码的[String: Any]类型
            var encodableState: [String: Any] = [:]
            for (key, value) in state {
                if let codableValue = value as? Codable {
                    encodableState[key] = value
                } else {
                    // 尝试转换为字符串
                    encodableState[key] = "\(value)"
                }
            }
            return .requestParameters(
                parameters: encodableState,
                encoding: JSONEncoding.default
            )
        case .updateUserProfile(let profile):
            return .requestParameters(
                parameters: profile,
                encoding: JSONEncoding.default
            )
        default:
            return .requestPlain
        }
    }

    /// 默认请求头
    var headers: [String: String]? {
        // 只设置Content-Type，Authorization头由AuthPlugin处理
        return ["Content-Type": "application/json"]
    }

    /// 用于单元测试的模拟数据
    var sampleData: Data {
        return Data()
    }
}
