platform :ios, '16.0'
min_ios = '16.0'

# flutter
flutter_application_path = '../../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

use_modular_headers!

target 'SwiftFlutter' do
  
  # Flutter
  install_all_flutter_pods(flutter_application_path)
  
  # 业务库
  pod 'Moya'
  pod 'Anchorage'
  pod 'Swinject'
  pod 'CocoaMQTT'
  pod 'Starscream'
  pod 'KeychainAccess'

  post_install do |installer|
    flutter_post_install(installer) if defined?(flutter_post_install)
  end
end
