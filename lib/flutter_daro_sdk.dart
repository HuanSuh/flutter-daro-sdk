library flutter_daro_sdk;

import 'flutter_daro_sdk_platform_interface.dart';
import 'flutter_daro_sdk_method_channel.dart';

export 'flutter_daro_sdk_platform_interface.dart';
export 'flutter_daro_sdk_method_channel.dart';

/// DARO SDK 메인 클래스
class DaroSdk {
  /// SDK 초기화
  ///
  /// [config] DARO SDK 초기화 설정
  ///
  /// 예제:
  /// ```dart
  /// await DaroSdk.initialize(DaroSdkConfig(
  ///   appCategory: DaroAppCategory.reward,
  ///   appKey: 'your-app-key',
  ///   userId: 'user-id',
  /// ));
  /// ```
  static Future<void> initialize(DaroSdkConfig config) async {
    await FlutterDaroSdkPlatform.instance.initialize(config);
  }

  /// 광고 표시
  ///
  /// 광고를 표시하고 결과를 반환합니다.
  ///
  /// 예제:
  /// ```dart
  /// final result = await DaroSdk.showAd();
  /// if (result.success) {
  ///   print('광고 표시 성공');
  ///   if (result.rewardAmount != null) {
  ///     print('리워드: ${result.rewardAmount}');
  ///   }
  /// } else {
  ///   print('광고 표시 실패: ${result.errorMessage}');
  /// }
  /// ```
  static Future<DaroAdResult> showAd() async {
    return await FlutterDaroSdkPlatform.instance.showAd();
  }

  /// 이벤트 스트림 구독
  ///
  /// SDK에서 발생하는 이벤트를 구독합니다.
  /// (광고 완료, 리워드 적립 등의 이벤트)
  ///
  /// 예제:
  /// ```dart
  /// DaroSdk.getEventStream()?.listen((event) {
  ///   print('이벤트: $event');
  /// });
  /// ```
  static Stream<Map<dynamic, dynamic>>? getEventStream() {
    final methodChannel = FlutterDaroSdkPlatform.instance;
    if (methodChannel is MethodChannelFlutterDaroSdk) {
      return methodChannel.getEventStream();
    }
    return null;
  }
}
