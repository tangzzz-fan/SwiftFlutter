//
//  PreferencesManager.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation

/// 用户偏好设置管理器，用于存储非敏感数据
class PreferencesManager {
    static let shared = PreferencesManager()

    private let userDefaults = UserDefaults.standard

    private init() {}

    /// 保存数据到UserDefaults
    /// - Parameters:
    ///   - key: 键
    ///   - value: 值
    func save(key: String, value: Any) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }

    /// 从UserDefaults读取数据
    /// - Parameter key: 键
    /// - Returns: 值，如果不存在则返回nil
    func get(key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }

    /// 从UserDefaults删除数据
    /// - Parameter key: 键
    func delete(key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
}
