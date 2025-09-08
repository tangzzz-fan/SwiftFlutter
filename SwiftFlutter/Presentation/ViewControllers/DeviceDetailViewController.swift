//
//  DeviceDetailViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Anchorage
import Combine
import UIKit

/// 设备详情视图控制器
class DeviceDetailViewController: UIViewController {
    // MARK: - Properties

    private let device: Device
    private let viewModel: DeviceViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Elements

    private lazy var deviceNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private lazy var deviceTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private lazy var stateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.onTintColor = .systemBlue
        return toggle
    }()

    private lazy var updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("更新状态", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Initialization

    init(device: Device, viewModel: DeviceViewModel) {
        self.device = device
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        configureView()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "设备详情"
        view.backgroundColor = .systemGroupedBackground

        // 添加子视图
        view.addSubview(deviceNameLabel)
        view.addSubview(deviceTypeLabel)
        view.addSubview(stateStackView)
        view.addSubview(updateButton)
        view.addSubview(loadingIndicator)

        // 设置约束
        setupConstraints()

        // 设置事件
        toggleSwitch.addTarget(
            self, action: #selector(toggleSwitchValueChanged), for: .valueChanged)
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        // 使用 Anchorage 设置约束
        deviceNameLabel.topAnchor == view.safeAreaLayoutGuide.topAnchor + 20
        deviceNameLabel.leadingAnchor == view.leadingAnchor + 16
        deviceNameLabel.trailingAnchor == view.trailingAnchor - 16

        deviceTypeLabel.topAnchor == deviceNameLabel.bottomAnchor + 8
        deviceTypeLabel.leadingAnchor == view.leadingAnchor + 16
        deviceTypeLabel.trailingAnchor == view.trailingAnchor - 16

        stateStackView.topAnchor == deviceTypeLabel.bottomAnchor + 30
        stateStackView.leadingAnchor == view.leadingAnchor + 16
        stateStackView.trailingAnchor == view.trailingAnchor - 16

        updateButton.topAnchor == stateStackView.bottomAnchor + 30
        updateButton.leadingAnchor == view.leadingAnchor + 16
        updateButton.trailingAnchor == view.trailingAnchor - 16
        updateButton.heightAnchor == 50

        loadingIndicator.centerXAnchor == view.centerXAnchor
        loadingIndicator.centerYAnchor == updateButton.centerYAnchor
    }

    private func setupBindings() {
        // 绑定加载状态
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                    self?.updateButton.isHidden = true
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.updateButton.isHidden = false
                }
            }
            .store(in: &cancellables)

        // 绑定错误信息
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }

    private func configureView() {
        deviceNameLabel.text = device.name
        deviceTypeLabel.text = device.type

        // 根据设备类型创建状态控件
        createStateControls(for: device)
    }

    private func createStateControls(for device: Device) {
        // 清空现有控件
        stateStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 根据设备类型创建控件
        switch device.type {
        case "light":
            createLightControls(for: device)
        case "outlet":
            createOutletControls(for: device)
        case "lock":
            createLockControls(for: device)
        default:
            createGenericControls(for: device)
        }
    }

    private func createLightControls(for device: Device) {
        // 开关控件
        let switchView = createSwitchControl(title: "开关", key: "on", device: device)
        stateStackView.addArrangedSubview(switchView)

        // 亮度控件
        if let brightness = device.state["brightness"]?.intValue {
            let brightnessView = createSliderControl(
                title: "亮度", key: "brightness", value: Float(brightness), min: 0, max: 100)
            stateStackView.addArrangedSubview(brightnessView)
        }
    }

    private func createOutletControls(for device: Device) {
        // 开关控件
        let switchView = createSwitchControl(title: "开关", key: "on", device: device)
        stateStackView.addArrangedSubview(switchView)
    }

    private func createLockControls(for device: Device) {
        // 锁定控件
        let switchView = createSwitchControl(title: "锁定", key: "locked", device: device)
        stateStackView.addArrangedSubview(switchView)

        // 电池控件
        if let battery = device.state["battery"]?.intValue {
            let batteryView = createSliderControl(
                title: "电池", key: "battery", value: Float(battery), min: 0, max: 100)
            stateStackView.addArrangedSubview(batteryView)
        }
    }

    private func createGenericControls(for device: Device) {
        // 显示所有状态键值对
        for (key, value) in device.state {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "\(key): \(value.stringValue ?? "nil")"
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .label
            stateStackView.addArrangedSubview(label)
        }
    }

    private func createSwitchControl(title: String, key: String, device: Device) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .label

        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.tag = key.hashValue
        switchControl.onTintColor = .systemBlue

        if let value = device.state[key]?.boolValue {
            switchControl.isOn = value
        }

        containerView.addSubview(titleLabel)
        containerView.addSubview(switchControl)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            switchControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            switchControl.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])

        return containerView
    }

    private func createSliderControl(
        title: String, key: String, value: Float, min: Float, max: Float
    ) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .label

        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.tag = key.hashValue

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = "\(Int(value))"
        valueLabel.font = UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .label
        valueLabel.tag = key.hashValue + 1000  // 使用不同的tag来区分

        containerView.addSubview(titleLabel)
        containerView.addSubview(slider)
        containerView.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),

            slider.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            slider.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            slider.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor, constant: -8),

            valueLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 40),
        ])

        return containerView
    }

    // MARK: - Actions

    @objc private func toggleSwitchValueChanged(_ sender: UISwitch) {
        // 更新UI但不立即发送请求
    }

    @objc private func updateButtonTapped() {
        var newState: [String: Any] = [:]

        // 收集所有控件的状态
        for case let view in stateStackView.arrangedSubviews {
            // 处理开关控件
            if let switchControl = view.subviews.first(where: { $0 is UISwitch }) as? UISwitch {
                let key =
                    switchControl.tag == "on".hashValue
                    ? "on" : switchControl.tag == "locked".hashValue ? "locked" : nil
                if let key = key {
                    newState[key] = switchControl.isOn
                }
            }

            // 处理滑块控件
            for case let slider as UISlider in view.subviews {
                let key =
                    slider.tag == "brightness".hashValue
                    ? "brightness" : slider.tag == "battery".hashValue ? "battery" : nil
                if let key = key {
                    newState[key] = Int(slider.value)
                }
            }
        }

        // 发送更新请求
        viewModel.updateDeviceState(id: device.id, state: newState)
    }

    // MARK: - Helper Methods

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
