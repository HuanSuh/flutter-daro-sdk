import 'package:flutter/material.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeSdk();
  }

  Future<void> _initializeSdk() async {
    try {
      // Reward 앱 초기화
      await DaroSdk.initialize(
        DaroSdkConfig(
          appCategory: DaroAppCategory.reward,
          appKey: 'test-app-key',
          userId: 'test-user-id',
        ),
      );
      _addLog('SDK 초기화 완료 (Reward 앱)');
    } catch (e) {
      _addLog('SDK 초기화 실패: $e');
    }
  }

  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toString().substring(11, 19)}: $message');
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DARO SDK Example (Reward)',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DARO SDK Example'),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _logs.clear();
                });
              },
              tooltip: '로그 지우기',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAdSection(title: '인터스티셜 광고', adType: DaroAdType.interstitial, adKey: 'interstitial-ad-key'),
                    const SizedBox(height: 16),
                    _buildAdSection(
                      title: '리워드 비디오 광고',
                      adType: DaroAdType.rewardedVideo,
                      adKey: 'rewarded-video-ad-key',
                    ),
                    const SizedBox(height: 16),
                    _buildAdSection(title: '팝업 광고', adType: DaroAdType.popup, adKey: 'popup-ad-key'),
                  ],
                ),
              ),
            ),
            const Divider(),
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('로그', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(_logs[index], style: const TextStyle(fontSize: 12)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdSection({required String title, required DaroAdType adType, required String adKey}) {
    return _AdSectionWidget(title: title, adType: adType, adKey: adKey, onLog: _addLog);
  }
}

class _AdSectionWidget extends StatefulWidget {
  final String title;
  final DaroAdType adType;
  final String adKey;
  final Function(String) onLog;

  const _AdSectionWidget({required this.title, required this.adType, required this.adKey, required this.onLog});

  @override
  State<_AdSectionWidget> createState() => _AdSectionWidgetState();
}

class _AdSectionWidgetState extends State<_AdSectionWidget> {
  DaroRewardAd? _ad;
  bool _isLoading = false;
  bool _isLoaded = false;
  String _status = '준비';

  @override
  void initState() {
    super.initState();
    _createAd();
  }

  void _createAd() {
    _ad = DaroSdk.createRewardAd(widget.adType, widget.adKey);
    _ad?.addListener((adKey, event) {
      final eventType = event['type'] as String? ?? 'unknown';
      final data = event['data'] as Map<dynamic, dynamic>?;
      widget.onLog('${widget.title} - 이벤트: $eventType ${data != null ? "- $data" : ""}');

      if (eventType == 'onDismiss') {
        setState(() {
          _status = '닫힘';
        });
      }
    });
    widget.onLog('${widget.title} - 인스턴스 생성 완료');
    setState(() {
      _status = '인스턴스 생성됨';
    });
  }

  Future<void> _loadAd() async {
    if (_ad == null) {
      widget.onLog('${widget.title} - 광고 인스턴스가 없습니다');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '로딩 중...';
    });

    try {
      await _ad!.load(
        DaroRewardAdConfig(adType: widget.adType, adKey: widget.adKey, placement: 'example-${widget.adType.name}'),
      );
      widget.onLog('${widget.title} - 로드 성공');
      setState(() {
        _isLoading = false;
        _isLoaded = true;
        _status = '로드 완료';
      });
    } catch (e) {
      widget.onLog('${widget.title} - 로드 실패: $e');
      setState(() {
        _isLoading = false;
        _isLoaded = false;
        _status = '로드 실패';
      });
    }
  }

  Future<void> _showAd() async {
    if (_ad == null) {
      widget.onLog('${widget.title} - 광고 인스턴스가 없습니다. 자동으로 로드 후 표시합니다.');
      // 인스턴스가 없으면 자동으로 생성하고 로드 후 표시
      _createAd();
      await _loadAd();
    } else if (!_isLoaded) {
      widget.onLog('${widget.title} - 광고가 로드되지 않았습니다. 자동으로 로드 후 표시합니다.');
      await _loadAd();
    }

    if (_ad == null) {
      widget.onLog('${widget.title} - 광고 인스턴스를 생성할 수 없습니다');
      return;
    }

    setState(() {
      _status = '표시 중...';
    });

    try {
      final success = await _ad!.show();
      if (success) {
        widget.onLog('${widget.title} - 표시 성공');
        setState(() {
          _status = '표시됨';
        });
      } else {
        widget.onLog('${widget.title} - 표시 실패');
        setState(() {
          _status = '표시 실패';
        });
      }
    } catch (e) {
      widget.onLog('${widget.title} - 표시 오류: $e');
      setState(() {
        _status = '표시 오류';
      });
    }
  }

  Future<void> _disposeAd() async {
    if (_ad == null) {
      widget.onLog('${widget.title} - 광고 인스턴스가 없습니다');
      return;
    }

    try {
      await _ad!.dispose();
      widget.onLog('${widget.title} - 해제 완료');
      setState(() {
        _ad = null;
        _isLoaded = false;
        _status = '해제됨';
      });
      // 해제 후 새로 생성
      _createAd();
    } catch (e) {
      widget.onLog('${widget.title} - 해제 실패: $e');
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _getStatusColor(), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    _status,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Ad Key: ${widget.adKey}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadAd,
                  icon:
                      _isLoading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.download),
                  label: const Text('Load'),
                ),
                ElevatedButton.icon(
                  onPressed: _showAd,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Show'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                OutlinedButton.icon(
                  onPressed: _disposeAd,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Dispose'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case '로드 완료':
        return Colors.green;
      case '표시됨':
        return Colors.blue;
      case '로딩 중...':
      case '표시 중...':
        return Colors.orange;
      case '로드 실패':
      case '표시 실패':
      case '표시 오류':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
