import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum DaroBannerAdSize {
  /// 320x50 배너
  banner320x50('banner', 320, 50),

  /// 320x250 배너 (MREC)
  banner320x250('mrec', 300, 250);

  final int width;
  final int height;
  final String value;

  const DaroBannerAdSize(this.value, this.width, this.height);
}

class DaroBannerAd {
  final DaroBannerAdSize size;
  final String adUnit;
  final String? placement;

  DaroBannerAd._(this.adUnit, this.size, {this.placement});

  factory DaroBannerAd.banner(String adUnit, {String? placement}) {
    return DaroBannerAd._(adUnit, DaroBannerAdSize.banner320x50, placement: placement);
  }

  factory DaroBannerAd.mrec(String adUnit, {String? placement}) {
    return DaroBannerAd._(adUnit, DaroBannerAdSize.banner320x250, placement: placement);
  }
}

enum DaroBannerAdEventType {
  onAdLoaded,
  onAdFailedToLoad,
  onAdImpression,
  onAdClicked;

  static DaroBannerAdEventType? byName(String? eventType) {
    if (eventType == null) return null;
    try {
      return DaroBannerAdEventType.values.firstWhere((e) => e.name == eventType);
    } catch (_) {
      return null;
    }
  }
}

class DaroBannerAdListener {
  final void Function(DaroBannerAd ad)? onAdLoaded;
  final void Function(DaroBannerAd ad, dynamic error)? onAdFailedToLoad;
  final void Function(DaroBannerAd ad)? onAdImpression;
  final void Function(DaroBannerAd ad)? onAdClicked;

  DaroBannerAdListener({this.onAdLoaded, this.onAdFailedToLoad, this.onAdImpression, this.onAdClicked});
}

class DaroBannerAdView extends StatefulWidget {
  final DaroBannerAd ad;
  final DaroBannerAdListener? listener;
  const DaroBannerAdView({required this.ad, this.listener, super.key});

  @override
  State<DaroBannerAdView> createState() => _DaroBannerAdViewState();
}

class _DaroBannerAdViewState extends State<DaroBannerAdView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const String _viewType = 'flutter_daro_banner_view';
  static const String _eventChannelName = 'com.daro.flutter_daro_sdk/events';
  Map<String, dynamic> get _creationParams => {
    "adUnit": widget.ad.adUnit,
    "placement": widget.ad.placement,
    "adSize": widget.ad.size.value,
  };

  EventChannel? _eventChannel;
  void _listenForNativeEvents(int viewId) {
    _eventChannel = EventChannel("${_eventChannelName}_$viewId", const JSONMethodCodec());
    _eventChannel?.receiveBroadcastStream().listen(_processNativeEvent);
  }

  @override
  void dispose() {
    _eventChannel = null;
    super.dispose();
  }

  void _processNativeEvent(dynamic data) async {
    final eventType = DaroBannerAdEventType.byName(data['event'] as String?);
    switch (eventType) {
      case DaroBannerAdEventType.onAdLoaded:
        debugPrint('[DARO] onAdLoaded: ${widget.ad.adUnit}');
        widget.listener?.onAdLoaded?.call(widget.ad);
      case DaroBannerAdEventType.onAdFailedToLoad:
        debugPrint('[DARO] onAdFailedToLoad: ${widget.ad.adUnit} ${data['data']}');
        widget.listener?.onAdFailedToLoad?.call(widget.ad, data['data']);
      case DaroBannerAdEventType.onAdImpression:
        debugPrint('[DARO] onAdImpression: ${widget.ad.adUnit}');
        widget.listener?.onAdImpression?.call(widget.ad);
      case DaroBannerAdEventType.onAdClicked:
        debugPrint('[DARO] onAdClicked: ${widget.ad.adUnit}');
        widget.listener?.onAdClicked?.call(widget.ad);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _buildBannerView(
          AndroidView(
            viewType: _viewType,
            onPlatformViewCreated: _listenForNativeEvents,
            creationParams: _creationParams,
            creationParamsCodec: const JSONMessageCodec(),
          ),
        );
      case TargetPlatform.iOS:
        return _buildBannerView(
          UiKitView(
            viewType: _viewType,
            onPlatformViewCreated: _listenForNativeEvents,
            creationParams: _creationParams,
            creationParamsCodec: const JSONMessageCodec(),
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildBannerView(Widget child) {
    try {
      return SizedBox(width: widget.ad.size.width.toDouble(), height: widget.ad.size.height.toDouble(), child: child);
    } catch (e) {
      widget.listener?.onAdFailedToLoad?.call(widget.ad, e);
      return Container();
    }
  }
}
