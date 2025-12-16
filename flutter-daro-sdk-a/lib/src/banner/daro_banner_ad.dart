import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';
import 'package:flutter_daro_sdk/src/daro_error.dart';

part 'daro_banner_ad_listener.dart';

enum DaroBannerAdSize {
  /// 320x50 배너
  banner('banner', 320, 50),

  /// 300x250 배너 (MREC)
  mrec('mrec', 300, 250);

  final int width;
  final int height;
  final String value;

  const DaroBannerAdSize(this.value, this.width, this.height);
}

class DaroBannerAd {
  final DaroBannerAdSize size;
  final String adUnit;
  final String? placement;

  DaroBannerAd(this.adUnit, this.size, {this.placement});

  factory DaroBannerAd.banner(String adUnit, {String? placement}) {
    return DaroBannerAd(adUnit, DaroBannerAdSize.banner, placement: placement);
  }

  factory DaroBannerAd.mrec(String adUnit, {String? placement}) {
    return DaroBannerAd(adUnit, DaroBannerAdSize.mrec, placement: placement);
  }
}

class DaroBannerAdView extends StatefulWidget {
  final DaroBannerAd ad;
  final DaroBannerAdListener? listener;
  const DaroBannerAdView({required this.ad, this.listener, super.key});

  @override
  State<DaroBannerAdView> createState() => _DaroBannerAdViewState();
}

class _DaroBannerAdViewState extends State<DaroBannerAdView>
    with AutomaticKeepAliveClientMixin {
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
    _eventChannel = EventChannel(
      "${_eventChannelName}_$viewId",
      const JSONMethodCodec(),
    );
    _eventChannel?.receiveBroadcastStream().listen(_processNativeEvent);
  }

  @override
  void dispose() {
    _eventChannel = null;
    super.dispose();
  }

  void _processNativeEvent(dynamic data) async {
    final eventType = DaroBannerAdEventType.byNameOrNull(
      data['event'] as String?,
    );
    if (eventType?.logLevel case DaroLogLevel logLevel
        when logLevel.index <= DaroSdk.logLevel.index) {
      debugPrint(
        '[DARO] $eventType - ${widget.ad.adUnit} ${data['data'] ?? ''}',
      );
    }
    switch (eventType) {
      case DaroBannerAdEventType.onAdLoaded:
        widget.listener?.onAdLoaded?.call(widget.ad);
      case DaroBannerAdEventType.onAdFailedToLoad:
        widget.listener?.onAdFailedToLoad?.call(
          widget.ad,
          DaroError.fromJson(data['data']),
        );
      case DaroBannerAdEventType.onAdImpression:
        widget.listener?.onAdImpression?.call(widget.ad);
      case DaroBannerAdEventType.onAdClicked:
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
      return SizedBox(
        width: widget.ad.size.width.toDouble(),
        height: widget.ad.size.height.toDouble(),
        child: child,
      );
    } catch (e) {
      widget.listener?.onAdFailedToLoad?.call(widget.ad, DaroError.fromJson(e));
      return Container();
    }
  }
}
