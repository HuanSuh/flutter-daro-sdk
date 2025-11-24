import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_daro_sdk_method_channel.dart';

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
  
  /// DARO SDK 앱 키 (선택사항)
  final String? appKey;
  
  /// 사용자 ID (선택사항)
  final String? userId;

  DaroSdkConfig({
    required this.appCategory,
    this.appKey,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'appCategory': appCategory.name,
      'appKey': appKey,
      'userId': userId,
    };
  }
}

/// 광고 표시 결과
class DaroAdResult {
  /// 광고 표시 성공 여부
  final bool success;
  
  /// 에러 메시지 (실패 시)
  final String? errorMessage;
  
  /// 리워드 적립 금액 (Reward 앱인 경우)
  final int? rewardAmount;

  DaroAdResult({
    required this.success,
    this.errorMessage,
    this.rewardAmount,
  });

  factory DaroAdResult.fromMap(Map<dynamic, dynamic> map) {
    return DaroAdResult(
      success: map['success'] as bool? ?? false,
      errorMessage: map['errorMessage'] as String?,
      rewardAmount: map['rewardAmount'] as int?,
    );
  }
}

/// 리워드 정보
class DaroRewardInfo {
  /// 현재 리워드 잔액
  final int balance;
  
  /// 총 적립된 리워드
  final int totalEarned;

  DaroRewardInfo({
    required this.balance,
    required this.totalEarned,
  });

  factory DaroRewardInfo.fromMap(Map<dynamic, dynamic> map) {
    return DaroRewardInfo(
      balance: map['balance'] as int? ?? 0,
      totalEarned: map['totalEarned'] as int? ?? 0,
    );
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

  /// 광고 표시
  Future<DaroAdResult> showAd() {
    throw UnimplementedError('showAd() has not been implemented.');
  }

  /// 리워드 잔액 조회
  Future<DaroRewardInfo> getRewardBalance() {
    throw UnimplementedError('getRewardBalance() has not been implemented.');
  }
}
