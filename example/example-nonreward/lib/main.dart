import 'package:flutter/material.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';
import 'package:flutter_daro_sdk_example_nonreward/src/ad_event_logger.dart';
import 'package:flutter_daro_sdk_example_nonreward/src/ad_section_widget.dart';

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
      // Non-Reward 앱 초기화
      final success = await DaroSdk.initialize(DaroSdkConfig.nonReward());
      if (success) {
        _addLog('SDK 초기화 완료 (Non-Reward 앱)');
      } else {
        _addLog('SDK 초기화 실패 (Non-Reward 앱) - false 반환');
      }
    } catch (e) {
      _addLog('SDK 초기화 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DARO SDK Example (Non-Reward)',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('DARO.A Example (Non-Reward)')),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    _buildAdSection(
                      title: '인터스티셜 광고',
                      adType: DaroRewardAdType.interstitial,
                      adKey: '5c9197f7-7b5f-45d5-85db-24603763570c',
                    ),
                    _buildAdSection(
                      title: '리워드 비디오 광고',
                      adType: DaroRewardAdType.rewardedVideo,
                      adKey: '7f2fb7c2-2170-444a-b5f8-91e7cd03b974',
                    ),
                    _buildAdSection(
                      title: '팝업 광고',
                      adType: DaroRewardAdType.popup,
                      adKey: 'df5f7623-21a6-49a6-8b14-0679a75b4b43',
                    ),
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
