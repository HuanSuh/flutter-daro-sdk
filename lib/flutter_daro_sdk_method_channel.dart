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
  final Map<String, DaroRewardAdListener> _rewardAdListeners = {};

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
            final eventData = event['data'] as Map<dynamic, dynamic>?;

            // 리워드 광고 이벤트 처리
            if (adUnit != null) {
              final eventName = DaroRewardAdEvent.byName(event['eventName'] as String?);
              debugPrint('[DARO] $eventName - $adUnit ${eventData?.isNotEmpty == true ? ' : $eventData' : ''}');
              final rewardAdListener = _rewardAdListeners[adUnit];
              if (rewardAdListener != null) {
                switch (eventName) {
                  case DaroRewardAdEvent.onAdLoadSuccess:
                    rewardAdListener.onAdLoadSuccess?.call(adUnit);
                  case DaroRewardAdEvent.onAdLoadFail:
                    rewardAdListener.onAdLoadFail?.call(adUnit, eventData ?? {});
                  case DaroRewardAdEvent.onAdImpression:
                    rewardAdListener.onAdImpression?.call(adUnit);
                  case DaroRewardAdEvent.onAdClicked:
                    rewardAdListener.onAdClicked?.call(adUnit);
                  case DaroRewardAdEvent.onShown:
                    rewardAdListener.onShown?.call(adUnit);
                  case DaroRewardAdEvent.onRewarded:
                    rewardAdListener.onRewarded?.call(adUnit, eventData ?? {});
                  case DaroRewardAdEvent.onDismiss:
                    rewardAdListener.onDismiss?.call(adUnit);
                  case DaroRewardAdEvent.onFailedToShow:
                    rewardAdListener.onFailedToShow?.call(adUnit, eventData ?? {});
                  case null:
                    break;
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
    } catch (e) {
      debugPrint('[DARO] initialize failed: $e');
      return false;
    }
  }

  @override
  Future<bool> setOptions(DaroSdkOptions options) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('setOptions', options.toMap());
      return result ?? false;
    } catch (e) {
      debugPrint('[DARO] setOptions failed: $e');
      return false;
    }
  }

  @override
  Future<bool> loadRewardAd(DaroRewardAdType type, String adUnit) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('loadRewardAd', {'adType': type.name, 'adUnit': adUnit});
      return result ?? false;
    } catch (e) {
      debugPrint('[DARO] loadRewardAd failed: $e');
      _rewardAdListeners[adUnit]?.onAdLoadFail?.call(adUnit, {'error': e});
      return false;
    }
  }

  @override
  Future<bool> showRewardAd(DaroRewardAdType type, String adUnit) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('showRewardAd', {'adType': type.name, 'adUnit': adUnit});
      return result ?? false;
    } catch (e) {
      _rewardAdListeners[adUnit]?.onFailedToShow?.call(adUnit, {'error': e});
      return false;
    }
  }

  @override
  void addRewardAdListener(String adUnit, DaroRewardAdListener listener) {
    _rewardAdListeners[adUnit] = listener;
  }

  @override
  void removeRewardAdListener(String adUnit) {
    _rewardAdListeners.remove(adUnit);
  }

  @override
  Future<void> disposeRewardAd(DaroRewardAdType type, String adUnit) async {
    try {
      await methodChannel.invokeMethod<void>('disposeRewardAd', {'adType': type.name, 'adUnit': adUnit});
      removeRewardAdListener(adUnit);
    } on PlatformException catch (e) {
      debugPrint('[DARO] disposeRewardAd failed: ${e.message}');
    }
  }
}
