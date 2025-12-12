import 'package:flutter/material.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk_platform_interface.dart';

part 'daro_reward_ad_listener.dart';
part 'daro_light_popup_options.dart';

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

/// 리워드 광고 클래스 (인터스티셜, 리워드 비디오, 팝업)
class DaroRewardAd {
  /// 광고 타입
  final DaroRewardAdType adType;

  /// 광고 키
  final String adUnit;

  /// 광고 옵션
  final Map<String, dynamic>? options;

  /// 플랫폼 인터페이스
  final FlutterDaroSdkPlatform _platform = FlutterDaroSdkPlatform.instance;

  DaroRewardAd._(this.adType, this.adUnit, {this.options});

  /// 광고 로드
  Future<bool> load() async {
    return _platform.loadRewardAd(adType, adUnit, options: options);
  }

  /// 광고 표시
  Future<bool> show() async {
    return _platform.showRewardAd(adType, adUnit, options: options);
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
  DaroPopupAd(String adKey, {DaroPopupAdOptions? options})
    : super._(DaroRewardAdType.popup, adKey, options: options?.toMap());
}

class DaroOpeningAd extends DaroRewardAd {
  DaroOpeningAd(String adKey) : super._(DaroRewardAdType.opening, adKey);
}
