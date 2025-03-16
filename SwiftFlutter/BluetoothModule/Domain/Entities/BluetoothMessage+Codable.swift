import Foundation

/// 使BluetoothMessage完全支持Codable
extension BluetoothMessage {
    enum CodingKeys: String, CodingKey {
        case type
        case data
        case timestamp
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(Int(timestamp.timeIntervalSince1970 * 1000), forKey: .timestamp)

        if let data = data {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let jsonString = String(data: jsonData, encoding: .utf8)
            try container.encode(jsonString, forKey: .data)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(BluetoothMessageType.self, forKey: .type)

        let timeInterval = try container.decode(Int.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: TimeInterval(timeInterval) / 1000.0)

        if let jsonString = try container.decodeIfPresent(String.self, forKey: .data),
            let jsonData = jsonString.data(using: .utf8),
            let dictionary = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        {
            data = dictionary
        } else {
            data = nil
        }
    }
}
