import Flutter
import Foundation

/// 蓝牙插件类，用于在Flutter引擎启动时注册
public class BluetoothPlugin {
    private static var bridge: FlutterBluetoothBridge?

    /// 注册蓝牙插件到Flutter引擎
    /// - Parameter registrar: Flutter插件注册器
    public static func register(with registrar: FlutterPluginRegistrar) {
        bridge = FlutterBluetoothBridge(binaryMessenger: registrar.messenger())
    }

    /// 注册蓝牙插件到Flutter引擎
    /// - Parameter binaryMessenger: Flutter二进制信使
    public static func register(binaryMessenger: FlutterBinaryMessenger) {
        bridge = FlutterBluetoothBridge(binaryMessenger: binaryMessenger)
    }
}
