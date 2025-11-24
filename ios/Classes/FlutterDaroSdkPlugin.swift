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
    
    appCategory = args["appCategory"] as? String
    let appKey = args["appKey"] as? String
    let userId = args["userId"] as? String
    
    // TODO: 실제 DARO SDK 초기화 코드로 교체
    // 예시:
    // let config = DaroSdkConfig(
    //   appCategory: appCategory,
    //   appKey: appKey,
    //   userId: userId
    // )
    // daroSdk = DaroSdk.shared
    // daroSdk?.initialize(config: config) { success, error in
    //   if success {
    //     result(nil)
    //   } else {
    //     result(FlutterError(
    //       code: "INIT_ERROR",
    //       message: error ?? "Unknown error",
    //       details: nil
    //     ))
    //   }
    // }
    
    // 임시 구현: 초기화 성공으로 처리
    result(nil)
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
}

// MARK: - FlutterStreamHandler
extension FlutterDaroSdkPlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
