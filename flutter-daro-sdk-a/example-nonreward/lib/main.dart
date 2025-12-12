import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';
import 'package:flutter_daro_sdk_example_nonreward/src/ad_event_logger.dart';
import 'package:flutter_daro_sdk_example_nonreward/src/ad_section_widget.dart';

class AdUnitConfig {
  final String? android;
  final String? ios;

  const AdUnitConfig({this.android, this.ios});

  String? get adUnit => Platform.isAndroid ? android : ios;
}

class TestAdConfig {
  final AdUnitConfig? banner;
  final AdUnitConfig? bannerMrec;
  final AdUnitConfig? interstitial;
  final AdUnitConfig? rewardedVideo;
  final AdUnitConfig? popup;
  final AdUnitConfig? opening;

  const TestAdConfig({this.banner, this.bannerMrec, this.interstitial, this.rewardedVideo, this.popup, this.opening});
}

void main() {
  runApp(
    MyApp(
      adConfig: TestAdConfig(
        banner: AdUnitConfig(
          android: 'a384af5c-0abc-4420-8efa-ee58f1fc6615',
          ios: '1602731d-42f2-4646-ac70-f49428d9a862',
        ),
        bannerMrec: AdUnitConfig(
          android: 'd770ab01-38f1-4619-a585-669dae47f080',
          ios: 'a18cb2ca-a9ac-4ae0-809f-38bace607be7',
        ),
        interstitial: AdUnitConfig(
          android: '339de698-56b5-44f7-97a2-5d6bbcefd596',
          ios: '5c9197f7-7b5f-45d5-85db-24603763570c',
        ),
        rewardedVideo: AdUnitConfig(
          android: '50bc1360-2099-4702-bb93-7586e1a633eb',
          ios: '7f2fb7c2-2170-444a-b5f8-91e7cd03b974',
        ),
        popup: AdUnitConfig(
          android: '8565a8aa-0e89-435c-a060-8eb5ca5df996',
          ios: 'df5f7623-21a6-49a6-8b14-0679a75b4b43',
        ),
        opening: AdUnitConfig(
          android: '1b038272-1b24-447d-a25b-575fb940cfc0',
          ios: '7763af9c-0456-4e37-808a-5478eb9e0aa3',
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final TestAdConfig adConfig;
  const MyApp({required this.adConfig, super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AdLogController _adLogController = AdLogController();
  void _addLog(String message) => _adLogController.addLog(message);

  bool _bannerAdSectionExpanded = true;
  bool _rewardAdSectionExpanded = false;

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
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_buildBannerAdSection(), _buildRewardAdSection()],
                ),
              ),
            ),
            AdEventLogger(controller: _adLogController),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title, {
    required List<Widget> children,
    required bool expanded,
    required ValueChanged<bool> onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => onTap(!expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Spacer(),
                Icon(expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 24),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(spacing: 16, children: children),
          ),
      ],
    );
  }

  Widget _buildBannerAdSection() {
    return _buildSection(
      '배너 광고',
      expanded: _bannerAdSectionExpanded,
      onTap: (expanded) => setState(() => _bannerAdSectionExpanded = expanded),
      children: [
        if (widget.adConfig.banner?.adUnit case final String adUnit)
          DaroBannerAdView(
            ad: DaroBannerAd.banner(adUnit),
            listener: DaroBannerAdListener(
              onAdLoaded: (ad) => _addLog('배너 광고 로드 완료'),
              onAdFailedToLoad: (ad, error) => _addLog('배너 광고 로드 실패: $error'),
              onAdImpression: (ad) => _addLog('배너 광고 노출'),
              onAdClicked: (ad) => _addLog('배너 광고 클릭'),
            ),
          ),
        if (widget.adConfig.bannerMrec?.adUnit case final String adUnit)
          DaroBannerAdView(
            ad: DaroBannerAd.mrec(adUnit),
            listener: DaroBannerAdListener(
              onAdLoaded: (ad) => _addLog('MREC 광고 로드 완료'),
              onAdFailedToLoad: (ad, error) => _addLog('MREC 광고 로드 실패: $error'),
              onAdImpression: (ad) => _addLog('MREC 광고 노출'),
              onAdClicked: (ad) => _addLog('MREC 광고 클릭'),
            ),
          ),
      ],
    );
  }

  Widget _buildRewardAdSection() {
    return _buildSection(
      '리워드 광고',
      children: [
        if (widget.adConfig.interstitial?.adUnit case final String adUnit)
          AdSectionWidget(title: '인터스티셜 광고', adType: DaroRewardAdType.interstitial, onLog: _addLog, adKey: adUnit),
        if (widget.adConfig.rewardedVideo?.adUnit case final String adUnit)
          AdSectionWidget(title: '리워드 비디오 광고', adType: DaroRewardAdType.rewardedVideo, onLog: _addLog, adKey: adUnit),
        if (widget.adConfig.popup?.adUnit case final String adUnit)
          AdSectionWidget(title: '팝업 광고', adType: DaroRewardAdType.popup, onLog: _addLog, adKey: adUnit),
        if (widget.adConfig.opening?.adUnit case final String adUnit)
          AdSectionWidget(title: '앱오프닝 광고', adType: DaroRewardAdType.opening, onLog: _addLog, adKey: adUnit),
      ],
      expanded: _rewardAdSectionExpanded,
      onTap: (expanded) => setState(() => _rewardAdSectionExpanded = expanded),
    );
  }
}
