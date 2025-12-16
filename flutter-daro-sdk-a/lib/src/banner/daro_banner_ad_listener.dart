part of 'daro_banner_ad.dart';

enum DaroBannerAdEventType {
  onAdLoaded,
  onAdFailedToLoad,
  onAdImpression,
  onAdClicked;

  static DaroBannerAdEventType? byNameOrNull(String? eventType) {
    if (eventType == null) return null;
    try {
      return DaroBannerAdEventType.values.firstWhere(
        (e) => e.name == eventType,
      );
    } catch (_) {
      return null;
    }
  }

  DaroLogLevel get logLevel => switch (this) {
    onAdFailedToLoad => DaroLogLevel.error,
    _ => DaroLogLevel.debug,
  };
}

class DaroBannerAdListener {
  final void Function(DaroBannerAd ad)? onAdLoaded;
  final void Function(DaroBannerAd ad, DaroError error)? onAdFailedToLoad;
  final void Function(DaroBannerAd ad)? onAdImpression;
  final void Function(DaroBannerAd ad)? onAdClicked;

  DaroBannerAdListener({
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdImpression,
    this.onAdClicked,
  });
}
