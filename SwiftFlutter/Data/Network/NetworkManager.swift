//
//  NetworkManager.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Combine
import Foundation

class NetworkManager: Networking {
    func request<T: Decodable>(url: URL, type: T.Type) -> AnyPublisher<T, NetworkError> {
        return URLSession.shared
            .dataTaskPublisher(for: URLRequest(url: url))
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                switch error {
                case is URLError:
                    return NetworkError.invalidURL
                case is DecodingError:
                    return NetworkError.decodingError
                default:
                    return NetworkError.noData
                }
            }
            .eraseToAnyPublisher()
    }
}
