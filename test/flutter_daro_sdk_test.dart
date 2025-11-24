import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk_platform_interface.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterDaroSdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterDaroSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterDaroSdkPlatform initialPlatform = FlutterDaroSdkPlatform.instance;

  test('$MethodChannelFlutterDaroSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterDaroSdk>());
  });

  test('getPlatformVersion', () async {
    FlutterDaroSdk flutterDaroSdkPlugin = FlutterDaroSdk();
    MockFlutterDaroSdkPlatform fakePlatform = MockFlutterDaroSdkPlatform();
    FlutterDaroSdkPlatform.instance = fakePlatform;

    expect(await flutterDaroSdkPlugin.getPlatformVersion(), '42');
  });
}
