# flutter_daro_sdk

DARO SDK Flutter plugin for Android and iOS.
> ⚠️ DARO 에서 제공하는 패키지가 아닙니다.

#### 구현 사항

- [x] Non-Reward
  - [x] 배너 & MREC 광고
  - [ ] 네이티브 광고
  - [x] 인터스티셜 광고
  - [x] 리워드 비디오 광고
  - [x] 앱 오프닝 광고
  - [x] 라이트 팝업 광고
- [ ] Reward



## 프로젝트 초기화

### Flutter

#### 요구사항
- 안드로이드 minSdkVersion : 26
- iOS 13.0 이상

> [app-ads.txt 파일 설정(링크)](https://guide.daro.so/ko/app-ads-txt-settings)이 잘 되었는지 다시 한 번 확인해주세요.

#### pubspec.yaml 추가

```yaml
flutter_daro_sdk: {version}
```
---
### Android

#### 1. android-daro-key.txt 추가
제공받은 android-daro-key.txt 파일을 추가합니다. 
> ⚠️ SDK를 초기화하기 위해서는 android-daro-key.txt 파일이 프로젝트에 반드시 포함되어야 합니다.
```
app/
 └── android-daro-key.txt

// flavor/buildType 별 분기가 필요한 경우
app/
└── src/
    ├── EnvA/
    │   └── android-daro-key.txt
    └── EnvB/
        └── android-daro-key.txt
```

#### 2. daroAppKey 설정
아래 중 한 곳에 daroAppKey를 설정합니다.
<details><summary>gradle.properties 에 설정 </summary>

```
android.useAndroidX=true
android.enableJetifier=true
daroAppKey={APP_KEY}

// flavor/buildType 별 분기가 필요한 경우
daroAppKey.EnvA={APP_KEY}
daroAppKey.EnvB={APP_KEY}
```
</details>

<details><summary>app 모듈의 gradle에 설정</summary>

```
buildscript{
    extra["daroAppKey"] = "APP_KEY"

    // flavor/buildType 별 분기가 필요한 경우
    extra["daroAppKey.EnvA"] = "APP_KEY"
    extra["daroAppKey.EnvB"] = "APP_KEY"
}
```
</details>

#### 3. build.gradle 설정

앱 프로젝트의 `android/app/build.gradle` (또는 `build.gradle.kts`)에 DARO 플러그인을 추가합니다:

**Non-Reward 앱인 경우:**
```kotlin
plugins {
    ...
    id("so.daro.a")  // Non-Reward 앱용 플러그인
}

dependencies {
    implementation("so.daro:daro-core:1.3.8")
    implementation("so.daro:daro-a:1.3.6")
}
```

#### 2. buildscript 설정

프로젝트 루트의 `android/build.gradle` (또는 `build.gradle.kts`)에 DARO 플러그인을 추가합니다:

**Non-Reward 앱인 경우:**
```kotlin
buildscript {
    dependencies {
        classpath("so.daro:daro-plugin:1.0.12")
    }
}
```

#### 3. 최소 SDK 버전

`android/app/build.gradle`에서 최소 SDK 버전을 26 이상으로 설정합니다:

```kotlin
android {
    defaultConfig {
        minSdk = 26
    }
}
```

---

### iOS

#### 요구사항

- iOS 13.0 이상
- Xcode 14.0 이상


#### 1. ios-daro-key.txt 추가
Xcode 프로젝트에 제공받은 ios-daro-key.txt 파일을 추가합니다.
> ⚠️ SDK를 초기화하기 위해서는 ios-daro-key.txt 파일이 프로젝트에 반드시 포함되어야 합니다.

Xcode > BuildPhase 예시
<img src="https://mintcdn.com/delightroom-5a71a6a8/zubkjN5vMaM7lt41/sdk-integration/ios_new/img/daro-key-import.png?w=1650&fit=max&auto=format&n=zubkjN5vMaM7lt41&q=85&s=8874b9f1304c93134dcfcbf8cedf8126" />

#### 2. Other Linker Flags 설정 (Objective-C)

> Objective-C로 개발하는 경우, 빌드 설정에 -ObjC 플래그를 반드시 추가해야 합니다. 
> 이 플래그가 없으면 SDK가 정상적으로 작동하지 않을 수 있습니다.
1. Xcode 프로젝트 설정에서 다음 단계를 진행하세요:
2. Xcode에서 프로젝트 파일을 선택합니다
3. Build Settings 탭을 선택합니다
4. 검색창에 “Other Linker Flags”를 입력합니다
5. Other Linker Flags 항목에 -ObjC를 추가합니다

#### 3. Info.plist 설정

앱 프로젝트의 `ios/Runner/Info.plist`에 앱 키를 추가합니다:

```xml
<key>GADApplicationIdentifier</key>
<string> /* Daro 대시보드에서 발급받은 Admob Key 추가 */ </string>
<key>DaroAppKey</key>
<string> /* Daro 대시보드에서 발급받은 Daro App Key 추가 */ </string>
<key>NSUserTrackingUsageDescription</key>
<string> /* 광고 제공을 위해 사용자 정보를 이용합니다 */ </string>
```

SKAdNetworkItems 를 추가합니다:
<details>
<summary>SKAdNetworkItems</summary>

```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4fzdc2evr5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4pfyvq9l8r.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>2fnua5tdw4.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ydx93a7ass.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>5a6flpkh64.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>p78axxw29g.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>v72qych5uu.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ludvb6z3bs.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cp8zw746q7.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>3sh42y64q3.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>c6k4g5qg8m.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>s39g8k73mm.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>3qy4746246.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>f38h382jlk.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>hs6bdukanm.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>v4nxqhlyqp.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>wzmmz9fp6w.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>yclnxrl5pm.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>t38b2kh725.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>7ug5zh24hu.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>gta9lk7p23.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>vutu7akeur.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>y5ghdn5j9k.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>n6fk4nfna4.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>v9wttpbfk9.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>n38lu8286q.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>47vhws6wlr.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>kbd757ywx3.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>9t245vhmpl.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>eh6m2bh4zr.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>a2p9lx4jpn.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>22mmun2rn5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4468km3ulz.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>2u9pt9hc89.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>8s468mfl3y.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>klf5c3l5u5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ppxm28t8ap.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ecpz2srf59.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>uw77j35x4d.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>pwa73g5rt2.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>mlmmfzh3r3.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>578prtvx9j.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4dzt52r2t5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>e5fvkxwrpn.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>8c4e2ghe7u.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>zq492l623r.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>3rd42ekr43.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>3qcr597p9d.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>mj797d8u6f.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>55644vm79v.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>6yxyv74ff7.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>55y65gfgn7.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cwn433xbcr.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>nu4557a4je.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>w7jznl3r6g.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>577p5t736z.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>6rd35atwn8.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>7bxrt786m8.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>7fbxrn65az.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>dt3cjx1a9i.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>fz2k2k5tej.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>jk2fsx2rgz.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>r8lj5b58b5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>tmhh9296z4.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>k6y4y55b64.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>qwpu75vrh2.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>252b5q8x7y.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4mn522wn87.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>7fmhfwg9en.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>8r8llnkz5a.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>dbu4b84rxf.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>dkc879ngq3.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>eh6m2bh4zr.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>f7s53z58qe.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>g6gcrrvk4p.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>gta8lk7p23.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>krvm3zuq6h.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>lr83yxwka7.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>mj797d8u6f.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>qu637u8glc.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>s69wq72ugq.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>v79kvwwj4g.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>vhf287vqwu.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>vutu7akeur.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>x5l83yy675.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>x8jxxk4ff5.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>x8uqf25wch.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>xga6mpmplv.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ln5gz23vtd.skadnetwork</string>
</dict>
<dict>
    <key>SKAdNetworkIdentifier</key>
    <string>z959bm4gru.skadnetwork</string>
</dict>
</array>

```
</details>

---

## 사용법

### 1. initialize - SDK 초기화

**중요**: 광고를 로드하기 전에 반드시 SDK를 초기화해야 합니다.

```dart
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';

// Non-Reward 앱 초기화
final success = await DaroSdk.initialize(
  options: DaroSdkOptions(  // optional
    userId : String
    logLevel : DaroLogLevel.debug,
    appMute: false,
  ),
);

if (success) {
  print('SDK 초기화 성공');
} else {
  print('SDK 초기화 실패');
}
```

#### DaroSdkConfig

- `DaroSdkConfig.nonReward()`: Non-Reward 앱용 설정

#### DaroSdkOptions (optional)

- `userId` (String?): 사용자 ID
- `logLevel` (DaroLogLevel?): 로그 레벨
  - `DaroLogLevel.off`: 로그 출력 없음
  - `DaroLogLevel.error`: 에러 로그만 출력
  - `DaroLogLevel.debug`: 모든 로그 출력 (개발 시 권장)
- `appMute` (bool?): 앱 음소거 설정

### 2. setOptions - SDK 옵션 설정

초기화 후 SDK 옵션을 변경할 수 있습니다:

```dart
final success = await DaroSdk.setOptions(
  DaroSdkOptions(
    userId: 'user-id',
    logLevel: DaroLogLevel.error,
    appMute: true,
  ),
);

if (success) {
  print('옵션 설정 성공');
}
```

### 3. bannerAd - 배너 광고

배너 광고는 `DaroBannerAdView` 위젯을 사용하여 표시합니다.

#### 기본 사용법

```dart
import 'package:flutter_daro_sdk/flutter_daro_sdk.dart';

// 320x50 배너
DaroBannerAdView(
  ad: DaroBannerAd.banner('your-ad-unit-id',
    placement: 'placement', // (optional)
  ),
  listener: DaroBannerAdListener(
    onAdLoaded: (ad) => print('광고 로드 완료'),
    onAdFailedToLoad: (ad, error) => print('광고 로드 실패: $error'),
    onAdImpression: (ad) => print('광고 노출'),
    onAdClicked: (ad) => print('광고 클릭'),
  ),
)

// 320x250 MREC 배너
DaroBannerAdView(
  ad: DaroBannerAd.mrec('your-ad-unit-id',
    placement: 'placement', // (optional)
  ),
  listener: DaroBannerAdListener(
    onAdLoaded: (ad) => print('광고 로드 완료'),
    onAdFailedToLoad: (ad, error) => print('광고 로드 실패: $error'),
    onAdImpression: (ad) => print('광고 노출'),
    onAdClicked: (ad) => print('광고 클릭'),
  ),
)
```


### 4. rewardAd - 리워드 광고

리워드 광고는 `DaroRewardAd` 클래스를 사용합니다. 지원하는 광고 타입:
- 전면광고 (`DaroInterstitialAd`)
- 리워드 비디오 광고 (`DaroRewardedVideoAd`)
- 팝업광고 (`DaroPopupAd`)
- 앱 오프닝 (`DaroOpeningAd`)

> - 각 리워드 광고는 `DaroRewardAd`를 상속받아 구현되어있습니다.
> - 각 리워드 광고는 `load()` 와 `show()`를 지원하며, `load()` 없이 `show()` 호출 시 로드가 완료되면 자동으로 노출됩니다.

#### 전면광고 (Interstitial)

```dart
// 광고 인스턴스 생성
final interstitialAd = DaroInterstitialAd('your-ad-unit-id');

// 이벤트 리스너 등록
interstitialAd.addListener(
  DaroRewardAdListener(
    onAdLoadSuccess: (adId) => print('광고 로드 성공: $adId'),
    onAdLoadFail: (adId, data) => print('광고 로드 실패: $adId, $data'),
    onShown: (adId) => print('광고 표시: $adId'),
    onAdImpression: (adId) => print('광고 노출: $adId'),
    onAdClicked: (adId) => print('광고 클릭: $adId'),
    onDismiss: (adId) => print('광고 닫힘: $adId'),
    onFailedToShow: (adId, data) => print('광고 표시 실패: $adId, $data'),
  ),
);

// 광고 로드
final loadSuccess = await interstitialAd.load();
if (loadSuccess) {
  print('광고 로드 성공');
  
  // 광고 표시
  final showSuccess = await interstitialAd.show();
  if (showSuccess) {
    print('광고 표시 성공');
  }
}

// 사용 후 해제
await interstitialAd.dispose();
```

#### 리워드 비디오 광고 (Rewarded Video)

```dart
// 광고 인스턴스 생성
final rewardedVideoAd = DaroRewardedVideoAd('your-ad-unit-id');

// 이벤트 리스너 등록
rewardedVideoAd.addListener(
  DaroRewardAdListener(
    onAdLoadSuccess: (adId) => print('광고 로드 성공: $adId'),
    onAdLoadFail: (adId, data) => print('광고 로드 실패: $adId, $data'),
    onShown: (adId) => print('광고 표시: $adId'),
    onRewarded: (adId, data) {
      final amount = data['reward']?['amount'] ?? 0;
      final type = data['reward']?['type'] ?? '';
      print('리워드 적립: $amount, 타입: $type');
    },
    onAdImpression: (adId) => print('광고 노출: $adId'),
    onAdClicked: (adId) => print('광고 클릭: $adId'),
    onDismiss: (adId) => print('광고 닫힘: $adId'),
    onFailedToShow: (adId, data) => print('광고 표시 실패: $adId, $data'),
  ),
);

// 광고 로드
final loadSuccess = await rewardedVideoAd.load();
if (loadSuccess) {
  // 광고 표시
  await rewardedVideoAd.show();
}

// 사용 후 해제
await rewardedVideoAd.dispose();
```

#### 팝업광고 (Popup)

```dart
// 광고 인스턴스 생성
final popupAd = DaroPopupAd('your-ad-unit-id',
  options: DaroPopupAdOptions(  // optional
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
  ),
);

// 이벤트 리스너 등록
popupAd.addListener(
  DaroRewardAdListener(
    onAdLoadSuccess: (adId) => print('광고 로드 성공: $adId'),
    onAdLoadFail: (adId, data) => print('광고 로드 실패: $adId, $data'),
    onShown: (adId) => print('광고 표시: $adId'),
    onAdImpression: (adId) => print('광고 노출: $adId'),
    onAdClicked: (adId) => print('광고 클릭: $adId'),
    onDismiss: (adId) => print('광고 닫힘: $adId'),
    onFailedToShow: (adId, data) => print('광고 표시 실패: $adId, $data'),
  ),
);

// 광고 로드
final loadSuccess = await popupAd.load();
if (loadSuccess) {
  // 광고 표시
  await popupAd.show();
}

// 사용 후 해제
await popupAd.dispose();
```

#### 앱 오프닝 (Opening)

```dart
// 광고 인스턴스 생성
final openingAd = DaroOpeningAd('your-ad-unit-id');

// 이벤트 리스너 등록
openingAd.addListener(
  DaroRewardAdListener(
    onAdLoadSuccess: (adId) => print('광고 로드 성공: $adId'),
    onAdLoadFail: (adId, data) => print('광고 로드 실패: $adId, $data'),
    onShown: (adId) => print('광고 표시: $adId'),
    onAdImpression: (adId) => print('광고 노출: $adId'),
    onAdClicked: (adId) => print('광고 클릭: $adId'),
    onDismiss: (adId) => print('광고 닫힘: $adId'),
    onFailedToShow: (adId, data) => print('광고 표시 실패: $adId, $data'),
  ),
);

// 광고 로드
final loadSuccess = await openingAd.load();
if (loadSuccess) {
  // 광고 표시
  await openingAd.show();
}

// 사용 후 해제
await openingAd.dispose();
```

#### 리워드 광고 이벤트

`DaroRewardAdListener`에서 사용 가능한 이벤트:

- `onAdLoadSuccess`: 광고 로드 성공
- `onAdLoadFail`: 광고 로드 실패
- `onShown`: 광고 표시됨
- `onRewarded`: 리워드 적립 (리워드 비디오 광고만)
- `onAdImpression`: 광고 노출 (성과 집계)
- `onAdClicked`: 광고 클릭
- `onDismiss`: 광고 닫힘
- `onFailedToShow`: 광고 표시 실패

## 주의사항

1. **리소스 해제**: 리워드 광고 인스턴스는 사용 후 `dispose()` 메서드를 호출하여 해제해야 합니다.
2. **앱 음소거**: `appMute` 옵션을 사용하면 동영상 광고 적합성이 저하되어 광고 수익이 감소할 수 있습니다. 사용자에게 맞춤 음소거 컨트롤을 제공하는 경우에만 사용하세요.
