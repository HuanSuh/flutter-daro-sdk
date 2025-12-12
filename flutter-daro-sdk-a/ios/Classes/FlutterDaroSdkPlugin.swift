import Flutter
import UIKit
import Daro

public class FlutterDaroSdkPlugin: NSObject, FlutterPlugin {
  /// MethodChannel for method calls from Flutter
  private var methodChannel: FlutterMethodChannel?
  
  /// EventChannel for sending events to Flutter
  private var eventChannel: FlutterEventChannel?
  private var eventSink: FlutterEventSink?
  
  /// 리워드 광고 인스턴스 맵 (타입과 adUnit를 조합한 키 사용: "type:adUnit")
  private var rewardAdMap: [String: FlutterDaroRewardAd] = [:]

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
    FlutterDaroBannerFactory.register(with: registrar)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "initialize":
      initialize(call: call, result: result)
    case "setOptions":
      setOptions(call: call, result: result)
    case "loadRewardAd":
      loadRewardAd(call: call, result: result)
    case "showRewardAd":
      showRewardAd(call: call, result: result)
    case "disposeRewardAd":
      disposeRewardAd(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// SDK 초기화
  private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "Invalid arguments for initialize",
        details: nil
      ))
      return
    }
    
    // appCategory = args["appCategory"] as? String
    // 문서 참고: https://guide.daro.so/ko/sdk-integration/ios_new/get-started#sdk-%EC%B4%88%EA%B8%B0%ED%99%94%ED%95%98%EA%B8%B0    
    DaroAds.shared.initialized { error in
      if let error {
        result(FlutterError(
          code: "INITIALIZE_FAILED",
          message: "Daro SDK initilized error : \(error)",
          details: nil
        ))
      } else {
        let options = args["options"] as? [String: Any]
        if let options {
          self._setOptions(
            userId: options["userId"] as? String, 
            logLevel: options["logLevel"] as? String, 
            appMute: options["appMute"] as? Bool
          )
        }
        result(true)
      }
    }
  }

  /// SDK 옵션 설정
  private func setOptions(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "Invalid arguments for setOptions",
        details: nil
      ))
      return
    }
    
    self._setOptions(
      userId: args["userId"] as? String, 
      logLevel: args["logLevel"] as? String, 
      appMute: args["appMute"] as? Bool
    )

    result(true)
  }

  private func _setOptions(userId: String?, logLevel: String?, appMute: Bool?) {
    if let userId {
      DaroAds.shared.userId = userId
    }
    if let logLevel {
      switch logLevel {
        case "off":
          DaroAds.shared.logLevel = .off
        case "error":
          DaroAds.shared.logLevel = .error
        case "debug":
          DaroAds.shared.logLevel = .debug
        default:
          print("Invalid logLevel: \(logLevel)")
      }
    }
    if let appMute {
      DaroAds.shared.setAppMuted(appMute)
    }
  }
  
  /// 리워드 광고 이벤트를 Flutter로 전송
  private func sendRewardAdEvent(adUnit: String, eventType: String, data: [String: Any?] = [:]) {
    let event: [String: Any] = [
      "eventName": eventType,
      "adUnit": adUnit,
      "data": data
    ]
    eventSink?(event)
  }

  /// 리워드 광고 인스턴스 생성
  private func _createRewardAdInstance(
    adType: FlutterDaroRewardAdType, 
    adUnit: String, 
    placement: String?, 
    options: [String: Any]? = nil
  ) -> FlutterDaroRewardAd {
    if let adInstance = rewardAdMap[adUnit] {
      return adInstance
    }
    let adInstance = FlutterDaroRewardAdFactory.create(
      adType: adType,
      adUnit: adUnit,
      placement: placement,
      options: options,
      listener: FlutterDaroRewardAdLoadListener(
        onAdLoadSuccess: { adItem, ad, adInfo in
          self.sendRewardAdEvent(adUnit: adUnit, eventType: "onAdLoadSuccess", data: [
            "ad": String(describing: ad as Any),
            "adInfo": String(describing: adInfo as Any)
          ])
        },
        onAdLoadFail: { error in
          self.sendRewardAdEvent(adUnit: adUnit, eventType: "onAdLoadFail", data: [
            "error": error.localizedDescription
          ])
          self._dispose(adUnit: adUnit)
        },
        onAdImpression: { adInfo in
          self.sendRewardAdEvent(adUnit: adUnit, eventType: "onAdImpression")
        },
        onAdClicked: { adInfo in
          self.sendRewardAdEvent(adUnit: adUnit, eventType: "onAdClicked")
        }
      )
    )
    self.rewardAdMap[adUnit] = adInstance
    return adInstance
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
    
    guard let adUnit = args["adUnit"] as? String else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "adUnit is required",
        details: nil
      ))
      return
    }
    
    let placement = args["placement"] as? String
    let options = args["options"] as? [String: Any]
    
    // String을 enum으로 변환
    guard let rewardAdType = FlutterDaroRewardAdType(rawValue: adType) else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "Invalid adType: \(adType)",
        details: nil
      ))
      return
    }
    
    // 새로운 리워드 광고 인스턴스 생성
    let adInstance: FlutterDaroRewardAd = _createRewardAdInstance(adType: rewardAdType, adUnit: adUnit, placement: placement, options: options)
    
    // 광고 로드
    adInstance.loadAd() { success, error in
      if success {
        result(nil)
      } else {
        result(FlutterError(
          code: "LOAD_ERROR",
          message: error?.localizedDescription ?? "Failed to load ad",
          details: nil
        ))
      }
    }
  }
  
  /// 리워드 광고 인스턴스 표시
  private func showRewardAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(false)
      return
    }
    
    guard let adType = args["adType"] as? String else {
      result(false)
      return
    }
    
    guard let adUnit = args["adUnit"] as? String else {
      result(false)
      return
    }
    
    let placement = args["placement"] as? String
    
    // String을 enum으로 변환
    guard let rewardAdType = FlutterDaroRewardAdType(rawValue: adType) else {
      result(false)
      return
    }
    
    var adInstance = rewardAdMap[adUnit]
    
    // 인스턴스가 없으면 자동으로 생성하고 로드
    if adInstance == nil {
      // 새로운 리워드 광고 인스턴스 생성
      let options = args["options"] as? [String: Any]
      adInstance = _createRewardAdInstance(adType: rewardAdType, adUnit: adUnit, placement: placement, options: options)
    }
    
    // 인스턴스가 있으면 바로 표시
    adInstance?.showAd(
      listener: FlutterDaroRewardAdListener(
        onShown: { adInfo in
          self.sendRewardAdEvent(adUnit: adUnit, eventType: "onShown")
        },
        onRewarded: { adInfo, reward in
          self.sendRewardAdEvent(adUnit: adUnit, eventType: "onRewarded", data: [
            "reward": [
              "amount": reward?.amount ?? 0,
              "type": reward?.rewardType ?? ""
            ]
          ])
        },
        onDismiss: { adInfo in
          self.sendRewardAdEvent(adUnit: adUnit, eventType: "onDismiss")
          self._dispose(adUnit: adUnit)
        },
        onFailedToShow: { adInfo, error in
          self.sendRewardAdEvent(
            adUnit: adUnit, 
            eventType: "onFailedToShow", 
            data: ["error": error.localizedDescription]
          )
          self._dispose(adUnit: adUnit)
        }
    )) { success, error in
      result(success ? true : FlutterError(
        code: "SHOW_ERROR",
        message: "Failed to show ad: \(error)",
        details: nil
      ))
    }
  }
  
  /// 리워드 광고 인스턴스 해제
  private func _dispose(adUnit: String) {
    rewardAdMap[adUnit]?.destroy()
    rewardAdMap.removeValue(forKey: adUnit)
  }
  private func disposeRewardAd(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "Invalid arguments for disposeRewardAd",
        details: nil
      ))
      return
    }
    
    guard let adUnit = args["adUnit"] as? String else {
      result(FlutterError(
        code: "INVALID_ARGUMENT",
        message: "adUnit is required",
        details: nil
      ))
      return
    }
    
    self._dispose(adUnit: adUnit)
    
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
