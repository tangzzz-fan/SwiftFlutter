//
//  NetworkProvider.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Combine
import Foundation
import Moya

/// 网络提供者，封装Moya Provider
class NetworkProvider {
    static let shared = NetworkProvider()

    private let provider: MoyaProvider<SmartHomeAPI>

    private init() {
        // 实例化MoyaProvider，传入AuthPlugin和RetryAndAuthPlugin
        self.provider = MoyaProvider<SmartHomeAPI>(
            plugins: [AuthPlugin(), RetryAndAuthPlugin()]
        )
    }

    /// 发起网络请求
    /// - Parameters:
    ///   - target: API目标
    ///   - completion: 完成回调
    func request(
        target: SmartHomeAPI,
        completion: @escaping (Result<Moya.Response, MoyaError>) -> Void
    ) {
        provider.request(target, completion: completion)
    }

    /// 发起网络请求并返回AnyPublisher
    /// - Parameter target: API目标
    /// - Returns: AnyPublisher
    func requestPublisher(target: SmartHomeAPI) -> AnyPublisher<Moya.Response, MoyaError> {
        return Future<Moya.Response, MoyaError> { promise in
            self.provider.request(target) { result in
                promise(result)
            }
        }.eraseToAnyPublisher()
    }

    /// 封装常用数据解析方法
    /// - Parameters:
    ///   - target: API目标
    ///   - type: 解析类型
    /// - Returns: AnyPublisher
    func request<T: Decodable>(
        target: SmartHomeAPI,
        type: T.Type
    ) -> AnyPublisher<T, Error> {
        return Future<Moya.Response, MoyaError> { promise in
            self.provider.request(target) { result in
                promise(result)
            }
        }
        .compactMap { $0.data }
        .decode(type: T.self, decoder: JSONDecoder())
        .eraseToAnyPublisher()
    }
}
