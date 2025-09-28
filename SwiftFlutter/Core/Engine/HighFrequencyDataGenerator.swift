//
//  HighFrequencyDataGenerator.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import Foundation

/// 高频数据生成器，用于生成模拟传感器数据
class HighFrequencyDataGenerator: NSObject {
    private var timer: Timer?
    private var displayLink: CADisplayLink?
    private var frequency: TimeInterval = 0.1  // 默认100ms
    private var eventSink: FlutterEventSink?
    private var isRunning = false

    /// 启动数据生成器
    /// - Parameters:
    ///   - frequencyMs: 频率（毫秒）
    ///   - eventSink: Flutter事件接收器
    func start(frequencyMs: Int, eventSink: @escaping FlutterEventSink) {
        guard !isRunning else { return }

        self.eventSink = eventSink
        self.frequency = TimeInterval(frequencyMs) / 1000.0
        self.isRunning = true

        // 使用CADisplayLink可以获得更精确的定时
        displayLink = CADisplayLink(target: self, selector: #selector(generateData))
        displayLink?.preferredFramesPerSecond = Int(1.0 / self.frequency)
        displayLink?.add(to: .main, forMode: .common)
    }

    /// 停止数据生成器
    func stop() {
        guard isRunning else { return }

        displayLink?.invalidate()
        displayLink = nil
        timer?.invalidate()
        timer = nil
        eventSink = nil
        isRunning = false
    }

    /// 生成数据并发送到Flutter
    @objc private func generateData() {
        guard let eventSink = eventSink, isRunning else { return }

        // 生成模拟传感器数据（随机数或正弦波数据）
        let timestamp = Date().timeIntervalSince1970
        let value = sin(timestamp)  // 使用正弦波数据作为示例

        // 创建数据字典
        let data: [String: Any] = [
            "timestamp": timestamp,
            "value": value,
            "frequency": Int(1.0 / frequency),
        ]

        // 发送数据到Flutter
        eventSink(data)
    }

    /// 启动/停止控制
    /// - Parameter isRunning: 是否运行
    func setRunning(_ isRunning: Bool) {
        if isRunning {
            // 重新启动需要eventSink，这里只是设置状态
            self.isRunning = true
        } else {
            stop()
        }
    }

    deinit {
        stop()
    }
}
