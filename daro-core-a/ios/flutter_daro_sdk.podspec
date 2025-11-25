#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint daro_core_a.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'daro_core_a'
  s.version          = '0.0.1'
  s.summary          = 'DARO SDK Core plugin for Non-Reward apps'
  s.description      = <<-DESC
DARO SDK Core plugin that provides iOS native dependencies for Non-Reward apps.
                       DESC
  s.homepage         = 'https://guide.daro.so'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  # DARO SDK 의존성은 Non-Reward 앱용으로 설정
  # 실제 사용 시 flutter_daro_sdk 플러그인에서 초기화
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

