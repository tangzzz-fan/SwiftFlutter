import Flutter
import Foundation

class LoggingChannel {
    private let messageChannel: FlutterBasicMessageChannel
    private let logHandler: (String, LogLevel) -> Void

    enum LogLevel: String {
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case debug = "DEBUG"
    }

    init(
        binaryMessenger: FlutterBinaryMessenger,
        logHandler: @escaping (String, LogLevel) -> Void
    ) {
        self.logHandler = logHandler

        // 使用StringCodec作为编解码器
        self.messageChannel = FlutterBasicMessageChannel(
            name: "com.example.swiftflutter/logging",
            binaryMessenger: binaryMessenger,
            codec: FlutterStringCodec.sharedInstance()
        )

        setupMessageHandler()
    }

    private func setupMessageHandler() {
        messageChannel.setMessageHandler { [weak self] message, reply in
            guard let self = self, let logMessage = message as? String else {
                reply("无效日志消息")
                return
            }

            // 解析日志消息格式：LEVEL:MESSAGE
            let components = logMessage.components(separatedBy: ":")
            if components.count >= 2 {
                let levelString = components[0]
                let message = components[1...].joined(separator: ":")

                if let level = LogLevel(rawValue: levelString) {
                    self.logHandler(message, level)
                    reply("日志已记录")
                } else {
                    reply("未知日志级别")
                }
            } else {
                // 默认为INFO级别
                self.logHandler(logMessage, .info)
                reply("日志已记录(默认INFO级别)")
            }
        }
    }

    // 发送日志到Flutter
    func sendLog(message: String, level: LogLevel) {
        let formattedMessage = "\(level.rawValue):\(message)"
        messageChannel.sendMessage(formattedMessage)
    }
}
