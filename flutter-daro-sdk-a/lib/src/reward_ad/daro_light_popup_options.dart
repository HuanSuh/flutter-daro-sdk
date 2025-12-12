part of 'daro_reward_ad.dart';

class DaroPopupAdOptions {
  // 전체 배경 색
  final Color backgroundColor;
  // 팝업 컨테이너 배경색
  final Color containerColor;
  // 상단 광고 마크 텍스트 색상
  final Color adMarkLabelTextColor;
  // 상단 광고 마크 배경색
  final Color adMarkLabelBackgroundColor;
  // 타이틀 텍스트 색상
  final Color titleColor;
  // 본문 텍스트 색상
  final Color bodyColor;
  // CTA(버튼) 배경색
  final Color ctaBackgroundColor;
  // CTA(버튼) 텍스트 색상
  final Color ctaTextColor;
  // 닫기 버튼 텍스트
  final String closeButtonText;
  // 닫기 버튼 텍스트 색상
  final Color closeButtonColor;

  DaroPopupAdOptions({
    this.backgroundColor = Colors.black26,
    this.containerColor = Colors.white,
    this.adMarkLabelTextColor = Colors.black,
    this.adMarkLabelBackgroundColor = Colors.black12,
    this.titleColor = Colors.black,
    this.bodyColor = Colors.black,
    this.ctaBackgroundColor = Colors.blue,
    this.ctaTextColor = Colors.white,
    this.closeButtonText = '닫기',
    this.closeButtonColor = Colors.white,
  });

  factory DaroPopupAdOptions.light({String closeButtonText = '닫기'}) {
    return DaroPopupAdOptions(closeButtonText: closeButtonText);
  }
  factory DaroPopupAdOptions.dark({String closeButtonText = '닫기'}) {
    return DaroPopupAdOptions(
      backgroundColor: Colors.black26,
      containerColor: Colors.black,
      adMarkLabelTextColor: Colors.white,
      adMarkLabelBackgroundColor: Colors.black12,
      titleColor: Colors.white,
      bodyColor: Colors.white,
      ctaBackgroundColor: Colors.blue,
      ctaTextColor: Colors.white,
      closeButtonText: closeButtonText,
      closeButtonColor: Colors.white,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'backgroundColor': backgroundColor.toARGB32(),
      'containerColor': containerColor.toARGB32(),
      'adMarkLabelTextColor': adMarkLabelTextColor.toARGB32(),
      'adMarkLabelBackgroundColor': adMarkLabelBackgroundColor.toARGB32(),
      'titleColor': titleColor.toARGB32(),
      'bodyColor': bodyColor.toARGB32(),
      'ctaBackgroundColor': ctaBackgroundColor.toARGB32(),
      'ctaTextColor': ctaTextColor.toARGB32(),
      'closeButtonText': closeButtonText,
      'closeButtonColor': closeButtonColor.toARGB32(),
    };
  }
}
