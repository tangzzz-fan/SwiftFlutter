//
//  APIResponse.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Foundation

/// 通用API响应模型
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let message: String?
    let data: T?
    let errorCode: Int?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case data
        case errorCode = "error_code"
    }
}
