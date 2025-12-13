part of 'daro_reward_ad.dart';

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

  static DaroRewardAdEvent? byNameOrNull(String? name) {
    if (name == null) return null;
    try {
      return DaroRewardAdEvent.values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  DaroLogLevel get logLevel => switch (this) {
    onAdLoadFail || onFailedToShow => DaroLogLevel.error,
    _ => DaroLogLevel.debug,
  };
}

class DaroRewardAdListener {
  // 광고 로드 성공
  final void Function(String adId)? onAdLoadSuccess;
  // 광고 로드 실패
  final void Function(String adId, DaroError error)? onAdLoadFail;
  // 광고 노출(성과 집계)
  final void Function(String adId)? onAdImpression;
  // 광고 클릭
  final void Function(String adId)? onAdClicked;
  // 광고 표시
  final void Function(String adId)? onShown;
  // 광고 리워드 적립
  final void Function(String adId, DaroReward reward)? onRewarded;
  // 광고 닫힘
  final void Function(String adId)? onDismiss;
  // 광고 표시 실패
  final void Function(String adId, DaroError error)? onFailedToShow;

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
