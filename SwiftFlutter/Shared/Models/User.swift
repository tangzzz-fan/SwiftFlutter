//
//  User.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case name = "username"
        case email
        case avatarURL
    }
}
