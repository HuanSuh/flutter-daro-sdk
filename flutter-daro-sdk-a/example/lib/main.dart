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

extension on AdUnitConfig? {
  bool get isEmpty => this?.adUnit?.isNotEmpty != true;
}

class TestAdConfig {
  final AdUnitConfig? banner;
  final AdUnitConfig? bannerMrec;
  final AdUnitConfig? interstitial;
  final AdUnitConfig? rewardedVideo;
  final AdUnitConfig? popup;
  final AdUnitConfig? opening;

  const TestAdConfig({
    this.banner,
    this.bannerMrec,
    this.interstitial,
    this.rewardedVideo,
    this.popup,
    this.opening,
  });

  bool get _isEmpty =>
      banner.isEmpty &&
      bannerMrec.isEmpty &&
      interstitial.isEmpty &&
      rewardedVideo.isEmpty &&
      popup.isEmpty &&
      opening.isEmpty;
}

void main() {
  runApp(
    MyApp(
      ///
      /// example 수행 시 secret-keys.json 에 있는 값을 사용합니다.
      /// secret-keys.template.json 을 복사하여 Daro Dashboard 에서 생성한 키 값을 입력해주세요.
      /// [flutter run --dart-define-from-file=secret-keys.json] 명령어를 통해 예제 실행
      ///
      adConfig: TestAdConfig(
        banner: AdUnitConfig(
          android: const String.fromEnvironment('ADUNITS_BANNER_ANDROID'),
          ios: const String.fromEnvironment('ADUNITS_BANNER_IOS'),
        ),
        bannerMrec: AdUnitConfig(
          android: const String.fromEnvironment('ADUNITS_BANNERMREC_ANDROID'),
          ios: const String.fromEnvironment('ADUNITS_BANNERMREC_IOS'),
        ),
        interstitial: AdUnitConfig(
          android: const String.fromEnvironment('ADUNITS_INTERSTITIAL_ANDROID'),
          ios: const String.fromEnvironment('ADUNITS_INTERSTITIAL_IOS'),
        ),
        rewardedVideo: AdUnitConfig(
          android: const String.fromEnvironment(
            'ADUNITS_REWARDEDVIDEO_ANDROID',
          ),
          ios: const String.fromEnvironment('ADUNITS_REWARDEDVIDEO_IOS'),
        ),
        popup: AdUnitConfig(
          android: const String.fromEnvironment('ADUNITS_POPUP_ANDROID'),
          ios: const String.fromEnvironment('ADUNITS_POPUP_IOS'),
        ),
        opening: AdUnitConfig(
          android: const String.fromEnvironment('ADUNITS_OPENING_ANDROID'),
          ios: const String.fromEnvironment('ADUNITS_OPENING_IOS'),
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final TestAdConfig adConfig;
  const MyApp({super.key, required this.adConfig});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AdLogController _adLogController = AdLogController();
  void _addLog(String message) => _adLogController.addLog(message);

  bool _bannerAdSectionExpanded = true;
  bool _rewardAdSectionExpanded = true;

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
    // Non-Reward 앱 초기화
    await DaroSdk.initialize()
        .then((_) => _addLog('SDK 초기화 완료 (Non-Reward 앱)'))
        .catchError((e) => _addLog('SDK 초기화 오류: $e'));

    if (widget.adConfig._isEmpty) {
      _addLog('광고 설정이 없습니다. secret-keys.json 에 광고키를 추가해주세요.');
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
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(
                  expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 24,
                ),
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
    DaroBannerAdListener buildListener(String name) {
      return DaroBannerAdListener(
        onAdLoaded: (ad) => _addLog('$name 광고 로드 완료'),
        onAdFailedToLoad: (ad, error) => _addLog('$name 광고 로드 실패: $error'),
        onAdImpression: (ad) => _addLog('$name 광고 노출'),
        onAdClicked: (ad) => _addLog('$name 광고 클릭'),
      );
    }

    return _buildSection(
      '배너 광고',
      expanded: _bannerAdSectionExpanded,
      onTap: (expanded) => setState(() => _bannerAdSectionExpanded = expanded),
      children: [
        if (widget.adConfig.banner?.adUnit case final String adUnit)
          DaroBannerAdView(
            ad: DaroBannerAd.banner(adUnit),
            listener: buildListener('배너'),
          ),
        if (widget.adConfig.bannerMrec?.adUnit case final String adUnit)
          DaroBannerAdView(
            ad: DaroBannerAd.mrec(adUnit),
            listener: buildListener('MREC'),
          ),
      ],
    );
  }

  Widget _buildRewardAdSection() {
    return _buildSection(
      '리워드 광고',
      children: [
        if (widget.adConfig.interstitial?.adUnit case final String adUnit)
          AdSectionWidget(
            title: '인터스티셜 광고',
            adType: DaroRewardAdType.interstitial,
            onLog: _addLog,
            adKey: adUnit,
          ),
        if (widget.adConfig.rewardedVideo?.adUnit case final String adUnit)
          AdSectionWidget(
            title: '리워드 비디오 광고',
            adType: DaroRewardAdType.rewardedVideo,
            onLog: _addLog,
            adKey: adUnit,
          ),
        if (widget.adConfig.popup?.adUnit case final String adUnit)
          AdSectionWidget(
            title: '팝업 광고',
            adType: DaroRewardAdType.popup,
            onLog: _addLog,
            adKey: adUnit,
          ),
        if (widget.adConfig.opening?.adUnit case final String adUnit)
          AdSectionWidget(
            title: '앱오프닝 광고',
            adType: DaroRewardAdType.opening,
            onLog: _addLog,
            adKey: adUnit,
          ),
      ],
      expanded: _rewardAdSectionExpanded,
      onTap: (expanded) => setState(() => _rewardAdSectionExpanded = expanded),
    );
  }
}
