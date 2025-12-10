import 'package:flutter/material.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';
import 'package:flutter_daro_sdk_example_reward/src/ad_event_logger.dart';
import 'package:flutter_daro_sdk_example_reward/src/ad_section_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AdLogController _adLogController = AdLogController();
  void _addLog(String message) => _adLogController.addLog(message);

  @override
  void initState() {
    super.initState();
    _initializeSdk();
  }

  @override
  void dispose() {
    _adLogController.dispose();
    super.dispose();
  }

  Future<void> _initializeSdk() async {
    try {
      // Reward 앱 초기화
      final success = await DaroSdk.initialize(DaroSdkConfig.reward());
      if (success) {
        _addLog('SDK 초기화 완료 (Reward 앱)');
      } else {
        _addLog('SDK 초기화 실패 (Reward 앱) - false 반환');
      }
    } catch (e) {
      _addLog('SDK 초기화 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DARO SDK Example (Reward)',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('DARO SDK Example (Reward)')),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAdSection(
                      title: '인터스티셜 광고',
                      adType: DaroRewardAdType.interstitial,
                      adKey: 'interstitial-ad-key',
                    ),
                    const SizedBox(height: 16),
                    _buildAdSection(
                      title: '리워드 비디오 광고',
                      adType: DaroRewardAdType.rewardedVideo,
                      adKey: 'rewarded-video-ad-key',
                    ),
                    const SizedBox(height: 16),
                    _buildAdSection(title: '팝업 광고', adType: DaroRewardAdType.popup, adKey: 'popup-ad-key'),
                  ],
                ),
              ),
            ),
            AdEventLogger(controller: _adLogController),
          ],
        ),
      ),
    );
  }

  Widget _buildAdSection({required String title, required DaroRewardAdType adType, required String adKey}) {
    return AdSectionWidget(title: title, adType: adType, adKey: adKey, onLog: _addLog);
  }
}
