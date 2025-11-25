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

  /// 리워드 광고 인스턴스 맵 (타입과 adKey를 조합한 키 사용: "type:adKey")
  private val rewardAdMap = mutableMapOf<String, RewardAdInstance>()

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
        // 기존 showRewardAd는 다른 용도로 사용되므로 별도 처리
        showRewardAd(call, result)
      }
      "loadRewardAd" -> {
        loadRewardAd(call, result)
      }
      "showRewardAdInstance" -> {
        showRewardAdInstance(call, result)
      }
      "disposeRewardAd" -> {
        disposeRewardAd(call, result)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  /// SDK 초기화
  private fun initialize(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<*, *> ?: return result.success(false)
      
      appCategory = args["appCategory"] as? String
      val appKey = args["appKey"] as? String
      val userId = args["userId"] as? String
      
      val currentActivity = activity
      if (currentActivity == null) {
        return result.success(false)
      }
      
      // TODO: 실제 DARO SDK 초기화 코드로 교체
      // 문서 참고: https://guide.daro.so/ko/sdk-integration/android/get-started#sdk-%EC%B4%88%EA%B8%B0%ED%99%94%ED%95%98%EA%B8%B0
      // 
      // import droom.daro.Daro
      // 
      // val sdkConfig = Daro.SDKConfig.Builder()
      //   .setDebugMode(false) // Daro 로그 노출 여부, default: false
      //   .setAppMute(false) // 앱 음소거 설정, default: false
      //   .build()
      // 
      // Daro.init(
      //   application = currentActivity.application,
      //   sdkConfig = sdkConfig
      // )
      // 
      // // 초기화 성공
      // result.success(true)
      
      // 임시 구현: 초기화 성공으로 처리
      result.success(true)
    } catch (e: Exception) {
      // 초기화 실패 시 false 반환
      result.success(false)
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

  /// 리워드 광고 이벤트를 Flutter로 전송
  private fun sendRewardAdEvent(adKey: String, eventType: String, data: Map<String, Any?>) {
    val event = mapOf(
      "adKey" to adKey,
      "event" to mapOf(
        "type" to eventType,
        "data" to data
      )
    )
    eventSink?.success(event)
  }

  /// 타입과 키를 조합한 맵 키 생성
  private fun getRewardAdMapKey(adType: String, adKey: String): String {
    return "$adType:$adKey"
  }

  /// 리워드 광고 로드
  private fun loadRewardAd(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<*, *> ?: return result.error(
        "INVALID_ARGUMENT",
        "Invalid arguments for loadRewardAd",
        null
      )

      val adType = args["adType"] as? String ?: return result.error(
        "INVALID_ARGUMENT",
        "adType is required",
        null
      )

      val adKey = args["adKey"] as? String ?: return result.error(
        "INVALID_ARGUMENT",
        "adKey is required",
        null
      )

      val placement = args["placement"] as? String

      val currentActivity = activity
      if (currentActivity == null) {
        return result.error(
          "NO_ACTIVITY",
          "No activity available to load ad",
          null
        )
      }

      val mapKey = getRewardAdMapKey(adType, adKey)

      // 기존 인스턴스가 있으면 해제
      rewardAdMap[mapKey]?.destroy()

      // 새로운 리워드 광고 인스턴스 생성
      val adInstance = RewardAdInstance(
        adType = adType,
        adKey = adKey,
        placement = placement,
        activity = currentActivity,
        onEvent = { eventType, data ->
          sendRewardAdEvent(adKey, eventType, data)
        }
      )

      // 인스턴스를 맵에 저장
      rewardAdMap[mapKey] = adInstance

      // 광고 로드
      adInstance.load(object : RewardAdLoadCallback {
        override fun onSuccess() {
          result.success(null)
        }

        override fun onError(error: String) {
          result.error("LOAD_ERROR", error, null)
        }
      })
    } catch (e: Exception) {
      result.error("LOAD_ERROR", e.message, null)
    }
  }

  /// 리워드 광고 인스턴스 표시
  private fun showRewardAdInstance(call: MethodCall, result: Result) {
    try {
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

      val adKey = args["adKey"] as? String ?: return result.error(
        "INVALID_ARGUMENT",
        "adKey is required",
        null
      )

      val placement = args["placement"] as? String

      val currentActivity = activity
      if (currentActivity == null) {
        return result.success(false)
      }

      val mapKey = getRewardAdMapKey(adType, adKey)
      var adInstance = rewardAdMap[mapKey]
      
      // 인스턴스가 없으면 자동으로 생성하고 로드
      if (adInstance == null) {
        // 새로운 리워드 광고 인스턴스 생성
        adInstance = RewardAdInstance(
          adType = adType,
          adKey = adKey,
          placement = placement,
          activity = currentActivity,
          onEvent = { eventType, data ->
            sendRewardAdEvent(adKey, eventType, data)
          }
        )

        // 인스턴스를 맵에 저장
        rewardAdMap[mapKey] = adInstance

        // 광고 로드 후 표시
        adInstance.load(object : RewardAdLoadCallback {
          override fun onSuccess() {
            // 로드 성공 후 표시
            adInstance?.show(currentActivity, object : RewardAdShowCallback {
              override fun onSuccess() {
                result.success(true)
              }

              override fun onError(error: String) {
                result.success(false)
              }
            })
          }

          override fun onError(error: String) {
            result.success(false)
          }
        })
        return
      }

      // 인스턴스가 있으면 바로 표시
      adInstance.show(currentActivity, object : RewardAdShowCallback {
        override fun onSuccess() {
          result.success(true)
        }

        override fun onError(error: String) {
          result.success(false)
        }
      })
    } catch (e: Exception) {
      result.success(false)
    }
  }

  /// 리워드 광고 인스턴스 해제
  private fun disposeRewardAd(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<*, *> ?: return result.error(
        "INVALID_ARGUMENT",
        "Invalid arguments for disposeRewardAd",
        null
      )

      val adType = args["adType"] as? String ?: return result.error(
        "INVALID_ARGUMENT",
        "adType is required",
        null
      )

      val adKey = args["adKey"] as? String ?: return result.error(
        "INVALID_ARGUMENT",
        "adKey is required",
        null
      )

      val mapKey = getRewardAdMapKey(adType, adKey)
      val adInstance = rewardAdMap.remove(mapKey)
      adInstance?.destroy()

      result.success(null)
    } catch (e: Exception) {
      result.error("DISPOSE_ERROR", e.message, null)
    }
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
    // 모든 리워드 광고 인스턴스 해제
    rewardAdMap.values.forEach { it.destroy() }
    rewardAdMap.clear()
  }
}

/// 리워드 광고 인스턴스 클래스 (인터스티셜, 리워드 비디오, 팝업)
class RewardAdInstance(
  private val adType: String,
  private val adKey: String,
  private val placement: String?,
  private val activity: Activity,
  private val onEvent: (String, Map<String, Any?>) -> Unit
) {
  // TODO: 실제 DARO SDK 타입으로 교체 필요
  // private var loader: Any? = null
  // private var ad: Any? = null

  /// 광고 로드
  fun load(callback: RewardAdLoadCallback) {
    // TODO: 실제 DARO SDK 코드로 교체
    // when (adType) {
    //   "interstitial" -> {
    //     val adUnit = DaroInterstitialAdUnit(
    //       key = adKey,
    //       placement = placement ?: ""
    //     )
    //     loader = DaroInterstitialAdLoader(
    //       context = activity,
    //       adUnit = adUnit
    //     )
    //     // ... 리스너 설정 및 로드
    //   }
    //   "rewardedVideo" -> {
    //     val adUnit = DaroRewardedVideoAdUnit(
    //       key = adKey,
    //       placement = placement ?: ""
    //     )
    //     loader = DaroRewardedVideoAdLoader(
    //       context = activity,
    //       adUnit = adUnit
    //     )
    //     // ... 리스너 설정 및 로드
    //   }
    //   "popup" -> {
    //     val adUnit = DaroPopupAdUnit(
    //       key = adKey,
    //       placement = placement ?: ""
    //     )
    //     loader = DaroPopupAdLoader(
    //       context = activity,
    //       adUnit = adUnit
    //     )
    //     // ... 리스너 설정 및 로드
    //   }
    // }

    // 임시 구현: 로드 성공으로 처리
    callback.onSuccess()
  }

  /// 광고 표시
  fun show(activity: Activity, callback: RewardAdShowCallback) {
    // TODO: 실제 DARO SDK 코드로 교체
    // when (adType) {
    //   "interstitial" -> {
    //     val currentAd = ad as? DaroInterstitialAd
    //     currentAd?.show(activity = activity)
    //   }
    //   "rewardedVideo" -> {
    //     val currentAd = ad as? DaroRewardedVideoAd
    //     currentAd?.show(activity = activity)
    //   }
    //   "popup" -> {
    //     val currentAd = ad as? DaroPopupAd
    //     currentAd?.show(activity = activity)
    //   }
    // }

    // 임시 구현: 표시 성공으로 처리
    callback.onSuccess()
  }

  /// 광고 인스턴스 해제
  fun destroy() {
    // TODO: 실제 DARO SDK 코드로 교체
    // when (adType) {
    //   "interstitial" -> {
    //     (ad as? DaroInterstitialAd)?.destroy()
    //   }
    //   "rewardedVideo" -> {
    //     (ad as? DaroRewardedVideoAd)?.destroy()
    //   }
    //   "popup" -> {
    //     (ad as? DaroPopupAd)?.destroy()
    //   }
    // }
    // ad = null
    // loader = null
  }
}

/// 리워드 광고 로드 콜백
interface RewardAdLoadCallback {
  fun onSuccess()
  fun onError(error: String)
}

/// 리워드 광고 표시 콜백
interface RewardAdShowCallback {
  fun onSuccess()
  fun onError(error: String)
}
