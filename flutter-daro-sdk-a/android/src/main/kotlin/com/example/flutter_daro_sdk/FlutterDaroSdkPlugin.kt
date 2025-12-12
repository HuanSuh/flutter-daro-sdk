package com.example.flutter_daro_sdk

import android.app.Activity
import droom.daro.Daro
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroRewardedAd
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterDaroSdkPlugin */
class FlutterDaroSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  private lateinit var methodChannel : MethodChannel

  /// The EventChannel for sending events to Flutter
  private lateinit var eventChannel : EventChannel
  private var eventSink: EventChannel.EventSink? = null

  /// Current activity reference
  private var activity: Activity? = null

  /// 앱 카테고리 타입
  private var appCategory: String? = null

  /// 리워드 광고 인스턴스 맵
  private val rewardAdMap = mutableMapOf<String, FlutterDaroRewardAd>()

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
      "loadRewardAd" -> {
        loadRewardAd(call, result)
      }
      "showRewardAd" -> {
        showRewardAd(call, result)
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
      val args = call.arguments as? Map<*, *> ?: return result.error(
        "INVALID_ARGUMENT",
        "Invalid arguments for initialize",
        null
      )

      appCategory = args["appCategory"] as? String
      val currentActivity = activity ?: return result.success(false)

      // 문서 참고: https://guide.daro.so/ko/sdk-integration/android/get-started#sdk-%EC%B4%88%EA%B8%B0%ED%99%94%ED%95%98%EA%B8%B0
      val configBuilder = Daro.SDKConfig.Builder()
      val options = args["options"] as? Map<*, *>
      if (options != null) {
        when (options["logLevel"] as? String) {
          "off" -> configBuilder.setDebugMode(false)
          "error" -> configBuilder.setDebugMode(true)
          "debug" -> configBuilder.setDebugMode(true)
          else -> {}
        }

        when(options["appMute"] as? Boolean) {
          true -> configBuilder.setAppMute(true)
          false -> configBuilder.setAppMute(false)
          else -> {}
        }
      }

       Daro.init(
         application = currentActivity.application,
         sdkConfig = configBuilder.build()
       )

      // 초기화 성공
      result.success(true)
    } catch (e: Exception) {
      result.error("INIT_ERROR", e.message, null)
    }
  }

  private fun createAdInstance(
    context: Activity,
    adType: FlutterDaroRewardAdType,
    adUnit: String,
    placement: String?,
    options: Map<*,*>?
  ): FlutterDaroRewardAd {
    rewardAdMap[adUnit]?.let {
      return it
    }
    val result = FlutterDaroRewardAdFactory.create(
      context = context,
      adType = adType,
      adUnit = adUnit,
      placement = placement,
      options = options,
      loadListener = object: FlutterDaroRewardAdLoadListener {
        override fun onAdLoadSuccess(ad: FlutterDaroRewardAd, adInstance: Any?, adInfo: DaroAdInfo?) {
          sendRewardAdEvent(
            adUnit,
            "onAdLoadSuccess",
            mapOf(
              "latency" to (adInfo)?.latency,
              "ad" to adInstance?.toString()
            )
          )
        }
        override fun onAdLoadFail(error: Any) {
          sendRewardAdEvent(
            adUnit,
            "onAdLoadFail",
            mapOf("error" to error.toString())
          )
        }
      }
    )
    rewardAdMap[adUnit] = result
    return result
  }

  /// 리워드 광고 로드
  private fun loadRewardAd(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<*, *> ?: return result.error(
        "INVALID_ARGUMENT",
        "Invalid arguments for loadRewardAd",
        null
      )

      val adType = FlutterDaroRewardAdType.fromString(args["adType"] as? String?) ?: return result.error(
        "INVALID_ARGUMENT",
        "adType is required",
        null
      )

      val adUnit = args["adUnit"] as? String ?: return result.error(
        "INVALID_ARGUMENT",
        "adKey is required",
        null
      )

      val placement = args["placement"] as? String

      val currentActivity = activity
        ?: return result.error(
          "NO_ACTIVITY",
          "No activity available to load ad",
          null
        )

      val options = args["options"] as? Map<*, *>


      // 기존 인스턴스가 있으면 해제
//      rewardAdMap[adUnit]?.destroy()

      // 새로운 리워드 광고 인스턴스 생성
      val adInstance = createAdInstance(currentActivity, adType, adUnit, placement, options)

      // 광고 로드
      adInstance.loadAd(
        autoShow = false,
        listener = null,
        result = { success, data ->
          if (success) {
            result.success(true)
          } else {
            result.error("LOAD_ERROR", data?.toString() ?: "Unknown error", data)
          }
        }
      )
    } catch (e: Exception) {
      result.error("LOAD_ERROR", e.message, null)
    }
  }

  /// 리워드 광고 표시
  private fun showRewardAd(call: MethodCall, result: Result) {
    try {
      val currentActivity = activity
        ?: return result.error(
          "NO_ACTIVITY",
          "No activity available to show ad",
          null
        )

      val args = call.arguments as? Map<*, *> ?: return result.error(
        "INVALID_ARGUMENT",
        "Invalid arguments for showRewardAd",
        null
      )

      val adType = FlutterDaroRewardAdType.fromString(args["adType"] as? String?) ?: return result.error(
        "INVALID_ARGUMENT",
        "adType is required",
        null
      )
      val adUnit = args["adUnit"] as? String
        ?: return result.error(
          "INVALID_ARGUMENT",
          "adKey is required",
          null
        )
      val placement = args["placement"] as? String
      val options = args["options"] as? Map<*, *>

      var adInstance = rewardAdMap[adUnit]
      if (adInstance == null) {
        adInstance = createAdInstance(currentActivity, adType, adUnit, placement, options)
      }

      adInstance.showAd(
        listener = object : FlutterDaroRewardAdListener {
          override fun onShown(adInfo: DaroAdInfo) {
            sendRewardAdEvent(adUnit, "onShown", emptyMap())
          }
          override fun onRewarded(adInfo: DaroAdInfo, rewardItem: DaroRewardedAd.DaroRewardedItem) {
            sendRewardAdEvent(
              adUnit,
              "onRewarded",
              mapOf(
                "type" to rewardItem.type,
                "amount" to rewardItem.amount
              )
            )
          }
          override fun onDismiss(adInfo: DaroAdInfo) {
            sendRewardAdEvent(adUnit, "onDismiss", emptyMap())
            dispose(adUnit)
          }
          override fun onFailedToShow(adInfo: DaroAdInfo, error: Any) {
            sendRewardAdEvent(
              adUnit,
              "onFailedToShow",
              mapOf("error" to error.toString())
            )
            dispose(adUnit)
          }
          override fun onAdImpression(adInfo: DaroAdInfo) {
            sendRewardAdEvent(adUnit, "onAdImpression", emptyMap())
          }
          override fun onAdClicked(adInfo: DaroAdInfo) {
            sendRewardAdEvent(adUnit, "onAdClicked", emptyMap())
          }
        },
        result = {success, data ->
          if (success) {
            result.success(true)
          } else {
            result.error("LOAD_ERROR", data?.toString() ?: "Unknown error", data)
          }
        }
      )
    } catch (e: Exception) {
      val adResult = mapOf(
        "adId" to "",
        "success" to false,
        "errorMessage" to (e.message ?: "Unknown error")
      )
      result.success(adResult)
    }
  }

  /// 리워드 광고 이벤트를 Flutter로 전송
  private fun sendRewardAdEvent(adUnit: String, eventType: String, data: Map<String, Any?>) {
    val event = mapOf(
      "eventName" to eventType,
      "adUnit" to adUnit,
      "data" to data,
    )
    eventSink?.success(event)
  }

  private fun dispose(adUnit: String) {
    rewardAdMap.remove(adUnit)?.destroy()
  }
  /// 리워드 광고 인스턴스 해제
  private fun disposeRewardAd(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<*, *> ?: return result.error(
        "INVALID_ARGUMENT",
        "Invalid arguments for disposeRewardAd",
        null
      )

      val adUnit = args["adUnit"] as? String ?: return result.error(
        "INVALID_ARGUMENT",
        "adUnit is required",
        null
      )

      dispose(adUnit)

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
