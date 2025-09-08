# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

# 定义 Flutter 模块的路径（修正路径）
flutter_application_path = '../flutter_module' # 根据实际路径修改
# 加载 Flutter 提供的辅助脚本
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'SwiftFlutter' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # 集成 Flutter 模块
  install_all_flutter_pods(flutter_application_path)
  
  # Pods for SwiftFlutter
  pod 'Moya'
end

post_install do |installer|
  # Flutter 提供的 post_install 配置
  flutter_post_install(installer) if defined?(flutter_post_install)
  
  # 确保 iOS 项目的最低部署版本与 Podfile 中定义的一致
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end
