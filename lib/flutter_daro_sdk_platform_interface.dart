import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_daro_sdk_method_channel.dart';
import 'src/reward_ad/daro_reward_ad.dart';

/// 앱 카테고리 타입
enum DaroAppCategory {
  /// Non-reward 앱: 현물성 리워드 제공 없이 특정 서비스나 기능을 제공하는 앱
  nonReward,

  /// Reward 앱: 광고 시청을 통한 현물성 리워드 획득이 주요 기능인 앱
  reward,
}

/// SDK 초기화 설정
class DaroSdkConfig {
  /// 앱 카테고리 타입
  final DaroAppCategory appCategory;

  /// SDK 옵션 설정
  final DaroSdkOptions? options;

  DaroSdkConfig._({required this.appCategory, this.options});

  factory DaroSdkConfig.reward({DaroSdkOptions? options}) {
    return DaroSdkConfig._(appCategory: DaroAppCategory.reward, options: options);
  }
  factory DaroSdkConfig.nonReward({DaroSdkOptions? options}) {
    return DaroSdkConfig._(appCategory: DaroAppCategory.nonReward, options: options);
  }

  Map<String, dynamic> toMap() {
    return {'appCategory': appCategory.name, 'options': options?.toMap()};
  }
}

enum DaroLogLevel {
  // 로그 출력 없음
  off,
  // 에러 로그만 출력
  error,
  // 모든 로그 출력 (개발 시 권장)
  debug,
}

class DaroSdkOptions {
  final String? userId;
  final DaroLogLevel? logLevel;
  final bool? appMute;

  DaroSdkOptions({this.userId, this.logLevel, this.appMute});

  Map<String, dynamic> toMap() {
    return {'userId': userId, 'logLevel': logLevel?.name, 'appMute': appMute};
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
  ///
  /// DARO SDK를 초기화합니다.
  /// 초기화 성공 여부를 boolean으로 반환합니다.
  ///
  /// [config] DARO SDK 초기화 설정
  /// Returns `true` if initialization succeeds, `false` otherwise
  Future<bool> initialize(DaroSdkConfig config);

  /// SDK 옵션 설정
  ///
  /// SDK 옵션을 설정합니다.
  /// 옵션 설정 성공 여부를 boolean으로 반환합니다.
  ///
  /// [options] SDK 옵션 설정
  /// Returns `true` if options setting succeeds, `false` otherwise
  Future<bool> setOptions(DaroSdkOptions options);

  //// 리워드 광고 (인터스티셜, 리워드 비디오, 팝업, 앱 오프닝)
  ///
  /// [loadRewardAd] 리워드 광고 인스턴스 로드
  /// [showRewardAd] 리워드 광고 인스턴스 표시
  /// [addRewardAdListener] 리워드 광고 리스너 등록
  /// [removeRewardAdListener] 리워드 광고 리스너 제거
  /// [disposeRewardAd] 리워드 광고 인스턴스 해제
  Future<bool> loadRewardAd(DaroRewardAdType type, String adUnit);
  Future<bool> showRewardAd(DaroRewardAdType type, String adUnit);
  void addRewardAdListener(String adUnit, DaroRewardAdListener listener);
  void removeRewardAdListener(String adUnit);
  Future<void> disposeRewardAd(DaroRewardAdType type, String adUnit);
}
