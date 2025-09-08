//
//  HighFrequencyDataStreamHandler.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import Foundation

/// 高频数据流处理器，实现FlutterStreamHandler协议
class HighFrequencyDataStreamHandler: NSObject, FlutterStreamHandler {
    private let dataGenerator = HighFrequencyDataGenerator()
    private var eventSink: FlutterEventSink?

    /// 当Flutter开始监听事件时调用
    /// - Parameters:
    ///   - arguments: 参数
    ///   - events: 事件接收器
    /// - Returns: 错误信息
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events

        // 启动数据生成计时器
        var frequencyMs = 100  // 默认100ms
        if let args = arguments as? [String: Any],
            let freq = args["frequency"] as? Int
        {
            frequencyMs = freq
        }

        dataGenerator.start(frequencyMs: frequencyMs, eventSink: events)
        return nil
    }

    /// 当Flutter取消监听事件时调用
    /// - Parameter arguments: 参数
    /// - Returns: 错误信息
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        // 停止计时器，清理资源
        dataGenerator.stop()
        self.eventSink = nil
        return nil
    }

    /// 启动数据生成器
    /// - Parameter frequencyMs: 频率（毫秒）
    func startDataGeneration(frequencyMs: Int) {
        guard let eventSink = self.eventSink else { return }
        dataGenerator.start(frequencyMs: frequencyMs, eventSink: eventSink)
    }

    /// 停止数据生成器
    func stopDataGeneration() {
        dataGenerator.stop()
    }
}
