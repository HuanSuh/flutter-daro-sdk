import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_daro_sdk_platform_interface.dart';

/// An implementation of [FlutterDaroSdkPlatform] that uses method channels.
class MethodChannelFlutterDaroSdk extends FlutterDaroSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.daro.flutter_daro_sdk/channel');

  /// The event channel used to receive events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('com.daro.flutter_daro_sdk/events');

  /// 광고 ID별 이벤트 리스너 맵
  final Map<String, DaroAdListener> _adListeners = {};

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
            final adId = event['adId'] as String?;
            final adKey = event['adKey'] as String?;
            final eventData = event['event'] as Map<dynamic, dynamic>?;

            if (eventData != null) {
              // 일반 광고 이벤트 처리
              if (adId != null) {
                final listener = _adListeners[adId];
                if (listener != null) {
                  listener(adId, eventData);
                }
              }

              // 리워드 광고 이벤트 처리
              if (adKey != null) {
                final rewardAdListener = _rewardAdListeners[adKey];
                if (rewardAdListener != null) {
                  rewardAdListener(adKey, eventData);
                }
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

  @override
  Future<void> initialize(DaroSdkConfig config) async {
    try {
      await methodChannel.invokeMethod<void>('initialize', config.toMap());
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize DARO SDK: ${e.message}');
    }
  }

  @override
  Future<DaroAdResult> showRewardAd(DaroRewardAdConfig config) async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('showRewardAd', config.toMap());
      if (result != null) {
        return DaroAdResult.fromMap(result);
      }
      return DaroAdResult(adId: '', success: false, errorMessage: 'Unknown error');
    } on PlatformException catch (e) {
      return DaroAdResult(adId: '', success: false, errorMessage: e.message ?? 'Failed to show ad');
    }
  }

  @override
  void addAdListener(String adId, DaroAdListener listener) {
    _adListeners[adId] = listener;
  }

  @override
  void removeAdListener(String adId) {
    _adListeners.remove(adId);
  }

  /// 리워드 광고 리스너 맵
  final Map<String, DaroAdListener> _rewardAdListeners = {};

  @override
  Future<void> loadRewardAd(DaroAdType type, String adKey, DaroRewardAdConfig config) async {
    try {
      await methodChannel.invokeMethod<void>('loadRewardAd', {'adType': type.name, 'adKey': adKey, ...config.toMap()});
    } on PlatformException catch (e) {
      throw Exception('Failed to load reward ad: ${e.message}');
    }
  }

  @override
  Future<bool> showRewardAdInstance(DaroAdType type, String adKey) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('showRewardAdInstance', {
        'adType': type.name,
        'adKey': adKey,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to show reward ad: ${e.message}');
    }
  }

  @override
  void addRewardAdListener(String adKey, DaroAdListener listener) {
    _rewardAdListeners[adKey] = listener;
  }

  @override
  void removeRewardAdListener(String adKey) {
    _rewardAdListeners.remove(adKey);
  }

  @override
  Future<void> disposeRewardAd(DaroAdType type, String adKey) async {
    try {
      await methodChannel.invokeMethod<void>('disposeRewardAd', {'adType': type.name, 'adKey': adKey});
      _rewardAdListeners.remove(adKey);
    } on PlatformException catch (e) {
      throw Exception('Failed to dispose reward ad: ${e.message}');
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
}
