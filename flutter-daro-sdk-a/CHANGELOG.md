## 0.9.10
2026.06.26
  - fix: resolve iOS banner/MREC not displaying
    - add Auto Layout constraints so the ad view fills its container (was .zero frame, invisible)
    - set rootViewController to the key window root VC to avoid a controller<->adView retain cycle
  - fix: select the top-most presented VC of the key window for interstitial/rewarded/popup
    - replace non-deterministic connectedScenes.first/windows.first with daroTopViewController()
  - fix: run ATT-callback ad load/show on the main thread (ATT callback is not main-thread guaranteed)

## 0.9.9
2026.06.24
  - chore: bump native DARO SDK dependencies to latest
    - Android: daro-a 1.3.6 → 1.5.7, daro-plugin 1.0.12 → 1.0.13
    - Android: remove deprecated daro-core (bundled into daro-a 1.4.0+)
    - iOS: DaroAds 1.1.45 → 1.1.65
  - fix: migrate Android native code for daro-a 1.4.0 breaking changes
    - droom.daro.Daro → droom.daro.a.Daro, SDKConfig 분리, setAppMute → setAppMuted
    - App Open Ad: DaroAppOpenAdLoader(internal 전환) → DaroAppOpenAdManager API로 마이그레이션

## 0.9.8
2026.02.11
  - feat: enhance iOS reward ad handling and options configuration

## 0.9.7
2026.01.16
  - fix: Initialize async exception handling

## 0.9.6
2026.01.10
  - fix: Improved ios initialize handling

## 0.9.5
2026.01.09
  - fix: android AdFactory lateinit issue

## 0.9.4
2026.01.08
  - ios formatting

## 0.9.3
2025.12.17
  - Error event formatting
  
## 0.9.2
2025.12.16
  - Improved package structure

## 0.9.1 
2025.12.16
  - Improved Banner constructor
  - Improved initialize and setOptions calls
  - Improved example structure

## 0.9.0
2025.12.15
  - Initial release
  - Non-Reward ad support (Banner, MREC, Interstitial, Rewarded Video, App Opening, Light Popup)
  - Android and iOS support
