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
    let state: [String: CodableValue]
    let capabilities: [String]?
    let createdAt: Date?
    let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, type, state, capabilities
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }

    // 自定义解码器以处理不同类型的值
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        capabilities = try container.decodeIfPresent([String].self, forKey: .capabilities)
        createdAt = try? container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try? container.decodeIfPresent(Date.self, forKey: .updatedAt)

        // 解码状态字典，处理不同类型的值
        if let stateDictionary = try? container.decode([String: CodableValue].self, forKey: .state)
        {
            state = stateDictionary
        } else {
            state = [:]
        }
    }

    // 自定义编码器
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(capabilities, forKey: .capabilities)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(state, forKey: .state)
    }
}

// 可编码值类型，用于处理不同类型的值
enum CodableValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "无法解码值")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }

    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return String(value)
        case .double(let value):
            return String(value)
        case .bool(let value):
            return String(value)
        case .null:
            return nil
        }
    }

    var intValue: Int? {
        switch self {
        case .string(let value):
            return Int(value)
        case .int(let value):
            return value
        case .double(let value):
            return Int(value)
        case .bool(let value):
            return value ? 1 : 0
        case .null:
            return nil
        }
    }

    var doubleValue: Double? {
        switch self {
        case .string(let value):
            return Double(value)
        case .int(let value):
            return Double(value)
        case .double(let value):
            return value
        case .bool(let value):
            return value ? 1.0 : 0.0
        case .null:
            return nil
        }
    }

    var boolValue: Bool? {
        switch self {
        case .string(let value):
            return Bool(value)
        case .int(let value):
            return value != 0
        case .double(let value):
            return value != 0.0
        case .bool(let value):
            return value
        case .null:
            return nil
        }
    }
}
