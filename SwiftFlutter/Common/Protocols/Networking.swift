//
//  Networking.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Combine
import Foundation

// MARK: - 协议定义
protocol MQTTManagerProtocol {
    func connect(host: String, port: UInt16, clientID: String)
    func disconnect()
    func subscribe(topic: String, qos: Int)
    func unsubscribe(topic: String)
    func publish(topic: String, message: String, qos: Int)
    func setConnectionStatusCallback(_ callback: @escaping (String) -> Void)
    func setMessageCallback(_ callback: @escaping (String, String) -> Void)
}

protocol WebSocketManagerProtocol {
    func connect(url: URL, headers: [String: String]?)
    func disconnect()
    func send(message: String)
    func setConnectionStatusCallback(_ callback: @escaping (String) -> Void)
    func setMessageCallback(_ callback: @escaping (String) -> Void)
}

protocol AuthManagerProtocol {
    var currentAuthToken: String? { get }
    func saveTokens(authToken: String, refreshToken: String)
    func clearTokens()
}

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
