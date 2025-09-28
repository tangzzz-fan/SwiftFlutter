//
//  DeviceViewModel.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Combine
import Foundation

/// 设备视图模型
class DeviceViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var selectedDevice: Device?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let deviceRepository: DeviceRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(deviceRepository: DeviceRepositoryProtocol = DeviceRepository()) {
        self.deviceRepository = deviceRepository
    }

    /// 加载设备列表
    func loadDevices() {
        isLoading = true
        errorMessage = nil

        deviceRepository.getDevices()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] devices in
                    self?.devices = devices
                }
            )
            .store(in: &cancellables)
    }

    /// 加载设备详情
    func loadDeviceDetails(id: String) {
        isLoading = true
        errorMessage = nil

        deviceRepository.getDeviceDetails(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] device in
                    self?.selectedDevice = device
                }
            )
            .store(in: &cancellables)
    }

    /// 更新设备状态
    func updateDeviceState(id: String, state: [String: Any]) {
        isLoading = true
        errorMessage = nil

        deviceRepository.updateDeviceState(id: id, state: state)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedDevice in
                    // 更新设备列表中的设备
                    if let index = self?.devices.firstIndex(where: { $0.id == updatedDevice.id }) {
                        self?.devices[index] = updatedDevice
                    }
                    // 如果是选中的设备，也更新选中设备
                    if self?.selectedDevice?.id == updatedDevice.id {
                        self?.selectedDevice = updatedDevice
                    }
                }
            )
            .store(in: &cancellables)
    }

    /// 清除错误信息
    func clearError() {
        errorMessage = nil
    }
}
