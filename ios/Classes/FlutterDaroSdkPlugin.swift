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
    case "showAd":
      showAd(result: result)
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

  /// 광고 표시
  private func showAd(result: @escaping FlutterResult) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
      let adResult: [String: Any] = [
        "success": false,
        "errorMessage": "No root view controller available"
      ]
      result(adResult)
      return
    }
    
    // TODO: 실제 DARO SDK 광고 표시 코드로 교체
    // 예시:
    // daroSdk?.showAd(
    //   viewController: rootViewController,
    //   onAdShown: {
    //     // 광고 표시 성공
    //   },
    //   onAdClosed: {
    //     // 광고 닫힘
    //     self.sendEvent(eventName: "adClosed", data: ["success": true])
    //     let adResult: [String: Any] = [
    //       "success": true
    //     ]
    //     result(adResult)
    //   },
    //   onRewardEarned: { amount in
    //     // 리워드 적립
    //     self.sendEvent(eventName: "rewardEarned", data: ["amount": amount])
    //     let adResult: [String: Any] = [
    //       "success": true,
    //       "rewardAmount": amount
    //     ]
    //     result(adResult)
    //   },
    //   onError: { error in
    //     let adResult: [String: Any] = [
    //       "success": false,
    //       "errorMessage": error
    //     ]
    //     result(adResult)
    //   }
    // )
    
    // 임시 구현: 광고 표시 성공으로 처리
    let adResult: [String: Any] = [
      "success": true,
      "rewardAmount": appCategory == "reward" ? 100 : nil
    ]
    result(adResult)
  }

  /// 이벤트를 Flutter로 전송
  private func sendEvent(eventName: String, data: [String: Any?]) {
    let event: [String: Any] = [
      "event": eventName,
      "data": data
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
