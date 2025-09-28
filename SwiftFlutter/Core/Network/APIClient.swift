//
//  APIClient.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Combine
import Foundation
import Moya

/// 统一的API客户端，基于Moya封装，简化网络调用
class APIClient {
    static let shared = APIClient()
    
    private let provider: MoyaProvider<SmartHomeAPI>
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // 配置Provider with plugins
        self.provider = MoyaProvider<SmartHomeAPI>(
            plugins: [AuthPlugin()]
        )
    }
    
    // MARK: - Generic Request Methods
    
    /// 通用请求方法，返回解析后的模型
    func request<T: Codable>(
        _ target: SmartHomeAPI,
        responseType: T.Type
    ) -> AnyPublisher<T, APIError> {
        return Future<T, APIError> { promise in
            self.provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // 检查HTTP状态码
                        guard (200...299).contains(response.statusCode) else {
                            if response.statusCode == 401 {
                                promise(.failure(.unauthorized))
                            } else {
                                promise(.failure(.httpError(response.statusCode)))
                            }
                            return
                        }
                        
                        // 解析JSON
                        let decoder = self.createJSONDecoder()
                        let result = try decoder.decode(T.self, from: response.data)
                        promise(.success(result))
                        
                    } catch {
                        promise(.failure(.decodingError(error)))
                    }
                    
                case .failure(let moyaError):
                    promise(.failure(.networkError(moyaError)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// 请求方法，返回APIResponse包装的模型
    func requestWithAPIResponse<T: Codable>(
        _ target: SmartHomeAPI,
        dataType: T.Type
    ) -> AnyPublisher<APIResponse<T>, APIError> {
        return request(target, responseType: APIResponse<T>.self)
            .tryMap { response in
                guard response.success else {
                    throw APIError.apiError(response.message ?? "未知API错误")
                }
                return response
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
    /// 通用请求方法，不返回数据
    func request(_ target: SmartHomeAPI) -> AnyPublisher<Void, APIError> {
        return Future<Void, APIError> { promise in
            self.provider.request(target) { result in
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        promise(.success(()))
                    } else {
                        promise(.failure(.httpError(response.statusCode)))
                    }
                case .failure(let error):
                    promise(.failure(.networkError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Authentication APIs
    
    /// 用户登录
    func login(email: String, password: String) -> AnyPublisher<AuthResponse, APIError> {
        return Future<AuthResponse, APIError> { promise in
            self.provider.request(.login(email: email, password: password)) { result in
                switch result {
                case .success(let response):
                    do {
                        // 检查HTTP状态码
                        guard (200...299).contains(response.statusCode) else {
                            if response.statusCode == 401 {
                                promise(.failure(.unauthorized))
                            } else {
                                promise(.failure(.httpError(response.statusCode)))
                            }
                            return
                        }
                        
                        // 直接解析AuthResponse（不包装在APIResponse中）
                        let authResponse = try JSONDecoder().decode(AuthResponse.self, from: response.data)
                        promise(.success(authResponse))
                    } catch {
                        promise(.failure(.decodingError(error)))
                    }
                case .failure(let error):
                    promise(.failure(.networkError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 获取当前用户信息
    func getCurrentUser() -> AnyPublisher<APIResponse<User>, APIError> {
        return requestWithAPIResponse(.getUserProfile, dataType: User.self)
    }
    
    // MARK: - Device APIs
    
    /// 获取设备列表
    func getDevices() -> AnyPublisher<[Device], APIError> {
        return requestWithAPIResponse(.getDevices, dataType: DeviceListResponse.self)
            .map { response in
                return response.data?.devices ?? []
            }
            .eraseToAnyPublisher()
    }
    
    /// 获取设备详情
    func getDeviceDetails(id: String) -> AnyPublisher<Device, APIError> {
        return requestWithAPIResponse(.getDeviceDetails(id: id), dataType: DeviceResponse.self)
            .tryMap { response in
                guard let device = response.data?.device else {
                    throw APIError.apiError("设备数据为空")
                }
                return device
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
    /// 更新设备状态
    func updateDeviceState(id: String, state: [String: Any]) -> AnyPublisher<Device, APIError> {
        return requestWithAPIResponse(.updateDeviceState(id: id, state: state), dataType: DeviceResponse.self)
            .tryMap { response in
                guard let device = response.data?.device else {
                    throw APIError.apiError("设备数据为空")
                }
                return device
            }
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.unknown(error)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    /// 创建JSON解码器
    private func createJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

// MARK: - API Error Enum

enum APIError: Error, LocalizedError {
    case networkError(MoyaError)
    case decodingError(Error)
    case httpError(Int)
    case unauthorized
    case apiError(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let moyaError):
            return "网络错误: \(moyaError.localizedDescription)"
        case .decodingError(let error):
            return "数据解析错误: \(error.localizedDescription)"
        case .httpError(let code):
            return "HTTP错误: \(code)"
        case .unauthorized:
            return "认证失败，请重新登录"
        case .apiError(let message):
            return "API错误: \(message)"
        case .unknown(let error):
            return "未知错误: \(error.localizedDescription)"
        }
    }
    
    /// 转换为Error类型
    var asError: Error {
        return self as Error
    }
}

// MARK: - Convenience Extensions

extension APIClient {
    /// 快速登录方法，自动保存token
    func loginAndSaveToken(email: String, password: String) -> AnyPublisher<User, APIError> {
        return login(email: email, password: password)
            .map { authResponse in
                AuthManager.shared.saveTokens(
                    authToken: authResponse.token,
                    refreshToken: authResponse.token
                )
                return authResponse.localUser
            }
            .eraseToAnyPublisher()
    }
}
