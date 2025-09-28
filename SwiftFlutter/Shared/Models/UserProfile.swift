//
//  UserProfile.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation

/// 用户资料模型
struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?
    let preferences: [String: Any]?

    enum CodingKeys: String, CodingKey {
        case id, name, email, avatarURL, preferences
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        avatarURL = try container.decodeIfPresent(String.self, forKey: .avatarURL)

        // 解码偏好设置字典
        if let preferencesData = try? container.decode(Data.self, forKey: .preferences) {
            preferences =
                (try? JSONSerialization.jsonObject(with: preferencesData) as? [String: Any]) ?? [:]
        } else {
            preferences = [:]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(avatarURL, forKey: .avatarURL)

        // 编码偏好设置字典
        if let preferences = preferences {
            let preferencesData = try JSONSerialization.data(withJSONObject: preferences)
            try container.encode(preferencesData, forKey: .preferences)
        }
    }
}
