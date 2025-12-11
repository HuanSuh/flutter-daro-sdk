import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MockFlutterDaroSdkPlatform with MockPlatformInterfaceMixin implements FlutterDaroSdkPlatform {}

void main() {
  final FlutterDaroSdkPlatform initialPlatform = FlutterDaroSdkPlatform.instance;

  test('$MethodChannelFlutterDaroSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterDaroSdk>());
  });
}
