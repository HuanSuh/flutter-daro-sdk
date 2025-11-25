import Flutter
import UIKit

public class DaroCoreAPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Non-Reward 앱용 DARO SDK 의존성만 포함
    // 실제 SDK 초기화는 flutter_daro_sdk 플러그인에서 처리
  }
}

