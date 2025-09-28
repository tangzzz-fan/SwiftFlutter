//
//  DeviceResponse.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Foundation

/// 设备列表响应模型
struct DeviceListResponse: Codable {
    let devices: [Device]
}

/// 单个设备响应模型
struct DeviceResponse: Codable {
    let device: Device
}
