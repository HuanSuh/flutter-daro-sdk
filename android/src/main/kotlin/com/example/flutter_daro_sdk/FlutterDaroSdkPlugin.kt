package com.example.flutter_daro_sdk

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.UUID

/** FlutterDaroSdkPlugin */
class FlutterDaroSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  private lateinit var methodChannel : MethodChannel
  
  /// The EventChannel for sending events to Flutter
  private lateinit var eventChannel : EventChannel
  private var eventSink: EventChannel.EventSink? = null
  
  /// Current activity reference
  private var activity: Activity? = null
  
  /// DARO SDK 인스턴스 (실제 DARO SDK로 교체 필요)
  // private var daroSdk: DaroSdk? = null
  
  /// 앱 카테고리 타입
  private var appCategory: String? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.daro.flutter_daro_sdk/channel")
    methodChannel.setMethodCallHandler(this)
    
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.daro.flutter_daro_sdk/events")
    eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
      }

      override fun onCancel(arguments: Any?) {
        eventSink = null
      }
    })
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "initialize" -> {
        initialize(call, result)
      }
      "showRewardAd" -> {
        showRewardAd(call, result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  /// SDK 초기화
  private fun initialize(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<*, *> ?: return result.error(
        "INVALID_ARGUMENT",
        "Invalid arguments for initialize",
        null
      )
      
      appCategory = args["appCategory"] as? String
      val appKey = args["appKey"] as? String
      val userId = args["userId"] as? String
      
      // TODO: 실제 DARO SDK 초기화 코드로 교체
      // 예시:
      // val config = DaroSdkConfig.Builder()
      //   .setAppCategory(appCategory)
      //   .setAppKey(appKey)
      //   .setUserId(userId)
      //   .build()
      // daroSdk = DaroSdk.getInstance()
      // daroSdk?.initialize(activity, config, object : DaroSdkCallback {
      //   override fun onSuccess() {
      //     result.success(null)
      //   }
      //   override fun onError(error: String) {
      //     result.error("INIT_ERROR", error, null)
      //   }
      // })
      
      // 임시 구현: 초기화 성공으로 처리
      result.success(null)
    } catch (e: Exception) {
      result.error("INIT_ERROR", e.message, null)
    }
  }

  /// 리워드 광고 표시
  private fun showRewardAd(call: MethodCall, result: Result) {
    try {
      val currentActivity = activity
      if (currentActivity == null) {
        return result.error(
          "NO_ACTIVITY",
          "No activity available to show ad",
          null
        )
      }
      
      val args = call.arguments as? Map<*, *> ?: return result.error(
        "INVALID_ARGUMENT",
        "Invalid arguments for showRewardAd",
        null
      )
      
      val adType = args["adType"] as? String ?: return result.error(
        "INVALID_ARGUMENT",
        "adType is required",
        null
      )
      val adKey = args["adKey"] as? String
      val extraParams = args["extraParams"] as? Map<*, *>
      
      // 고유한 광고 ID 생성
      val adId = UUID.randomUUID().toString()
      
      // TODO: 실제 DARO SDK 광고 표시 코드로 교체
      // 예시:
      // val adConfig = DaroAdConfig.Builder()
      //   .setAdType(adType) // "interstitial", "rewardedVideo", "popup"
      //   .setAdKey(adKey)
      //   .setExtraParams(extraParams)
      //   .build()
      // 
      // daroSdk?.showRewardAd(currentActivity, adConfig, object : DaroAdCallback {
      //   override fun onAdShown() {
      //     // 광고 표시 성공
      //     sendAdEvent(adId, "adShown", mapOf("success" to true))
      //   }
      //   override fun onAdClosed() {
      //     // 광고 닫힘
      //     sendAdEvent(adId, "adClosed", mapOf("success" to true))
      //   }
      //   override fun onRewardEarned(amount: Int) {
      //     // 리워드 적립
      //     sendAdEvent(adId, "rewardEarned", mapOf("amount" to amount))
      //   }
      //   override fun onError(error: String) {
      //     sendAdEvent(adId, "error", mapOf("errorMessage" to error))
      //   }
      // })
      
      // 임시 구현: 광고 표시 성공으로 처리
      val adResult = mapOf(
        "adId" to adId,
        "success" to true,
        "rewardAmount" to if (appCategory == "reward" && adType == "rewardedVideo") 100 else null
      )
      result.success(adResult)
      
      // 임시 이벤트 전송 (실제로는 SDK 콜백에서 호출)
      sendAdEvent(adId, "adShown", mapOf("success" to true))
    } catch (e: Exception) {
      val adResult = mapOf(
        "adId" to "",
        "success" to false,
        "errorMessage" to (e.message ?: "Unknown error")
      )
      result.success(adResult)
    }
  }

  /// 광고 ID별 이벤트를 Flutter로 전송
  private fun sendAdEvent(adId: String, eventType: String, data: Map<String, Any?>) {
    val event = mapOf(
      "adId" to adId,
      "event" to mapOf(
        "type" to eventType,
        "data" to data
      )
    )
    eventSink?.success(event)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }
}
