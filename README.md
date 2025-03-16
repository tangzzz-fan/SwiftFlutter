# SwiftFlutter

SwiftFlutter 是一个将 Flutter 模块集成到 Swift/iOS 应用的示例项目。本项目展示了如何在现有的 iOS 应用中嵌入 Flutter 模块，并实现两者之间的通信。

## 项目结构 
```
SwiftFlutter/
├── SwiftFlutter/ # iOS 应用源代码
│ ├── AppDelegate.swift # iOS 应用委托
│ ├── SceneDelegate.swift # 场景委托
│ ├── ViewController.swift # 主视图控制器
│ ├── CustomFlutterViewController.swift # 自定义 Flutter 视图控制器
│ └── BluetoothModule/ # 蓝牙处理模块
│   ├── Domain/ # 领域层
│   │ ├── Entities/ # 实体对象
│   │ ├── Interfaces/ # 接口定义 
│   │ └── Utils/ # 工具类
│   ├── Infrastructure/ # 基础设施层
│   │ └── CoreBluetooth/ # CoreBluetooth封装
│   ├── Application/ # 应用层
│   │ └── Services/ # 服务实现
│   └── Presentation/ # 表示层
│     └── Publishers/ # Flutter通信
├── flutter_module/ # Flutter 模块
│ ├── lib/ # Flutter 源代码
│ │ ├── main.dart # Flutter 入口文件
│ │ ├── router/ # 路由管理
│ │ ├── screens/ # 页面
│ │ ├── services/ # 服务
│ │ └── widgets/ # 组件
│ └── pubspec.yaml # Flutter 依赖配置
├── Podfile # CocoaPods 配置文件
├── .gitignore # Git 忽略文件
├── setup.sh # 项目依赖安装脚本
└── README.md # 项目说明文档
```


## 技术栈

### iOS 部分
- Swift 5
- UIKit
- CocoaPods
- Moya (网络请求库)

### Flutter 部分
- Flutter SDK
- go_router (路由管理)
- provider (状态管理)
- flutter_svg 和 cached_network_image (UI 组件)

## 功能特性

1. **iOS 与 Flutter 集成**：在 iOS 应用中嵌入 Flutter 模块
2. **平台通信**：iOS 和 Flutter 之间的双向通信
3. **自定义 Flutter 视图控制器**：监听 Flutter 页面的生命周期
4. **Flutter 路由管理**：使用 go_router 实现页面导航
5. **iOS 风格适配**：在 Flutter 中实现接近原生的 iOS 界面风格

## 安装与运行

### 前置要求

- macOS 操作系统
- Xcode 14.0 或更高版本
- CocoaPods
- Flutter SDK (3.3.0 或更高版本)

### 安装步骤

1. 使用安装脚本安装依赖
```bash
chmod +x setup.sh
./setup.sh
```
2. 打开 Xcode 工作区
```bash
open SwiftFlutter.xcworkspace
```
3. 在 Xcode 中运行项目

### 手动安装步骤

如果你不想使用安装脚本，也可以按照以下步骤手动安装：

1. 安装 Flutter 依赖
```bash
cd flutter_module
flutter pub get
cd ..
```
2. 安装 iOS 依赖
```bash
pod install
```

## 开发指南

### 添加新的 Flutter 页面

1. 在 `flutter_module/lib/screens/` 目录下创建新的页面文件
2. 在 `flutter_module/lib/router/app_router.dart` 中添加新的路由配置
3. 更新导航方法以支持新页面

### 添加新的平台通信方法

1. 在 iOS 端的 `ViewController.swift` 中的 `setupMethodChannel` 方法中添加新的方法处理
2. 在 Flutter 端的 `HomeScreen` 类中的 `_setupMethodChannel` 方法中添加对应的方法处理

## 常见问题

### Flutter 模块无法加载

确保 Flutter 模块路径在 Podfile 中正确配置，并且已经成功运行 `pod install`。

### 平台通信失败

检查 iOS 和 Flutter 端的通道名称是否一致，默认为 `com.example.swiftflutter/channel`。

### 编译错误

如果遇到编译错误，尝试清理项目并重新安装依赖：
```bash
./setup.sh --clean
```

## 贡献指南

欢迎提交 Pull Request 或创建 Issue 来改进这个项目。在提交代码前，请确保：

1. 代码符合项目的编码规范
2. 添加了必要的测试
3. 更新了相关文档

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。