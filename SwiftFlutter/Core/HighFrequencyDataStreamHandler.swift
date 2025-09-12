//
//  HighFrequencyDataStreamHandler.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import Foundation

class HighFrequencyDataStreamHandler: NSObject, FlutterStreamHandler {
    private var dataGenerator: Timer?
    private var eventSink: FlutterEventSink?
    private var isGenerating = false
    
    func sendData(_ data: [String: Any], completion: @escaping (Bool, Double) -> Void) {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 发送数据到Flutter
        eventSink?(data)
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let latency = (endTime - startTime) * 1000 // 转换为毫秒
        
        // 模拟成功发送
        completion(true, latency)
    }
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        startDataGeneration()
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopDataGeneration()
        self.eventSink = nil
        return nil
    }
    
    private func startDataGeneration() {
        guard !isGenerating else { return }
        
        isGenerating = true
        dataGenerator = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] _ in
            self?.generateData()
        }
    }
    
    private func stopDataGeneration() {
        isGenerating = false
        dataGenerator?.invalidate()
        dataGenerator = nil
    }
    
    private func generateData() {
        let timestamp = Date().timeIntervalSince1970
        let value = sin(timestamp * 10) * 100 + Double.random(in: -10...10)
        
        let data: [String: Any] = [
            "timestamp": timestamp,
            "value": value,
            "type": "sensor_data"
        ]
        
        eventSink?(data)
    }
}