# iOS 原生架构设计说明

## 概述

本文档详细说明了 iOS 原生部分的架构设计和实现，采用了现代化的 Clean Architecture 模式，结合 Swinject、MVVM-C、POP 和 Combine 技术栈。

## 架构层次

### 1. Application 层
- **DependencyContainer.swift**: 依赖注入容器，管理所有组件的依赖关系

### 2. Presentation 层
- **ViewControllers**: UIKit 视图控制器
- **ViewModels**: 视图模型，处理 UI 逻辑
- **Views**: SwiftUI 视图
- **Coordinators**: 协调器，处理页面导航和流程控制

### 3. Domain 层
- **Entities**: 核心数据模型
- **Services**: 业务服务接口和实现

### 4. Data 层
- **Network**: 网络请求管理器

### 5. Common 层
- **Protocols**: 公共协议定义

### 6. FlutterIntegration 层
- **FlutterEngineManager.swift**: Flutter 引擎管理器
- **FlutterBridge.swift**: 原生与 Flutter 通信桥接

## 技术实现细节

### 依赖注入 (Swinject)
使用 Swinject 实现依赖注入，解耦各组件间的依赖关系，提高代码可测试性和可维护性。

### MVVM-C 模式
- **Model**: 数据模型层
- **View**: 视图层 (UIKit + SwiftUI)
- **ViewModel**: 视图模型层，处理 UI 逻辑
- **Coordinator**: 协调器层，处理页面导航

### 面向协议编程 (POP)
通过协议定义组件接口，使用协议扩展提供默认实现，提高代码复用性。

### Combine 响应式编程
使用 Combine 框架处理异步数据流，实现响应式编程模式。

### Flutter 集成管理
1. **FlutterEngineManager**: 管理 Flutter 引擎的生命周期，支持多引擎实例
2. **FlutterBridge**: 处理原生与 Flutter 间的通信 (MethodChannel 和 EventChannel)

## 目录结构

```
SwiftFlutter/
├── Application/
│   └── DependencyContainer.swift
├── Common/
│   └── Protocols/
│       └── Networking.swift
├── Data/
│   └── Network/
│       └── NetworkManager.swift
├── Domain/
│   ├── Entities/
│   │   └── User.swift
│   └── Services/
│       └── UserService.swift
├── FlutterIntegration/
│   ├── FlutterBridge.swift
│   └── FlutterEngineManager.swift
├── Presentation/
│   ├── Coordinators/
│   │   ├── Coordinator.swift
│   │   └── MainCoordinator.swift
│   ├── ViewControllers/
│   │   ├── HomeViewController.swift
│   │   ├── SettingsViewController.swift
│   │   └── UserProfileViewController.swift
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift
│   │   └── ViewModel.swift
│   └── Views/
│       ├── HomeView.swift
│       ├── SettingsView.swift
│       └── UserProfileView.swift
├── AppDelegate.swift
└── SceneDelegate.swift
```

## Flutter 集成说明

### 引擎管理
使用 `FlutterEngineManager` 管理 Flutter 引擎实例：
- 支持多引擎实例管理
- 实现引擎状态跟踪 (空闲、活动、暂停)
- 提供引擎的创建、复用和销毁机制

### 通信桥接
使用 `FlutterBridge` 处理原生与 Flutter 间的通信：
- MethodChannel: 处理方法调用
- EventChannel: 处理事件推送

## 后续工作

1. 实现高频数据流传输对比功能
2. 实现大数据量传输对比功能
3. 实现复杂数据结构传递演示功能
4. 完善原生 Bridge 接口实现
5. 添加性能监控和日志记录