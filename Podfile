require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', __dir__]).strip

platform :ios, '16.0'
min_ios = '16.0'
prepare_react_native_project!

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
  Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
  use_frameworks! :linkage => linkage.to_sym
else
  use_frameworks!
end

# flutter
flutter_application_path = '../../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

# 全局取 config
config = use_native_modules!

target 'SwiftFlutter' do
  use_frameworks!

  use_react_native!(
      :path => config[:reactNativePath],
      :app_path => "#{Pod::Config.instance.installation_root}/.."
    )
  
  # Flutter
  install_all_flutter_pods(flutter_application_path)
  use_modular_headers!
  
  # 业务库
  pod 'Moya'
  pod 'Anchorage'
  pod 'Swinject'
  pod 'CocoaMQTT'
  pod 'Starscream'
  pod 'KeychainAccess'
end

post_install do |installer|
  flutter_post_install(installer) if defined?(flutter_post_install)
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = min_ios
    end
  end
  
  # React Native post install configuration
  react_native_post_install(
    installer,
    config[:reactNativePath],
    :mac_catalyst_enabled => false,
  )
end
