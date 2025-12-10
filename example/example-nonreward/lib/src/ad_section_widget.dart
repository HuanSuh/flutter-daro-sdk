import 'package:flutter/material.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';

class AdSectionWidget extends StatefulWidget {
  final String title;
  final DaroRewardAdType adType;
  final String adKey;
  final Function(String) onLog;

  const AdSectionWidget({
    super.key,
    required this.title,
    required this.adType,
    required this.adKey,
    required this.onLog,
  });

  @override
  State<AdSectionWidget> createState() => _AdSectionWidgetState();
}

class _AdSectionWidgetState extends State<AdSectionWidget> {
  DaroRewardAd? _ad;
  bool _isLoading = false;
  bool _isLoaded = false;
  String _status = '준비';

  void _createAd() {
    _ad = switch (widget.adType) {
      DaroRewardAdType.interstitial => DaroInterstitialAd(widget.adKey),
      DaroRewardAdType.rewardedVideo => DaroRewardedVideoAd(widget.adKey),
      DaroRewardAdType.popup => DaroPopupAd(widget.adKey),
      DaroRewardAdType.opening => DaroOpeningAd(widget.adKey),
    };
    // _ad?.addListener((adKey, event) {
    //   final eventType = event['type'] as String? ?? 'unknown';
    //   final data = event['data'] as Map<dynamic, dynamic>?;
    //   widget.onLog('${widget.title} - 이벤트: $eventType ${data != null ? "- $data" : ""}');

    //   if (eventType == 'onDismiss') {
    //     setState(() {
    //       _status = '닫힘';
    //     });
    //   }
    // });
    widget.onLog('${widget.title} - 인스턴스 생성 완료');
    setState(() {
      _status = '인스턴스 생성됨';
    });
  }

  Future<void> _loadAd() async {
    if (_ad == null) {
      widget.onLog('${widget.title} - 광고 인스턴스가 없습니다');
      // 인스턴스가 없으면 자동으로 생성하고 로드 후 표시
      _createAd();
    }

    setState(() {
      _isLoading = true;
      _status = '로딩 중...';
    });

    try {
      await _ad!.load();
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
      _createAd();
      // widget.onLog('${widget.title} - 광고 인스턴스가 없습니다. 자동으로 로드 후 표시합니다.');
      // await _loadAd();
      // } else if (!_isLoaded) {
      //   widget.onLog('${widget.title} - 광고가 로드되지 않았습니다. 자동으로 로드 후 표시합니다.');
      //   await _loadAd();
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
        _isLoading = false;
        _isLoaded = false;
        _status = '해제됨';
      });
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
                ElevatedButton.icon(onPressed: _isLoading ? null : _loadAd, label: const Text('Load')),
                ElevatedButton.icon(
                  onPressed: _showAd,
                  label: const Text('Show'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                OutlinedButton.icon(
                  onPressed: _disposeAd,
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
