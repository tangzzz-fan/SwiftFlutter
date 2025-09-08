//
//  KeychainManager.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Foundation

/// 安全存储管理器，用于存储敏感数据如Token等
class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    /// 保存数据到Keychain
    /// - Parameters:
    ///   - key: 键
    ///   - value: 值
    /// - Returns: 是否保存成功
    @discardableResult
    func save(key: String, value: String) -> Bool {
        let data = value.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ]

        // 先删除已存在的项
        SecItemDelete(query as CFDictionary)

        // 添加新的项
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// 从Keychain读取数据
    /// - Parameter key: 键
    /// - Returns: 值，如果不存在则返回nil
    func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
            let data = result as? Data,
            let value = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return value
    }

    /// 从Keychain删除数据
    /// - Parameter key: 键
    /// - Returns: 是否删除成功
    @discardableResult
    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
