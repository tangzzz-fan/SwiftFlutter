//
//  DeviceCategory.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Foundation

/// 设备分类模型
struct DeviceCategory {
    let id: String
    let name: String
    let description: String
    let iconName: String
    let deviceCount: Int
    
    /// 获取默认设备分类
    static func getDefaultCategories() -> [DeviceCategory] {
        return [
            DeviceCategory(
                id: "lighting",
                name: "照明设备",
                description: "智能灯泡、LED灯带等照明设备",
                iconName: "lightbulb.fill",
                deviceCount: 0
            ),
            DeviceCategory(
                id: "climate",
                name: "气候控制",
                description: "空调、暖气、风扇等温控设备",
                iconName: "thermometer",
                deviceCount: 0
            ),
            DeviceCategory(
                id: "security",
                name: "安全监控",
                description: "摄像头、门锁、传感器等安全设备",
                iconName: "shield.fill",
                deviceCount: 0
            ),
            DeviceCategory(
                id: "entertainment",
                name: "娱乐影音",
                description: "音响、电视、投影仪等娱乐设备",
                iconName: "speaker.wave.3.fill",
                deviceCount: 0
            ),
            DeviceCategory(
                id: "appliances",
                name: "家用电器",
                description: "洗衣机、冰箱、微波炉等家电设备",
                iconName: "house.fill",
                deviceCount: 0
            ),
            DeviceCategory(
                id: "network",
                name: "网络设备",
                description: "路由器、网关、中继器等网络设备",
                iconName: "wifi",
                deviceCount: 0
            ),
            DeviceCategory(
                id: "mqtt_test",
                name: "MQTT测试",
                description: "测试MQTT连接和通讯功能",
                iconName: "antenna.radiowaves.left.and.right",
                deviceCount: 0
            ),
            DeviceCategory(
                id: "websocket_test", 
                name: "WebSocket测试",
                description: "测试WebSocket连接和实时通讯",
                iconName: "globe",
                deviceCount: 0
            )
        ]
    }
}
