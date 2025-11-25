package com.example.daro_core_a

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** DaroCoreAPlugin - Non-Reward 앱용 DARO SDK Core 플러그인 */
class DaroCoreAPlugin: FlutterPlugin {
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // Non-Reward 앱용 DARO SDK 의존성만 포함
    // 실제 SDK 초기화는 flutter_daro_sdk 플러그인에서 처리
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    // 정리 작업
  }
}

