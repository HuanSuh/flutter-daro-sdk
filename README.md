# flutter_daro_sdk

DARO SDK Flutter plugin for Android and iOS. Supports both Reward and Non-reward apps.

## 프로젝트 구조

이 프로젝트는 세 개의 플러그인으로 구성되어 있습니다:

- **flutter_daro_sdk**: 공통 SDK 기능을 제공하는 메인 플러그인
- **daro_core_a**: Non-Reward 앱용 네이티브 의존성을 제공하는 플러그인
- **daro_core_m**: Reward 앱용 네이티브 의존성을 제공하는 플러그인

## 설치

### Reward 앱인 경우

`pubspec.yaml`에 다음을 추가하세요:

```yaml
dependencies:
  flutter_daro_sdk:
    git:
      url: https://github.com/your-repo/flutter-daro-sdk.git
      ref: main
  daro_core_m:
    git:
      url: https://github.com/your-repo/flutter-daro-sdk.git
      ref: main
      path: core/daro-core-m
```

또는 로컬에서 사용하는 경우:

```yaml
dependencies:
  flutter_daro_sdk:
    path: ./flutter-daro-sdk
  daro_core_m:
    path: ./flutter-daro-sdk/core/daro-core-m
```

### Non-Reward 앱인 경우

`pubspec.yaml`에 다음을 추가하세요:

```yaml
dependencies:
  flutter_daro_sdk:
    git:
      url: https://github.com/your-repo/flutter-daro-sdk.git
      ref: main
  daro_core_a:
    git:
      url: https://github.com/your-repo/flutter-daro-sdk.git
      ref: main
      path: core/daro-core-a
```

또는 로컬에서 사용하는 경우:

```yaml
dependencies:
  flutter_daro_sdk:
    path: ./flutter-daro-sdk
  daro_core_a:
    path: ./flutter-daro-sdk/core/daro-core-a
```

> **중요**: `flutter_daro_sdk`와 함께 반드시 해당 앱 카테고리에 맞는 core 플러그인(`daro_core_a` 또는 `daro_core_m`)을 함께 추가해야 합니다.

## 사용 방법

### 1. SDK 초기화

**중요**: 광고를 로드하기 전에 반드시 SDK를 초기화해야 합니다. 초기화 전 광고를 요청하면 광고가 정상적으로 표시되지 않을 수 있습니다.

앱 시작 시 SDK를 초기화하세요:

```dart
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';

// Reward 앱인 경우
final success = await DaroSdk.initialize(DaroSdkConfig(
  appCategory: DaroAppCategory.reward,
  appKey: 'your-app-key', // 선택사항
  userId: 'user-id', // 선택사항
));

if (success) {
  print('SDK 초기화 성공');
  // 광고 로드 및 표시 진행
} else {
  print('SDK 초기화 실패');
  // 에러 처리
}

// Non-reward 앱인 경우
final success = await DaroSdk.initialize(DaroSdkConfig(
  appCategory: DaroAppCategory.nonReward,
  appKey: 'your-app-key', // 선택사항
));

if (success) {
  print('SDK 초기화 성공');
} else {
  print('SDK 초기화 실패');
}
```

`initialize()` 메서드는 초기화 성공 여부를 `bool` 값으로 반환합니다.

### 2. 리워드 광고 표시

광고 타입(전면광고, 리워드 비디오 광고, 팝업광고)과 광고 키를 지정하여 광고를 표시합니다:

```dart
// 리워드 비디오 광고 표시
final result = await DaroSdk.showRewardAd(DaroRewardAdConfig(
  adType: DaroAdType.rewardedVideo,
  adKey: 'your-ad-key', // 선택사항
  extraParams: {'customParam': 'value'}, // 선택사항
));

if (result.success) {
  print('광고 ID: ${result.adId}');
  
  // 광고 이벤트 리스너 등록
  DaroSdk.addAdListener(result.adId, (adId, event) {
    final eventType = event['type'] as String;
    final data = event['data'] as Map<dynamic, dynamic>;
    
    switch (eventType) {
      case 'adShown':
        print('광고가 표시되었습니다');
        break;
      case 'adClosed':
        print('광고가 닫혔습니다');
        break;
      case 'rewardEarned':
        final amount = data['amount'] as int;
        print('리워드 적립: $amount');
        break;
      case 'error':
        final errorMessage = data['errorMessage'] as String;
        print('에러 발생: $errorMessage');
        break;
    }
  });
  
  if (result.rewardAmount != null) {
    print('리워드: ${result.rewardAmount}');
  }
} else {
  print('광고 표시 실패: ${result.errorMessage}');
}
```

### 3. 광고 타입

지원하는 광고 타입:

- `DaroAdType.interstitial`: 전면광고
- `DaroAdType.rewardedVideo`: 리워드 비디오 광고
- `DaroAdType.popup`: 팝업광고

### 4. 이벤트 리스너 관리

광고 인스턴스별로 이벤트 리스너를 등록하고 제거할 수 있습니다:

```dart
// 리스너 등록
DaroSdk.addAdListener('ad-id', (adId, event) {
  // 이벤트 처리
});

// 리스너 제거
DaroSdk.removeAdListener('ad-id');
```

## 앱 카테고리 선택

DARO SDK는 두 가지 앱 카테고리를 지원합니다:

### Non-reward 앱
- 앱의 주요 목적이 현물성 리워드 제공 없이 특정 서비스나 기능을 제공하는 앱
- 예시: 유틸리티 앱, 플랫폼 앱, 쇼핑 앱, 음악 재생 앱, 메신저 앱 등

### Reward 앱
- 광고 시청을 통한 현물성 리워드 획득이 앱의 주요 기능인 앱
- 예시: 앱테크 앱, 현금과 직접적으로 1:1 교환할 수 있는 포인트 앱

## 플러그인별 역할

### flutter_daro_sdk (메인 플러그인)
- 공통 SDK 기능 제공
- Flutter와 네이티브 간 통신 처리
- 광고 로드/표시/이벤트 관리

### daro_core_a (Non-Reward 앱용)
- Non-Reward 앱용 Android/iOS 네이티브 의존성 제공
- Non-Reward 앱용 Maven 저장소 및 플러그인 설정 포함
- ProGuard 규칙 포함

### daro_core_m (Reward 앱용)
- Reward 앱용 Android/iOS 네이티브 의존성 제공
- Reward 앱용 Maven 저장소 및 플러그인 설정 포함
- AppLovin Quality Service 플러그인 포함

## 네이티브 SDK 연동

이 플러그인은 DARO SDK의 네이티브 기능을 Flutter에서 사용할 수 있도록 래핑합니다. 실제 DARO SDK를 연동하려면:

### Android 설정

#### Core 플러그인 설정

**Non-Reward 앱 (`daro_core_a`)의 경우:**

`core/daro-core-a/android/build.gradle`에서 TODO 주석을 제거하고 실제 설정을 적용하세요:

```groovy
buildscript {
    dependencies {
        classpath("so.daro:daro-plugin:1.0.12")
    }
}

apply plugin: "so.daro.a"
```

**Reward 앱 (`daro_core_m`)의 경우:**

`core/daro-core-m/android/build.gradle`에서 TODO 주석을 제거하고 실제 설정을 적용하세요:

```groovy
buildscript {
    dependencies {
        classpath("so.daro:daro-plugin:1.0.12")
        classpath("com.applovin.quality:AppLovinQualityServiceGradlePlugin:5.5.2")
    }
}

apply plugin: "so.daro.m"
```

#### 1. Maven 저장소 설정

각 core 플러그인의 `android/settings.gradle`에 필요한 Maven 저장소가 이미 추가되어 있습니다:
- `core/daro-core-a/android/settings.gradle`: Non-Reward 앱용 저장소
- `core/daro-core-m/android/settings.gradle`: Reward 앱용 저장소

#### 2. DARO 플러그인 추가 및 적용

각 core 플러그인의 `android/build.gradle`에서 TODO 주석을 제거하고 실제 설정을 적용하세요. 위의 "Core 플러그인 설정" 섹션을 참고하세요.

#### 3. 최소 SDK 버전

각 core 플러그인에서 `minSdk = 23`으로 설정되어 있습니다 (DARO SDK 요구사항).

#### 4. ProGuard 규칙

- **Non-Reward 앱 (`daro_core_a`)**: `core/daro-core-a/android/proguard-rules.pro` 파일이 포함되어 있습니다.
- **Reward 앱 (`daro_core_m`)**: 별도로 proguard를 설정하지 않아도 됩니다.

#### 5. 앱 키 설정 (선택사항)

앱 프로젝트의 `android/gradle.properties`에 앱 키를 설정할 수 있습니다:

```properties
daroAppKey=YOUR_APP_KEY
```

또는 flavor/buildType별로 분기할 수 있습니다:

```properties
daroAppKey.Production=YOUR_PRODUCTION_KEY
daroAppKey.Development=YOUR_DEVELOPMENT_KEY
```

#### 6. SDK 초기화

`flutter_daro_sdk/android/src/main/kotlin/.../FlutterDaroSdkPlugin.kt`의 `initialize()` 메서드에서 실제 SDK 초기화 코드를 작성하세요.

**Android 초기화 예시:**

```kotlin
import droom.daro.Daro

val sdkConfig = Daro.SDKConfig.Builder()
  .setDebugMode(false) // Daro 로그 노출 여부, default: false
  .setAppMute(false)   // 앱 음소거 설정, default: false
  .build()

Daro.init(
  application = currentActivity.application,
  sdkConfig = sdkConfig
)

// 초기화 성공
result.success(true)
```

**앱 음소거 설정:**

앱 오프닝, 배너, 전면 광고, 보상형, 보상형 전면 광고 형식의 경우 `setAppMute()` 메서드를 사용하여 앱 볼륨이 음소거되었음을 DARO SDK에 알릴 수 있습니다:

```kotlin
// 앱 음소거 설정
Daro.setAppMute(true)

// 앱 음소거 해제
Daro.setAppMute(false)
```

> **주의**: 앱을 음소거하면 동영상 광고 적합성이 저하되어 앱의 광고 수익이 감소할 수 있습니다. 앱이 사용자에게 맞춤 음소거 컨트롤을 제공하고 사용자의 음소거 결정이 API에 제대로 반영되는 경우에만 이 API를 활용해야 합니다.

자세한 내용은 [DARO Android SDK 가이드](https://guide.daro.so/ko/sdk-integration/android/get-started#sdk-%EC%B4%88%EA%B8%B0%ED%99%94%ED%95%98%EA%B8%B0)를 참고하세요.

### iOS 설정

#### 1. CocoaPods 의존성

**Reward 앱 (`daro_core_m`)의 경우:**

`core/daro-core-m/ios/flutter_daro_sdk.podspec`에 DARO SDK 의존성을 추가하세요:

```ruby
s.dependency 'DaroAds', '~> 1.1.45'
```

최신 버전은 [DARO iOS SDK 릴리즈](https://github.com/delightroom/daro-ios-sdk/releases)에서 확인하세요.

**Non-Reward 앱 (`daro_core_a`)의 경우:**

Non-Reward 앱용 iOS SDK 의존성이 필요한 경우 `core/daro-core-a/ios/flutter_daro_sdk.podspec`에 추가하세요.

#### 2. Podfile 설정

앱 프로젝트의 `ios/Podfile`에 다음을 추가하세요:

```ruby
use_frameworks!

# DARO SDK
pod 'DaroAds', '~> 1.1.45'
```

그리고 다음 명령어를 실행하세요:

```bash
cd ios
pod install --repo-update
```

#### 3. Info.plist 설정

앱 프로젝트의 `ios/Runner/Info.plist`에 다음을 추가하세요:

```xml
<key>DaroAppKey</key>
<string>YOUR_DARO_APP_KEY</string>
```

#### 4. SDK 초기화

`flutter_daro_sdk/ios/Classes/FlutterDaroSdkPlugin.swift`의 `initialize()` 메서드에서 실제 SDK 초기화 코드를 작성하세요.

**iOS 초기화 예시:**

```swift
import DaroAds

let config = DaroSdkConfig(
  debugMode: false, // Daro 로그 노출 여부, default: false
  appMute: false    // 앱 음소거 설정, default: false
)

DaroSdk.shared.initialize(config: config) { success, error in
  if success {
    result(true)
  } else {
    result(false)
  }
}
```

**앱 음소거 설정:**

앱 오프닝, 배너, 전면 광고, 보상형, 보상형 전면 광고 형식의 경우 `setAppMute()` 메서드를 사용하여 앱 볼륨이 음소거되었음을 DARO SDK에 알릴 수 있습니다:

```swift
// 앱 음소거 설정
DaroSdk.shared.setAppMute(true)

// 앱 음소거 해제
DaroSdk.shared.setAppMute(false)
```

> **주의**: 앱을 음소거하면 동영상 광고 적합성이 저하되어 앱의 광고 수익이 감소할 수 있습니다. 앱이 사용자에게 맞춤 음소거 컨트롤을 제공하고 사용자의 음소거 결정이 API에 제대로 반영되는 경우에만 이 API를 활용해야 합니다.

자세한 내용은 [DARO iOS SDK 가이드](https://guide.daro.so/ko/sdk-integration/ios_new/get-started#sdk-%EC%B4%88%EA%B8%B0%ED%99%94%ED%95%98%EA%B8%B0)를 참고하세요.

## 예제 프로젝트

프로젝트에는 두 개의 예제 프로젝트가 포함되어 있습니다:

- **example-reward**: Reward 앱용 예제 프로젝트
  - `daro_core_m` 플러그인 사용
  - `DaroAppCategory.reward`로 초기화
  - Reward 앱 개발 시 참고

- **example-nonreward**: Non-Reward 앱용 예제 프로젝트
  - `daro_core_a` 플러그인 사용
  - `DaroAppCategory.nonReward`로 초기화
  - Non-Reward 앱 개발 시 참고

각 예제 프로젝트에서 각 광고 타입별로 load/show/dispose 기능을 테스트할 수 있습니다.

## 프로젝트 구조 요약

```
flutter-daro-sdk/
├── lib/                          # flutter_daro_sdk 메인 플러그인
│   ├── flutter_daro_sdk.dart
│   ├── flutter_daro_sdk_platform_interface.dart
│   └── flutter_daro_sdk_method_channel.dart
├── android/                      # flutter_daro_sdk Android 구현
├── ios/                          # flutter_daro_sdk iOS 구현
├── core/                          # Core 플러그인 폴더
│   ├── daro-core-a/              # Non-Reward 앱용 core 플러그인
│   │   ├── lib/
│   │   ├── android/               # Non-Reward 앱용 Android 설정
│   │   └── ios/                   # Non-Reward 앱용 iOS 설정
│   └── daro-core-m/               # Reward 앱용 core 플러그인
│       ├── lib/
│       ├── android/               # Reward 앱용 Android 설정
│       └── ios/                   # Reward 앱용 iOS 설정
└── example/                       # 예제 프로젝트 폴더
    ├── example-reward/            # Reward 앱용 예제 프로젝트
    │   ├── lib/main.dart
    │   ├── android/
    │   └── ios/
    └── example-nonreward/        # Non-Reward 앱용 예제 프로젝트
        ├── lib/main.dart
        ├── android/
        └── ios/
```

## 참고사항

- 현재 게임 앱은 DARO SDK 연동이 지원되지 않습니다.
- 카테고리 선택에 어려움이 있으시다면 [cs@daro.so](mailto:cs@daro.so)으로 문의해주세요.

## 라이선스

이 프로젝트의 라이선스는 LICENSE 파일을 참고하세요.
