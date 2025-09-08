//
//  Networking.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Combine
import Foundation

protocol Networking {
    func request<T: Decodable>(url: URL, type: T.Type) -> AnyPublisher<T, NetworkError>
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .httpError(let code):
            return "HTTP error with code: \(code)"
        }
    }
}
