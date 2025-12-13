import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';
import 'package:flutter_daro_sdk/src/daro_error.dart';

/// An implementation of [FlutterDaroSdkPlatform] that uses method channels.
class MethodChannelFlutterDaroSdk extends FlutterDaroSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.daro.flutter_daro_sdk/channel');

  /// The event channel used to receive events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('com.daro.flutter_daro_sdk/events');

  /// 광고 ID별 이벤트 리스너 맵
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
              final eventType = DaroRewardAdEvent.byNameOrNull(event['eventName'] as String?);
              if (eventType?.logLevel case DaroLogLevel logLevel when DaroSdk.logLevel.index <= logLevel.index) {
                debugPrint('[DARO] $eventType - $adUnit ${eventData ?? ''}');
              }
              final rewardAdListener = _rewardAdListeners[adUnit];
              if (rewardAdListener != null) {
                switch (eventType) {
                  case DaroRewardAdEvent.onAdLoadSuccess:
                    rewardAdListener.onAdLoadSuccess?.call(adUnit);
                  case DaroRewardAdEvent.onAdLoadFail:
                    rewardAdListener.onAdLoadFail?.call(adUnit, DaroError.fromJson(eventData));
                  case DaroRewardAdEvent.onAdImpression:
                    rewardAdListener.onAdImpression?.call(adUnit);
                  case DaroRewardAdEvent.onAdClicked:
                    rewardAdListener.onAdClicked?.call(adUnit);
                  case DaroRewardAdEvent.onShown:
                    rewardAdListener.onShown?.call(adUnit);
                  case DaroRewardAdEvent.onRewarded:
                    rewardAdListener.onRewarded?.call(adUnit, DaroReward.fromJson(eventData));
                  case DaroRewardAdEvent.onDismiss:
                    rewardAdListener.onDismiss?.call(adUnit);
                  case DaroRewardAdEvent.onFailedToShow:
                    rewardAdListener.onFailedToShow?.call(adUnit, DaroError.fromJson(eventData));
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

  bool _isInitialized = false;
  Completer<bool>? _initializeCompleter;
  Completer<bool>? get _pendingCompleter {
    if (_initializeCompleter case final Completer<bool> completer when !completer.isCompleted) {
      return completer;
    }
    return null;
  }

  Future<void> _checkInitialized() async {
    if (_isInitialized) {
      return;
    }
    return initialize(DaroSdkConfig.nonReward()).then((_) {});
  }

  Future<bool> _initialize(DaroSdkConfig config, Completer<bool> completer) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('initialize', config.toMap());
      _isInitialized = result ?? false;
      completer.complete(result ?? false);
      return result ?? false;
    } catch (e) {
      debugPrint('[DARO] initialize failed: $e');
      completer.completeError(e);
      return false;
    }
  }

  @override
  Future<bool> initialize(DaroSdkConfig config) async {
    if (_isInitialized) {
      return true;
    }
    final pendingCompleter = _pendingCompleter;
    if (pendingCompleter != null) {
      return pendingCompleter.future;
    }
    final completer = Completer<bool>();
    return _initialize(config, completer);
  }

  @override
  Future<bool> setOptions(DaroSdkOptions options) async {
    try {
      await _checkInitialized();
      final result = await methodChannel.invokeMethod<bool>('setOptions', options.toMap());
      return result ?? false;
    } catch (e) {
      debugPrint('[DARO] setOptions failed: $e');
      return false;
    }
  }

  /// 배너 광고
  ///

  /// 리워드 광고
  ///
  @override
  Future<bool> loadRewardAd(DaroRewardAdType type, String adUnit, {Map<String, dynamic>? options}) async {
    try {
      await _checkInitialized();
      final result = await methodChannel.invokeMethod<bool>('loadRewardAd', {
        'adType': type.name,
        'adUnit': adUnit,
        'options': options,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('[DARO] loadRewardAd failed: $e');
      _rewardAdListeners[adUnit]?.onAdLoadFail?.call(adUnit, DaroError.fromJson(e));
      return false;
    }
  }

  @override
  Future<bool> showRewardAd(DaroRewardAdType type, String adUnit, {Map<String, dynamic>? options}) async {
    try {
      await _checkInitialized();
      final result = await methodChannel.invokeMethod<bool>('showRewardAd', {
        'adType': type.name,
        'adUnit': adUnit,
        'options': options,
      });
      return result ?? false;
    } catch (e) {
      _rewardAdListeners[adUnit]?.onFailedToShow?.call(adUnit, DaroError.fromJson(e));
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
