//
//  DeviceListViewController.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/9/9.
//

import Anchorage
import Combine
import UIKit

/// 设备列表视图控制器
class DeviceListViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: DeviceViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Elements

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: "DeviceCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    // MARK: - Initialization

    init(viewModel: DeviceViewModel = DeviceViewModel()) {
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
        loadData()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "设备列表"
        view.backgroundColor = .systemGroupedBackground

        // 添加子视图
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)

        // 设置约束
        setupConstraints()

        // 设置数据源和代理
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupConstraints() {
        // 使用 Anchorage 设置约束
        tableView.topAnchor == view.safeAreaLayoutGuide.topAnchor
        tableView.leadingAnchor == view.leadingAnchor
        tableView.trailingAnchor == view.trailingAnchor
        tableView.bottomAnchor == view.bottomAnchor

        loadingIndicator.centerXAnchor == view.centerXAnchor
        loadingIndicator.centerYAnchor == view.centerYAnchor

        errorLabel.topAnchor == view.safeAreaLayoutGuide.topAnchor
        errorLabel.leadingAnchor == view.leadingAnchor
        errorLabel.trailingAnchor == view.trailingAnchor
        errorLabel.bottomAnchor == view.bottomAnchor
    }

    private func setupBindings() {
        // 绑定设备列表
        viewModel.$devices
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        // 绑定加载状态
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        // 绑定错误信息
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorLabel.text = errorMessage
                    self?.errorLabel.isHidden = false
                } else {
                    self?.errorLabel.isHidden = true
                }
            }
            .store(in: &cancellables)
    }

    private func loadData() {
        viewModel.loadDevices()
    }
}

// MARK: - UITableViewDataSource

extension DeviceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
            as! DeviceTableViewCell
        let device = viewModel.devices[indexPath.row]
        cell.configure(with: device)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension DeviceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let device = viewModel.devices[indexPath.row]
        let deviceDetailVC = DeviceDetailViewController(device: device, viewModel: viewModel)
        navigationController?.pushViewController(deviceDetailVC, animated: true)
    }
}
