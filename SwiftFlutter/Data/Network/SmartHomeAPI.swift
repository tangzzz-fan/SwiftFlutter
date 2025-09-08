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
    case login(username: String, password: String)
    case getDevices
    case updateDeviceState(id: String, state: [String: Any])
    case getDeviceDetails(id: String)
    case getUserProfile
    case updateUserProfile(profile: [String: Any])
}

extension SmartHomeAPI: TargetType {
    /// API基础URL
    var baseURL: URL {
        return URL(string: "https://api.smarthome.example.com")!
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
            return "/user/profile"
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
        case .login(let username, let password):
            return .requestParameters(
                parameters: ["username": username, "password": password],
                encoding: JSONEncoding.default
            )
        case .updateDeviceState(_, let state):
            return .requestParameters(
                parameters: state,
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
        var headers = ["Content-Type": "application/json"]

        // 为需要认证的API添加Authorization头
        switch self {
        case .getDevices, .updateDeviceState, .getDeviceDetails, .getUserProfile,
            .updateUserProfile:
            if let token = AuthManager.shared.currentAuthToken {
                headers["Authorization"] = "Bearer \(token)"
            }
        default:
            break
        }

        return headers
    }

    /// 用于单元测试的模拟数据
    var sampleData: Data {
        switch self {
        case .login:
            return #"{"token": "sample_token", "refreshToken": "sample_refresh_token"}"#.data(
                using: .utf8)!
        case .getDevices:
            return
                #"{"devices": [{"id": "1", "name": "Light", "type": "light", "state": {"on": true}}]}"#
                .data(using: .utf8)!
        case .getDeviceDetails:
            return
                #"{"id": "1", "name": "Light", "type": "light", "state": {"on": true}, "capabilities": ["onOff"]}"#
                .data(using: .utf8)!
        case .getUserProfile:
            return #"{"id": "user1", "name": "John Doe", "email": "john@example.com"}"#.data(
                using: .utf8)!
        default:
            return Data()
        }
    }
}
