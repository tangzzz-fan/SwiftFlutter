//
//  Device.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation

/// 设备模型
struct Device: Codable {
    let id: String
    let name: String
    let type: String
    let state: [String: Any]
    let capabilities: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, type, state, capabilities
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        capabilities = try container.decodeIfPresent([String].self, forKey: .capabilities)

        // 解码状态字典
        if let stateData = try? container.decode(Data.self, forKey: .state) {
            state = (try? JSONSerialization.jsonObject(with: stateData) as? [String: Any]) ?? [:]
        } else {
            state = [:]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(capabilities, forKey: .capabilities)

        // 编码状态字典
        let stateData = try JSONSerialization.data(withJSONObject: state)
        try container.encode(stateData, forKey: .state)
    }
}
