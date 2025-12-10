import 'package:flutter_daro_sdk/flutter_daro_sdk_platform_interface.dart';

/// 광고 타입
enum DaroRewardAdType {
  /// 전면광고
  interstitial,

  /// 리워드 비디오 광고
  rewardedVideo,

  /// 팝업광고
  popup,

  /// 앱 오프닝
  opening,
}

/// 광고 표시 결과
class DaroAdResult {
  /// 광고 ID (이벤트 리스너 등록에 사용)
  final String adId;

  /// 광고 표시 성공 여부
  final bool success;

  /// 에러 메시지 (실패 시)
  final String? errorMessage;

  /// 리워드 적립 금액 (Reward 앱인 경우)
  final int? rewardAmount;

  DaroAdResult({required this.adId, required this.success, this.errorMessage, this.rewardAmount});

  factory DaroAdResult.fromMap(Map<dynamic, dynamic> map) {
    return DaroAdResult(
      adId: map['adId'] as String? ?? '',
      success: map['success'] as bool? ?? false,
      errorMessage: map['errorMessage'] as String?,
      rewardAmount: map['rewardAmount'] as int?,
    );
  }
}

/// 광고 이벤트 리스너
enum DaroRewardAdEvent {
  onAdLoadSuccess,
  onAdLoadFail,
  onAdImpression,
  onAdClicked,
  onShown,
  onRewarded,
  onDismiss,
  onFailedToShow;

  static DaroRewardAdEvent? byName(String? name) {
    if (name == null) return null;
    try {
      return DaroRewardAdEvent.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }
}

class DaroRewardAdListener {
  // 광고 로드 성공
  final void Function(String adId)? onAdLoadSuccess;
  // 광고 로드 실패
  final void Function(String adId, Map<dynamic, dynamic> data)? onAdLoadFail;
  // 광고 노출(성과 집계)
  final void Function(String adId)? onAdImpression;
  // 광고 클릭
  final void Function(String adId)? onAdClicked;
  // 광고 표시
  final void Function(String adId)? onShown;
  // 광고 리워드 적립
  final void Function(String adId, Map<dynamic, dynamic> data)? onRewarded;
  // 광고 닫힘
  final void Function(String adId)? onDismiss;
  // 광고 표시 실패
  final void Function(String adId, Map<dynamic, dynamic> data)? onFailedToShow;

  DaroRewardAdListener({
    this.onAdLoadSuccess,
    this.onAdLoadFail,
    this.onAdImpression,
    this.onAdClicked,
    this.onShown,
    this.onRewarded,
    this.onDismiss,
    this.onFailedToShow,
  });
}

/// 리워드 광고 클래스 (인터스티셜, 리워드 비디오, 팝업)
class DaroRewardAd {
  /// 광고 타입
  final DaroRewardAdType adType;

  /// 광고 키
  final String adUnit;

  /// 플랫폼 인터페이스
  final FlutterDaroSdkPlatform _platform = FlutterDaroSdkPlatform.instance;

  DaroRewardAd._(this.adType, this.adUnit);

  /// 광고 로드
  Future<bool> load() async {
    return _platform.loadRewardAd(adType, adUnit);
  }

  /// 광고 표시
  Future<bool> show() async {
    return _platform.showRewardAd(adType, adUnit);
  }

  /// 광고 이벤트 리스너 등록
  void addListener(DaroRewardAdListener listener) {
    _platform.addRewardAdListener(adUnit, listener);
  }

  /// 광고 이벤트 리스너 제거
  void removeListener() {
    _platform.removeRewardAdListener(adUnit);
  }

  /// 광고 인스턴스 해제
  Future<void> dispose() async {
    removeListener();
    await _platform.disposeRewardAd(adType, adUnit);
  }
}

class DaroInterstitialAd extends DaroRewardAd {
  DaroInterstitialAd(String adKey) : super._(DaroRewardAdType.interstitial, adKey);
}

class DaroRewardedVideoAd extends DaroRewardAd {
  DaroRewardedVideoAd(String adKey) : super._(DaroRewardAdType.rewardedVideo, adKey);
}

class DaroPopupAd extends DaroRewardAd {
  DaroPopupAd(String adKey) : super._(DaroRewardAdType.popup, adKey);
}

class DaroOpeningAd extends DaroRewardAd {
  DaroOpeningAd(String adKey) : super._(DaroRewardAdType.opening, adKey);
}
