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

  @override
  Future<void> initialize(DaroSdkConfig config) async {
    try {
      await methodChannel.invokeMethod<void>('initialize', config.toMap());
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize DARO SDK: ${e.message}');
    }
  }

  @override
  Future<DaroAdResult> showAd() async {
    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>('showAd');
      if (result != null) {
        return DaroAdResult.fromMap(result);
      }
      return DaroAdResult(success: false, errorMessage: 'Unknown error');
    } on PlatformException catch (e) {
      return DaroAdResult(success: false, errorMessage: e.message ?? 'Failed to show ad');
    }
  }

  /// 이벤트 스트림 구독 (콜백 이벤트 수신)
  Stream<Map<dynamic, dynamic>>? getEventStream() {
    try {
      return eventChannel.receiveBroadcastStream().cast<Map<dynamic, dynamic>>();
    } catch (e) {
      return null;
    }
  }
}
