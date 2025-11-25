#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint daro_core_m.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'daro_core_m'
  s.version          = '0.0.1'
  s.summary          = 'DARO SDK Core plugin for Reward apps'
  s.description      = <<-DESC
DARO SDK Core plugin that provides iOS native dependencies for Reward apps.
                       DESC
  s.homepage         = 'https://guide.daro.so'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  
  # DARO SDK 의존성은 Reward 앱용으로 설정
  # TODO: 실제 버전으로 교체
  # s.dependency 'DaroAds', '~> 1.1.45'
  # 실제 사용 시 flutter_daro_sdk 플러그인에서 초기화
  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

