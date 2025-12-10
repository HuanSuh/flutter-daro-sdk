import 'flutter_daro_sdk_platform_interface.dart';

export 'flutter_daro_sdk_platform_interface.dart';
export 'flutter_daro_sdk_method_channel.dart';
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
  static Future<bool> initialize(DaroSdkConfig config) async {
    return await FlutterDaroSdkPlatform.instance.initialize(config);
  }

  // /// 리워드 광고 인스턴스 생성
  // ///
  // /// 광고 타입과 키를 기반으로 리워드 광고 인스턴스를 생성합니다.
  // ///
  // /// 예제:
  // /// ```dart
  // /// // 인터스티셜 광고
  // /// final interstitialAd = DaroSdk.createAd(
  // ///   DaroAdType.interstitial,
  // ///   'your-ad-key',
  // /// );
  // /// await interstitialAd.load(DaroRewardAdConfig(
  // ///   adType: DaroAdType.interstitial,
  // ///   adKey: 'your-ad-key',
  // ///   placement: 'main-screen',
  // /// ));
  // /// await interstitialAd.show();
  // ///
  // /// // 리워드 비디오 광고
  // /// final rewardVideoAd = DaroSdk.createAd(
  // ///   DaroAdType.rewardedVideo,
  // ///   'your-reward-ad-key',
  // /// );
  // /// ```
  // static DaroRewardAd createAd(DaroRewardAdType type, String adKey) {
  //   return DaroRewardAd(type, adKey, FlutterDaroSdkPlatform.instance);
  // }

  // static DaroRewardAd createRewardAd(String adKey) {
  //   return DaroRewardAd(DaroRewardAdType.rewardedVideo, adKey, FlutterDaroSdkPlatform.instance);
  // }

  // static DaroRewardAd createInterstitialAd(String adKey) {
  //   return DaroRewardAd(DaroRewardAdType.interstitial, adKey, FlutterDaroSdkPlatform.instance);
  // }

  // static DaroRewardAd createPopupAd(String adKey) {
  //   return DaroRewardAd(DaroRewardAdType.popup, adKey, FlutterDaroSdkPlatform.instance);
  // }
}
