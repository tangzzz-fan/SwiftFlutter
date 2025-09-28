//
//  FlutterEngineManager.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import Foundation

enum EngineState {
    case idle
    case active
    case paused
}

struct EngineInfo {
    let key: String
    let engine: FlutterEngine
    let state: EngineState
    let createdAt: Date
}

class FlutterEngineManager {
    static let shared = FlutterEngineManager()

    private var engines: [String: EngineInfo] = [:]
    private let engineGroup: FlutterEngineGroup

    private init() {
        // 初始化Flutter引擎组
        engineGroup = FlutterEngineGroup(name: "flutter_engine_group", project: nil)
    }

    /// 添加引擎到管理器
    func addEngine(forKey key: String, engine: FlutterEngine) {
        let engineInfo = EngineInfo(
            key: key,
            engine: engine,
            state: .active,
            createdAt: Date()
        )

        engines[key] = engineInfo
    }

    /// 创建或获取Flutter引擎
    func getEngine(forKey key: String) -> FlutterEngine? {
        if let engineInfo = engines[key] {
            return engineInfo.engine
        }

        // 创建新引擎
        let engine = engineGroup.makeEngine(withEntrypoint: nil, libraryURI: nil)
        engine.run()

        // 添加到管理器
        addEngine(forKey: key, engine: engine)

        return engine
    }

    /// 释放指定的引擎
    func releaseEngine(forKey key: String) {
        engines.removeValue(forKey: key)
    }

    /// 暂停引擎
    func pauseEngine(forKey key: String) {
        guard let engineInfo = engines[key] else { return }

        let updatedInfo = EngineInfo(
            key: engineInfo.key,
            engine: engineInfo.engine,
            state: .paused,
            createdAt: engineInfo.createdAt
        )

        engines[key] = updatedInfo
    }

    /// 恢复引擎
    func resumeEngine(forKey key: String) {
        guard let engineInfo = engines[key] else { return }

        let updatedInfo = EngineInfo(
            key: engineInfo.key,
            engine: engineInfo.engine,
            state: .active,
            createdAt: engineInfo.createdAt
        )

        engines[key] = updatedInfo
    }

    /// 获取所有引擎信息
    func getAllEngineInfo() -> [EngineInfo] {
        return Array(engines.values)
    }
}