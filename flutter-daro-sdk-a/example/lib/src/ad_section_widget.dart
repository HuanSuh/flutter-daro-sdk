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
  String _status = '준비';

  void _createAd() {
    _ad = switch (widget.adType) {
      DaroRewardAdType.interstitial => DaroInterstitialAd(widget.adKey),
      DaroRewardAdType.rewardedVideo => DaroRewardedVideoAd(widget.adKey),
      DaroRewardAdType.popup => DaroPopupAd(
        widget.adKey,
        options: DaroPopupAdOptions.dark(),
      ),
      DaroRewardAdType.opening => DaroOpeningAd(widget.adKey),
    };
    _ad?.addListener(
      DaroRewardAdListener(
        onAdLoadSuccess: (adKey) {
          widget.onLog('${widget.title} - 로드 성공');
          setState(() {
            _isLoading = false;
            _status = '로드 완료';
          });
        },
        onAdLoadFail: (adKey, data) {
          widget.onLog('${widget.title} - 로드 실패: $data');
          setState(() {
            _isLoading = false;
            _status = '로드 실패';
          });
        },
        onAdImpression: (adKey) {
          widget.onLog('${widget.title} - 노출');
        },
        onAdClicked: (adKey) {
          widget.onLog('${widget.title} - 클릭');
        },
        onShown: (adKey) {
          widget.onLog('${widget.title} - 표시');
          setState(() {
            _status = '표시됨';
          });
        },
        onRewarded: (adKey, data) {
          widget.onLog('${widget.title} - 리워드: $data');
        },
        onDismiss: (adKey) {
          widget.onLog('${widget.title} - 닫힘');
        },
        onFailedToShow: (adKey, data) {
          widget.onLog('${widget.title} - 표시 실패: $data');
          setState(() {
            _status = '표시 오류';
          });
        },
      ),
    );
    widget.onLog('${widget.title} - 인스턴스 생성 완료');
    setState(() {
      _status = '인스턴스 생성됨';
    });
  }

  Future<void> _loadAd() async {
    if (_ad == null) {
      widget.onLog('${widget.title} - 광고 인스턴스가 없습니다');
      // 인스턴스가 없으면 자동으로 생성하고 로드
      _createAd();
    }

    setState(() {
      _isLoading = true;
      _status = '로딩 중...';
    });

    await _ad!.load();
  }

  Future<void> _showAd() async {
    if (_ad == null) {
      // 인스턴스가 없으면 자동으로 생성하고 표시
      _createAd();
    }

    if (_ad == null) {
      widget.onLog('${widget.title} - 광고 인스턴스를 생성할 수 없습니다');
      return;
    }

    setState(() {
      _status = '표시 중...';
    });

    await _ad!.show();
  }

  Future<void> _disposeAd() async {
    if (_ad == null) {
      widget.onLog('${widget.title} - 광고 인스턴스가 없습니다');
      return;
    }

    await _ad!.dispose();
    widget.onLog('${widget.title} - 해제');
    setState(() {
      _ad = null;
      _isLoading = false;
      _status = '해제됨';
    });
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
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ad Key: ${widget.adKey}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadAd,
                  label: const Text('Load'),
                ),
                ElevatedButton.icon(
                  onPressed: _showAd,
                  label: const Text('Show'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
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
