import CoreMotion
import Flutter
import Foundation

class SensorEventHandler: NSObject {
    private let eventChannel: FlutterEventChannel
    private let motionManager = CMMotionManager()
    private var eventSink: FlutterEventSink?

    init(binaryMessenger: FlutterBinaryMessenger) {
        self.eventChannel = FlutterEventChannel(
            name: "com.example.swiftflutter/sensor_events",
            binaryMessenger: binaryMessenger
        )
        super.init()
        self.eventChannel.setStreamHandler(self)
    }

    private func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            eventSink?(
                FlutterError(
                    code: "UNAVAILABLE",
                    message: "加速度计在该设备上不可用",
                    details: nil
                ))
            return
        }

        motionManager.accelerometerUpdateInterval = 0.1  // 每0.1秒更新一次
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let sink = self.eventSink else { return }

            if let error = error {
                sink(
                    FlutterError(
                        code: "ACCELEROMETER_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                return
            }

            if let data = data {
                sink([
                    "x": data.acceleration.x,
                    "y": data.acceleration.y,
                    "z": data.acceleration.z,
                    "timestamp": Date().timeIntervalSince1970 * 1000,
                ])
            }
        }
    }

    private func stopAccelerometerUpdates() {
        if motionManager.isAccelerometerActive {
            motionManager.stopAccelerometerUpdates()
        }
    }
}

// MARK: - FlutterStreamHandler
extension SensorEventHandler: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events
        startAccelerometerUpdates()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopAccelerometerUpdates()
        eventSink = nil
        return nil
    }
}
