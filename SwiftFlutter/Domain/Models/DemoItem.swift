//
//  DemoItem.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/1/13.
//

import Foundation

/// Demo项目类型枚举
enum DemoType: String, CaseIterable {
    case native = "native"
    case hybrid = "hybrid"
    case flutter = "flutter"
}

/// Demo项目数据模型
struct DemoItem {
    let id: String
    let title: String
    let description: String
    let iconName: String?
    let demoType: DemoType
    let targetController: String? // 目标控制器类名
    let isAvailable: Bool // 是否可用
    
    init(
        id: String,
        title: String,
        description: String,
        iconName: String? = "app.fill",
        demoType: DemoType,
        targetController: String? = nil,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.demoType = demoType
        self.targetController = targetController
        self.isAvailable = isAvailable
    }
}

// MARK: - Demo数据提供者

/// 原生Demo提供者
struct NativeDemoProvider {
    static func getDefaultDemos() -> [DemoItem] {
        return [
            DemoItem(
                id: "audio_video",
                title: "音视频播放器",
                description: "展示原生音视频播放功能",
                iconName: "play.circle.fill",
                demoType: .native,
                targetController: "AudioVideoViewController"
            ),
            DemoItem(
                id: "network_test",
                title: "网络请求测试",
                description: "测试Moya网络请求功能",
                iconName: "network",
                demoType: .native,
                targetController: "NetworkTestViewController"
            ),
            DemoItem(
                id: "mqtt_test",
                title: "MQTT实时通信",
                description: "测试MQTT消息订阅发布",
                iconName: "antenna.radiowaves.left.and.right",
                demoType: .native,
                targetController: "MQTTTestViewController"
            ),
            DemoItem(
                id: "websocket_test",
                title: "WebSocket连接",
                description: "测试WebSocket实时通信",
                iconName: "globe.badge.chevron.backward",
                demoType: .native,
                targetController: "WebSocketTestViewController"
            ),
            DemoItem(
                id: "camera_demo",
                title: "相机调用",
                description: "展示原生相机功能",
                iconName: "camera.fill",
                demoType: .native,
                targetController: "CameraViewController"
            ),
            DemoItem(
                id: "sensor_data",
                title: "传感器数据",
                description: "获取设备传感器信息",
                iconName: "sensor.fill",
                demoType: .native,
                targetController: "SensorViewController"
            )
        ]
    }
}

/// Hybrid Demo提供者
struct HybridDemoProvider {
    static func getDefaultDemos() -> [DemoItem] {
        return [
            DemoItem(
                id: "hybrid_mall",
                title: "混合商城",
                description: "原生首页 + 跨平台商品详情",
                iconName: "cart.fill",
                demoType: .hybrid,
                targetController: "HybridMallViewController"
            ),
            DemoItem(
                id: "payment_flow",
                title: "支付流程",
                description: "原生安全支付 + 跨平台UI",
                iconName: "creditcard.fill",
                demoType: .hybrid,
                targetController: "HybridPaymentViewController"
            ),
            DemoItem(
                id: "native_rn_bridge",
                title: "原生-RN桥接",
                description: "展示原生与RN数据交互",
                iconName: "arrow.left.arrow.right",
                demoType: .hybrid,
                targetController: "NativeRNBridgeViewController"
            ),
            DemoItem(
                id: "native_flutter_bridge",
                title: "原生-Flutter桥接",
                description: "展示原生与Flutter通信",
                iconName: "arrow.up.arrow.down",
                demoType: .hybrid,
                targetController: "NativeFlutterBridgeViewController"
            )
        ]
    }
}

/// Flutter Demo提供者
struct FlutterDemoProvider {
    static func getDefaultDemos() -> [DemoItem] {
        return [
            DemoItem(
                id: "user_profile",
                title: "个人中心",
                description: "用户资料管理和设置",
                iconName: "person.circle.fill",
                demoType: .flutter,
                targetController: "CustomFlutterViewController"
            ),
            DemoItem(
                id: "app_settings",
                title: "应用设置",
                description: "主题、语言、通知等设置",
                iconName: "gearshape.fill",
                demoType: .flutter,
                targetController: "CustomFlutterViewController"
            ),
            DemoItem(
                id: "data_charts",
                title: "数据统计图表",
                description: "使用Flutter图表展示数据",
                iconName: "chart.bar.fill",
                demoType: .flutter,
                targetController: "CustomFlutterViewController"
            ),
            DemoItem(
                id: "theme_switcher",
                title: "主题切换",
                description: "动态切换应用主题",
                iconName: "paintbrush.fill",
                demoType: .flutter,
                targetController: "CustomFlutterViewController"
            )
        ]
    }
}
