# Resolve react_native_pods.rb with node to allow for hoisting
require Pod::Executable.execute_command('node', ['-p',
  'require.resolve(
    "react-native/scripts/react_native_pods.rb",
    {paths: [process.argv[1]]},
  )', __dir__]).strip

platform :ios, '16.0'
min_ios = '16.0'

prepare_react_native_project!

# flutter
flutter_application_path = '../../flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

linkage = ENV['USE_FRAMEWORKS']
if linkage != nil
  Pod::UI.puts "Configuring Pod with #{linkage}ally linked Frameworks".green
  use_frameworks! :linkage => linkage.to_sym
end

use_frameworks! :linkage => :static

target 'SwiftFlutter' do

  # React Native
  config = use_native_modules!

  use_react_native!(
    :path => config[:reactNativePath],
    # An absolute path to your application root.
    :app_path => "#{Pod::Config.instance.installation_root}/.."
  )
  
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
    react_native_post_install(
      installer,
      config[:reactNativePath],
      :mac_catalyst_enabled => false,
      # :ccache_enabled => true
    )
  end
end
