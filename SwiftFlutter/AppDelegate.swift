//
//  AppDelegate.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import Flutter
import UIKit
import React

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 初始化 React Native 桥接
        ReactNativeBridgeManager.shared.initializeBridge(launchOptions: launchOptions)
        
        // 初始化Flutter引擎组
        let flutterEngineGroup = FlutterEngineGroup(name: "io.flutter", project: nil)

        // 在应用启动时预热Flutter引擎
        let engine = flutterEngineGroup.makeEngine(with: FlutterEngineGroupOptions())
        engine.run(withEntrypoint: nil)
        // 保存引擎引用供后续使用
        FlutterEngineManager.shared.addEngine(forKey: "main", engine: engine)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
    }
}
