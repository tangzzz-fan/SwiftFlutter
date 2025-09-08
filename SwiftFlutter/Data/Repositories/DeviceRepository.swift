//
//  DeviceRepository.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Combine
import Foundation

/// 设备仓库协议
protocol DeviceRepositoryProtocol {
    func getDevices() -> AnyPublisher<[Device], Error>
    func getDeviceDetails(id: String) -> AnyPublisher<Device, Error>
    func updateDeviceState(id: String, state: [String: Any]) -> AnyPublisher<Device, Error>
}

/// 设备仓库实现
class DeviceRepository: DeviceRepositoryProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }

    /// 获取设备列表
    func getDevices() -> AnyPublisher<[Device], Error> {
        return apiClient.getDevices()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    /// 获取设备详情
    func getDeviceDetails(id: String) -> AnyPublisher<Device, Error> {
        return apiClient.getDeviceDetails(id: id)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    /// 更新设备状态
    func updateDeviceState(id: String, state: [String: Any]) -> AnyPublisher<Device, Error> {
        return apiClient.updateDeviceState(id: id, state: state)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

}
