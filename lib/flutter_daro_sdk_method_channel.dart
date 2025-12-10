import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_daro_sdk_platform_interface.dart';
import 'src/reward_ad/daro_reward_ad.dart';

/// An implementation of [FlutterDaroSdkPlatform] that uses method channels.
class MethodChannelFlutterDaroSdk extends FlutterDaroSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.daro.flutter_daro_sdk/channel');

  /// The event channel used to receive events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('com.daro.flutter_daro_sdk/events');

  // /// 광고 ID별 이벤트 리스너 맵
  // final Map<String, DaroAdListener> _adListeners = {};

  /// 이벤트 스트림 구독
  StreamSubscription<dynamic>? _eventSubscription;

  MethodChannelFlutterDaroSdk() {
    _setupEventStream();
  }

  /// 이벤트 스트림 설정
  void _setupEventStream() {
    try {
      _eventSubscription = eventChannel.receiveBroadcastStream().listen(
        (event) {
          if (event is Map) {
            final adUnit = event['adUnit'] as String?;
            final eventData = event['event'] as Map<dynamic, dynamic>?;

            if (eventData != null) {
              // 리워드 광고 이벤트 처리
              if (adUnit != null) {
                // final rewardAdListener = _rewardAdListeners[adUnit];
                // if (rewardAdListener != null) {
                //   rewardAdListener(adUnit, eventData);
                // }
              }
            }
          }
        },
        onError: (error) {
          // 에러 처리
        },
      );
    } catch (e) {
      // 에러 처리
    }
  }

  /// 이벤트 스트림 구독 (내부 사용)
  Stream<Map<dynamic, dynamic>>? getEventStream() {
    try {
      return eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> initialize(DaroSdkConfig config) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('initialize', config.toMap());
      return result ?? false;
    } on PlatformException catch (error) {
      // 초기화 실패 시 false 반환
      debugPrint('initialize failed: ${error.message}');
      return false;
    }
  }

  @override
  Future<void> setOptions(DaroSdkOptions options) async {
    try {
      await methodChannel.invokeMethod<void>('setOptions', options.toMap());
    } on PlatformException catch (e) {
      throw Exception('Failed to set options: ${e.message}');
    }
  }

  @override
  Future<void> loadRewardAd(DaroRewardAdType type, String adUnit) async {
    try {
      return methodChannel.invokeMethod<void>('loadRewardAd', {'adType': type.name, 'adUnit': adUnit});
    } on PlatformException catch (e) {
      throw Exception('Failed to load reward ad: ${e.message}');
    }
  }

  @override
  Future<bool> showRewardAd(DaroRewardAdType type, String adUnit) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('showRewardAd', {'adType': type.name, 'adUnit': adUnit});
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to show reward ad: ${e.message}');
    }
  }

  @override
  void addRewardAdListener(String adUnit, DaroRewardAdListener listener) {
    // TODO: implement addRewardAdListener
  }

  @override
  void removeRewardAdListener(String adUnit) {
    // TODO: implement removeRewardAdListener
  }

  @override
  Future<void> disposeRewardAd(DaroRewardAdType type, String adUnit) async {
    try {
      await methodChannel.invokeMethod<void>('disposeRewardAd', {'adType': type.name, 'adUnit': adUnit});
    } on PlatformException catch (e) {
      throw Exception('Failed to dispose reward ad: ${e.message}');
    }
  }
}
