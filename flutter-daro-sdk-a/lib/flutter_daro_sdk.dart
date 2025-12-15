import 'flutter_daro_sdk_platform_interface.dart';

export 'flutter_daro_sdk_platform_interface.dart';
export 'flutter_daro_sdk_method_channel.dart';
export 'src/banner/daro_banner_ad.dart';
export 'src/reward_ad/daro_reward_ad.dart';

/// DARO SDK 메인 클래스
class DaroSdk {
  /// SDK 초기화
  ///
  /// DARO SDK를 초기화합니다. 초기화 성공 여부를 반환합니다.
  ///
  /// **중요**: 광고를 로드하기 전에 반드시 SDK를 초기화해야 합니다.
  /// 초기화 전 광고를 요청하면 광고가 정상적으로 표시되지 않을 수 있습니다.
  ///
  /// [config] DARO SDK 초기화 설정
  ///
  /// Returns `true` if initialization succeeds, `false` otherwise
  ///
  /// 예제:
  /// ```dart
  /// final success = await DaroSdk.initialize(DaroSdkConfig(
  ///   appCategory: DaroAppCategory.reward,
  ///   appKey: 'your-app-key',
  ///   userId: 'user-id',
  /// ));
  /// if (success) {
  ///   print('SDK 초기화 성공');
  /// } else {
  ///   print('SDK 초기화 실패');
  /// }
  /// ```
  static Future<void> initialize({DaroSdkOptions? options}) async {
    if (options?.logLevel case DaroLogLevel logLevel) {
      DaroSdk._logLevel = logLevel;
    }
    return await FlutterDaroSdkPlatform.instance.initialize(DaroSdkConfig.nonReward(options: options));
  }

  static Future<bool> setOptions(DaroSdkOptions options) async {
    if (options.logLevel case DaroLogLevel logLevel) {
      DaroSdk._logLevel = logLevel;
    }
    return await FlutterDaroSdkPlatform.instance.setOptions(options);
  }

  static DaroLogLevel _logLevel = DaroLogLevel.off;
  static DaroLogLevel get logLevel => _logLevel;
}
