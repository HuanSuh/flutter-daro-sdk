import Flutter
import UIKit

public class FlutterDaroSdkPlugin: NSObject, FlutterPlugin {
  /// MethodChannel for method calls from Flutter
  private var methodChannel: FlutterMethodChannel?
  
  /// EventChannel for sending events to Flutter
  private var eventChannel: FlutterEventChannel?
  private var eventSink: FlutterEventSink?
  
  /// DARO SDK 인스턴스 (실제 DARO SDK로 교체 필요)
  // private var daroSdk: DaroSdk?
  
  /// 앱 카테고리 타입
  private var appCategory: String?
  
  /// 리워드 광고 인스턴스 맵 (타입과 adKey를 조합한 키 사용: "type:adKey")
  private var rewardAdMap: [String: RewardAdInstance] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FlutterDaroSdkPlugin()
    
    // MethodChannel 설정
    let methodChannel = FlutterMethodChannel(
      name: "com.daro.flutter_daro_sdk/channel",
      binaryMessenger: registrar.messenger()
    )
    instance.methodChannel = methodChannel
    registrar.addMethodCallDelegate(instance, channel: methodChannel)
    
    // EventChannel 설정
    let eventChannel = FlutterEventChannel(
      name: "com.daro.flutter_daro_sdk/events",
      binaryMessenger: registrar.messenger()
    )
    instance.eventChannel = eventChannel
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      initialize(call: call, result: result)
    case "showRewardAd":
      showRewardAd(call: call, result: result)
    case "loadRewardAd":
      loadRewardAd(call: call, result: result)
    case "showRewardAdInstance":
      showRewardAdInstance(call: call, result: result)
    case "disposeRewardAd":
      disposeRewardAd(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// SDK 초기화
  private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(false)
      return
    }
    
    appCategory = args["appCategory"] as? String
    let appKey = args["appKey"] as? String
    let userId = args["userId"] as? String
    
    // TODO: 실제 DARO SDK 초기화 코드로 교체
    // 문서 참고: https://guide.daro.so/ko/sdk-integration/ios_new/get-started#sdk-%EC%B4%88%EA%B8%B0%ED%99%94%ED%95%98%EA%B8%B0
    // 
    // import DaroAds
    // 
    // let config = DaroSdkConfig(
    //   debugMode: false, // Daro 로그 노출 여부, default: false
    //   appMute: false    // 앱 음소거 설정, default: false
    // )
    // 
    // DaroSdk.shared.initialize(config: config) { success, error in
    //   if success {
    //     result(true)
    //   } else {
    //     result(false)
    //   }
    // }
    
    // 임시 구현: 초기화 성공으로 처리
    result(true)
  }

  /// 리워드 광고 표시
  private func showRewardAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
      let adResult: [String: Any] = [
        "adId": "",
        "success": false,
        "errorMessage": "No root view controller available"
      ]
      result(adResult)
      return
    }
    
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "Invalid arguments for showRewardAd",
        details: nil
      ))
      return
    }
    
    guard let adType = args["adType"] as? String else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "adType is required",
        details: nil
      ))
      return
    }
    
    let adKey = args["adKey"] as? String
    let extraParams = args["extraParams"] as? [String: Any]
    
    // 고유한 광고 ID 생성
    let adId = UUID().uuidString
    
    // TODO: 실제 DARO SDK 광고 표시 코드로 교체
    // 예시:
    // let adConfig = DaroAdConfig(
    //   adType: adType, // "interstitial", "rewardedVideo", "popup"
    //   adKey: adKey,
    //   extraParams: extraParams
    // )
    // 
    // daroSdk?.showRewardAd(
    //   viewController: rootViewController,
    //   config: adConfig,
    //   onAdShown: {
    //     // 광고 표시 성공
    //     self.sendAdEvent(adId: adId, eventType: "adShown", data: ["success": true])
    //   },
    //   onAdClosed: {
    //     // 광고 닫힘
    //     self.sendAdEvent(adId: adId, eventType: "adClosed", data: ["success": true])
    //   },
    //   onRewardEarned: { amount in
    //     // 리워드 적립
    //     self.sendAdEvent(adId: adId, eventType: "rewardEarned", data: ["amount": amount])
    //   },
    //   onError: { error in
    //     self.sendAdEvent(adId: adId, eventType: "error", data: ["errorMessage": error])
    //   }
    // )
    
    // 임시 구현: 광고 표시 성공으로 처리
    let adResult: [String: Any] = [
      "adId": adId,
      "success": true,
      "rewardAmount": (appCategory == "reward" && adType == "rewardedVideo") ? 100 : nil
    ]
    result(adResult)
    
    // 임시 이벤트 전송 (실제로는 SDK 콜백에서 호출)
    sendAdEvent(adId: adId, eventType: "adShown", data: ["success": true])
  }

  /// 광고 ID별 이벤트를 Flutter로 전송
  private func sendAdEvent(adId: String, eventType: String, data: [String: Any?]) {
    let event: [String: Any] = [
      "adId": adId,
      "event": [
        "type": eventType,
        "data": data
      ]
    ]
    eventSink?(event)
  }
  
  /// 리워드 광고 이벤트를 Flutter로 전송
  private func sendRewardAdEvent(adKey: String, eventType: String, data: [String: Any?]) {
    let event: [String: Any] = [
      "adKey": adKey,
      "event": [
        "type": eventType,
        "data": data
      ]
    ]
    eventSink?(event)
  }
  
  /// 타입과 키를 조합한 맵 키 생성
  private func getRewardAdMapKey(adType: String, adKey: String) -> String {
    return "\(adType):\(adKey)"
  }
  
  /// 리워드 광고 로드
  private func loadRewardAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "Invalid arguments for loadRewardAd",
        details: nil
      ))
      return
    }
    
    guard let adType = args["adType"] as? String else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "adType is required",
        details: nil
      ))
      return
    }
    
    guard let adKey = args["adKey"] as? String else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "adKey is required",
        details: nil
      ))
      return
    }
    
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
      result(FlutterError(
        code: "NO_VIEW_CONTROLLER",
        message: "No root view controller available to load ad",
        details: nil
      ))
      return
    }
    
    let placement = args["placement"] as? String
    let mapKey = getRewardAdMapKey(adType: adType, adKey: adKey)
    
    // 기존 인스턴스가 있으면 해제
    rewardAdMap[mapKey]?.destroy()
    
    // 새로운 리워드 광고 인스턴스 생성
    let adInstance = RewardAdInstance(
      adType: adType,
      adKey: adKey,
      placement: placement,
      viewController: rootViewController,
      onEvent: { [weak self] eventType, data in
        self?.sendRewardAdEvent(adKey: adKey, eventType: eventType, data: data)
      }
    )
    
    // 인스턴스를 맵에 저장
    rewardAdMap[mapKey] = adInstance
    
    // 광고 로드
    adInstance.load { success, error in
      if success {
        result(nil)
      } else {
        result(FlutterError(
          code: "LOAD_ERROR",
          message: error ?? "Unknown error",
          details: nil
        ))
      }
    }
  }
  
  /// 리워드 광고 인스턴스 표시
  private func showRewardAdInstance(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(false)
      return
    }
    
    guard let adType = args["adType"] as? String else {
      result(false)
      return
    }
    
    guard let adKey = args["adKey"] as? String else {
      result(false)
      return
    }
    
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
      result(false)
      return
    }
    
    let placement = args["placement"] as? String
    let mapKey = getRewardAdMapKey(adType: adType, adKey: adKey)
    var adInstance = rewardAdMap[mapKey]
    
    // 인스턴스가 없으면 자동으로 생성하고 로드
    if adInstance == nil {
      // 새로운 리워드 광고 인스턴스 생성
      adInstance = RewardAdInstance(
        adType: adType,
        adKey: adKey,
        placement: placement,
        viewController: rootViewController,
        onEvent: { [weak self] eventType, data in
          self?.sendRewardAdEvent(adKey: adKey, eventType: eventType, data: data)
        }
      )
      
      // 인스턴스를 맵에 저장
      rewardAdMap[mapKey] = adInstance
      
      // 광고 로드 후 표시
      adInstance?.load { [weak self] success, error in
        guard let self = self else { return }
        if success {
          // 로드 성공 후 표시
          adInstance?.show(viewController: rootViewController) { showSuccess, showError in
            result(showSuccess)
          }
        } else {
          result(false)
        }
      }
      return
    }
    
    // 인스턴스가 있으면 바로 표시
    adInstance?.show(viewController: rootViewController) { success, error in
      result(success)
    }
  }
  
  /// 리워드 광고 인스턴스 해제
  private func disposeRewardAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "Invalid arguments for disposeRewardAd",
        details: nil
      ))
      return
    }
    
    guard let adType = args["adType"] as? String else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "adType is required",
        details: nil
      ))
      return
    }
    
    guard let adKey = args["adKey"] as? String else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "adKey is required",
        details: nil
      ))
      return
    }
    
    let mapKey = getRewardAdMapKey(adType: adType, adKey: adKey)
    rewardAdMap[mapKey]?.destroy()
    rewardAdMap.removeValue(forKey: mapKey)
    
    result(nil)
  }
}

// MARK: - FlutterStreamHandler
extension FlutterDaroSdkPlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    // 모든 리워드 광고 인스턴스 해제
    rewardAdMap.values.forEach { $0.destroy() }
    rewardAdMap.removeAll()
    return nil
  }
}

/// 리워드 광고 인스턴스 클래스 (인터스티셜, 리워드 비디오, 팝업)
class RewardAdInstance {
  private let adType: String
  private let adKey: String
  private let placement: String?
  private weak var viewController: UIViewController?
  private let onEvent: (String, [String: Any?]) -> Void
  
  // TODO: 실제 DARO SDK 타입으로 교체 필요
  // private var loader: Any?
  // private var ad: Any?
  
  init(adType: String, adKey: String, placement: String?, viewController: UIViewController?, onEvent: @escaping (String, [String: Any?]) -> Void) {
    self.adType = adType
    self.adKey = adKey
    self.placement = placement
    self.viewController = viewController
    self.onEvent = onEvent
  }
  
  /// 광고 로드
  func load(completion: @escaping (Bool, String?) -> Void) {
    // TODO: 실제 DARO SDK 코드로 교체
    // switch adType {
    // case "interstitial":
    //   let adUnit = DaroInterstitialAdUnit(
    //     key: adKey,
    //     placement: placement ?? ""
    //   )
    //   loader = DaroInterstitialAdLoader(
    //     context: viewController,
    //     adUnit: adUnit
    //   )
    //   // ... 리스너 설정 및 로드
    // case "rewardedVideo":
    //   let adUnit = DaroRewardedVideoAdUnit(
    //     key: adKey,
    //     placement: placement ?? ""
    //   )
    //   loader = DaroRewardedVideoAdLoader(
    //     context: viewController,
    //     adUnit: adUnit
    //   )
    //   // ... 리스너 설정 및 로드
    // case "popup":
    //   let adUnit = DaroPopupAdUnit(
    //     key: adKey,
    //     placement: placement ?? ""
    //   )
    //   loader = DaroPopupAdLoader(
    //     context: viewController,
    //     adUnit: adUnit
    //   )
    //   // ... 리스너 설정 및 로드
    // default:
    //   completion(false, "Unknown ad type")
    //   return
    // }
    
    // 임시 구현: 로드 성공으로 처리
    completion(true, nil)
  }
  
  /// 광고 표시
  func show(viewController: UIViewController, completion: @escaping (Bool, String?) -> Void) {
    // TODO: 실제 DARO SDK 코드로 교체
    // switch adType {
    // case "interstitial":
    //   guard let currentAd = ad as? DaroInterstitialAd else {
    //     completion(false, "Ad not loaded")
    //     return
    //   }
    //   currentAd.show(viewController: viewController)
    // case "rewardedVideo":
    //   guard let currentAd = ad as? DaroRewardedVideoAd else {
    //     completion(false, "Ad not loaded")
    //     return
    //   }
    //   currentAd.show(viewController: viewController)
    // case "popup":
    //   guard let currentAd = ad as? DaroPopupAd else {
    //     completion(false, "Ad not loaded")
    //     return
    //   }
    //   currentAd.show(viewController: viewController)
    // default:
    //   completion(false, "Unknown ad type")
    //   return
    // }
    
    // 임시 구현: 표시 성공으로 처리
    completion(true, nil)
  }
  
  /// 광고 인스턴스 해제
  func destroy() {
    // TODO: 실제 DARO SDK 코드로 교체
    // switch adType {
    // case "interstitial":
    //   (ad as? DaroInterstitialAd)?.destroy()
    // case "rewardedVideo":
    //   (ad as? DaroRewardedVideoAd)?.destroy()
    // case "popup":
    //   (ad as? DaroPopupAd)?.destroy()
    // default:
    //   break
    // }
    // ad = nil
    // loader = nil
  }
}
