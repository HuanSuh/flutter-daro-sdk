# flutter_daro_sdk

DARO SDK Flutter plugin for Android and iOS. Supports both Reward and Non-reward apps.

## 설치

`pubspec.yaml`에 다음을 추가하세요:

```yaml
dependencies:
  flutter_daro_sdk:
    git:
      url: https://github.com/your-repo/flutter-daro-sdk.git
      ref: main
```

또는 로컬에서 사용하는 경우:

```yaml
dependencies:
  flutter_daro_sdk:
    path: ./flutter-daro-sdk
```

## 사용 방법

### 1. SDK 초기화

앱 시작 시 SDK를 초기화하세요:

```dart
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';

// Reward 앱인 경우
await DaroSdk.initialize(DaroSdkConfig(
  appCategory: DaroAppCategory.reward,
  appKey: 'your-app-key', // 선택사항
  userId: 'user-id', // 선택사항
));

// Non-reward 앱인 경우
await DaroSdk.initialize(DaroSdkConfig(
  appCategory: DaroAppCategory.nonReward,
));
```

### 2. 광고 표시

```dart
final result = await DaroSdk.showAd();
if (result.success) {
  print('광고 표시 성공');
  if (result.rewardAmount != null) {
    print('리워드: ${result.rewardAmount}');
  }
} else {
  print('광고 표시 실패: ${result.errorMessage}');
}
```

### 3. 이벤트 구독

SDK에서 발생하는 이벤트를 구독할 수 있습니다:

```dart
DaroSdk.getEventStream()?.listen((event) {
  final eventName = event['event'] as String;
  final data = event['data'] as Map<dynamic, dynamic>;
  
  switch (eventName) {
    case 'adClosed':
      print('광고가 닫혔습니다');
      break;
    case 'rewardEarned':
      final amount = data['amount'] as int;
      print('리워드 적립: $amount');
      break;
  }
});
```

## 앱 카테고리 선택

DARO SDK는 두 가지 앱 카테고리를 지원합니다:

### Non-reward 앱
- 앱의 주요 목적이 현물성 리워드 제공 없이 특정 서비스나 기능을 제공하는 앱
- 예시: 유틸리티 앱, 플랫폼 앱, 쇼핑 앱, 음악 재생 앱, 메신저 앱 등

### Reward 앱
- 광고 시청을 통한 현물성 리워드 획득이 앱의 주요 기능인 앱
- 예시: 앱테크 앱, 현금과 직접적으로 1:1 교환할 수 있는 포인트 앱

## 네이티브 SDK 연동

이 플러그인은 DARO SDK의 네이티브 기능을 Flutter에서 사용할 수 있도록 래핑합니다. 실제 DARO SDK를 연동하려면:

### Android

1. `android/build.gradle`에 DARO SDK 의존성 추가
2. `android/src/main/kotlin/.../FlutterDaroSdkPlugin.kt`의 TODO 주석을 참고하여 실제 SDK 연동 코드 작성

### iOS

1. `ios/flutter_daro_sdk.podspec`에 DARO SDK 의존성 추가
2. `ios/Classes/FlutterDaroSdkPlugin.swift`의 TODO 주석을 참고하여 실제 SDK 연동 코드 작성

자세한 연동 가이드는 [DARO SDK 가이드](https://guide.daro.so)를 참고하세요.

## 참고사항

- 현재 게임 앱은 DARO SDK 연동이 지원되지 않습니다.
- 카테고리 선택에 어려움이 있으시다면 [cs@daro.so](mailto:cs@daro.so)으로 문의해주세요.

## 라이선스

이 프로젝트의 라이선스는 LICENSE 파일을 참고하세요.
