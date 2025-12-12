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
