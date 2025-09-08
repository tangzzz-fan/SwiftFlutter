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
    case decodingError(Error)
    case httpError(Int)
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let err):
            return "Failed to decode data: \(err.localizedDescription)"
        case .httpError(let code):
            return "HTTP error with code: \(code)"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
}
