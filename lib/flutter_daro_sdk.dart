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

  /// 리워드 광고 표시
  ///
  /// 광고를 표시하고 광고 ID를 반환합니다.
  ///
  /// 예제:
  /// ```dart
  /// final result = await DaroSdk.showRewardAd(DaroRewardAdConfig(
  ///   adType: DaroAdType.rewardedVideo,
  ///   adKey: 'your-ad-key',
  /// ));
  /// if (result.success) {
  ///   print('광고 ID: ${result.adId}');
  ///   // 광고 이벤트 리스너 등록
  ///   DaroSdk.addAdListener(result.adId, (adId, event) {
  ///     print('광고 이벤트: $event');
  ///   });
  /// } else {
  ///   print('광고 표시 실패: ${result.errorMessage}');
  /// }
  /// ```
  static Future<DaroAdResult> showRewardAd(DaroRewardAdConfig config) async {
    return await FlutterDaroSdkPlatform.instance.showRewardAd(config);
  }

  /// 광고 이벤트 리스너 등록
  ///
  /// 특정 광고 인스턴스의 이벤트를 수신하기 위한 리스너를 등록합니다.
  ///
  /// 예제:
  /// ```dart
  /// DaroSdk.addAdListener('ad-id', (adId, event) {
  ///   final eventType = event['type'] as String;
  ///   if (eventType == 'adClosed') {
  ///     print('광고가 닫혔습니다');
  ///   } else if (eventType == 'rewardEarned') {
  ///     final amount = event['amount'] as int;
  ///     print('리워드 적립: $amount');
  ///   }
  /// });
  /// ```
  static void addAdListener(String adId, DaroAdListener listener) {
    FlutterDaroSdkPlatform.instance.addAdListener(adId, listener);
  }

  /// 광고 이벤트 리스너 제거
  ///
  /// 특정 광고 인스턴스의 이벤트 리스너를 제거합니다.
  ///
  /// 예제:
  /// ```dart
  /// DaroSdk.removeAdListener('ad-id');
  /// ```
  static void removeAdListener(String adId) {
    FlutterDaroSdkPlatform.instance.removeAdListener(adId);
  }
}
