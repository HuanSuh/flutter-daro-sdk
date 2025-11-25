import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_daro_sdk_method_channel.dart';

/// 앱 카테고리 타입
enum DaroAppCategory {
  /// Non-reward 앱: 현물성 리워드 제공 없이 특정 서비스나 기능을 제공하는 앱
  nonReward,

  /// Reward 앱: 광고 시청을 통한 현물성 리워드 획득이 주요 기능인 앱
  reward,
}

/// 광고 타입
enum DaroAdType {
  /// 전면광고
  interstitial,

  /// 리워드 비디오 광고
  rewardedVideo,

  /// 팝업광고
  popup,
}

/// SDK 초기화 설정
class DaroSdkConfig {
  /// 앱 카테고리 타입
  final DaroAppCategory appCategory;

  /// DARO SDK 앱 키 (선택사항)
  final String? appKey;

  /// 사용자 ID (선택사항)
  final String? userId;

  DaroSdkConfig({required this.appCategory, this.appKey, this.userId});

  Map<String, dynamic> toMap() {
    return {'appCategory': appCategory.name, 'appKey': appKey, 'userId': userId};
  }
}

/// 리워드 광고 표시 설정
class DaroRewardAdConfig {
  /// 광고 타입
  final DaroAdType adType;

  /// 광고 키 (필수)
  final String adKey;

  /// Placement (로그에 표시될 이름, 선택사항)
  final String? placement;

  /// 추가 파라미터 (선택사항)
  final Map<String, dynamic>? extraParams;

  DaroRewardAdConfig({required this.adType, required this.adKey, this.placement, this.extraParams});

  Map<String, dynamic> toMap() {
    return {'adType': adType.name, 'adKey': adKey, 'placement': placement, 'extraParams': extraParams};
  }
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
typedef DaroAdListener = void Function(String adId, Map<dynamic, dynamic> event);

/// 리워드 광고 클래스 (인터스티셜, 리워드 비디오, 팝업)
class DaroRewardAd {
  /// 광고 타입
  final DaroAdType adType;

  /// 광고 키
  final String adKey;

  /// 플랫폼 인터페이스
  final FlutterDaroSdkPlatform _platform;

  DaroRewardAd(this.adType, this.adKey, this._platform);

  /// 광고 로드
  Future<void> load(DaroRewardAdConfig config) async {
    await _platform.loadRewardAd(adType, adKey, config);
  }

  /// 광고 표시
  Future<bool> show() async {
    return await _platform.showRewardAdInstance(adType, adKey);
  }

  /// 광고 이벤트 리스너 등록
  void addListener(DaroAdListener listener) {
    _platform.addRewardAdListener(adKey, listener);
  }

  /// 광고 이벤트 리스너 제거
  void removeListener() {
    _platform.removeRewardAdListener(adKey);
  }

  /// 광고 인스턴스 해제
  Future<void> dispose() async {
    await _platform.disposeRewardAd(adType, adKey);
  }
}

abstract class FlutterDaroSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterDaroSdkPlatform.
  FlutterDaroSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterDaroSdkPlatform _instance = MethodChannelFlutterDaroSdk();

  /// The default instance of [FlutterDaroSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterDaroSdk].
  static FlutterDaroSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterDaroSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterDaroSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// SDK 초기화
  Future<void> initialize(DaroSdkConfig config) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// 리워드 광고 표시 (기존 API - 호환성 유지)
  Future<DaroAdResult> showRewardAd(DaroRewardAdConfig config) {
    throw UnimplementedError('showRewardAd() has not been implemented.');
  }

  /// 광고 이벤트 리스너 등록
  void addAdListener(String adId, DaroAdListener listener) {
    throw UnimplementedError('addAdListener() has not been implemented.');
  }

  /// 광고 이벤트 리스너 제거
  void removeAdListener(String adId) {
    throw UnimplementedError('removeAdListener() has not been implemented.');
  }

  /// 리워드 광고 로드 (인터스티셜, 리워드 비디오, 팝업)
  Future<void> loadRewardAd(DaroAdType type, String adKey, DaroRewardAdConfig config) {
    throw UnimplementedError('loadRewardAd() has not been implemented.');
  }

  /// 리워드 광고 인스턴스 표시 (인터스티셜, 리워드 비디오, 팝업)
  Future<bool> showRewardAdInstance(DaroAdType type, String adKey) {
    throw UnimplementedError('showRewardAdInstance() has not been implemented.');
  }

  /// 리워드 광고 리스너 등록
  void addRewardAdListener(String adKey, DaroAdListener listener) {
    throw UnimplementedError('addRewardAdListener() has not been implemented.');
  }

  /// 리워드 광고 리스너 제거
  void removeRewardAdListener(String adKey) {
    throw UnimplementedError('removeRewardAdListener() has not been implemented.');
  }

  /// 리워드 광고 인스턴스 해제
  Future<void> disposeRewardAd(DaroAdType type, String adKey) {
    throw UnimplementedError('disposeRewardAd() has not been implemented.');
  }
}
