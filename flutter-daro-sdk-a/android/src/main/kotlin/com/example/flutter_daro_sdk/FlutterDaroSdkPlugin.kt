package com.example.flutter_daro_sdk

import android.app.Activity
import droom.daro.Daro
import droom.daro.core.model.DaroAdDisplayFailError
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
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
  private lateinit var bannerAdFactory: FlutterDaroBannerAdFactory

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

    bannerAdFactory = FlutterDaroBannerAdFactory.registerWith(flutterPluginBinding)
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
        "1001",
        "INVALID_ARGUMENT",
        "Invalid arguments for initialize",
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
      result.error("1002", "INIT_ERROR", e.message)
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
        override fun onAdLoadFail(error: DaroAdLoadError) {
          sendRewardAdEvent(
            adUnit,
            "onAdLoadFail",
            mapOf(
              "code" to error.code,
              "message" to error.message
            )
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
        "1001",
        "INVALID_ARGUMENT",
        "Invalid arguments for loadRewardAd",
      )

      val adType = FlutterDaroRewardAdType.fromString(args["adType"] as? String?) ?: return result.error(
        "1001",
        "INVALID_ARGUMENT",
        "adType is required ${args["adType"]}",
      )

      val adUnit = args["adUnit"] as? String ?: return result.error(
        "1001",
        "INVALID_ARGUMENT",
        "adUnit is required",
      )

      val placement = args["placement"] as? String

      val currentActivity = activity
        ?: return result.error(
          "1013",
          "NO_ACTIVITY",
          "No activity available to load ad",
        )

      val options = args["options"] as? Map<*, *>


      // 새로운 리워드 광고 인스턴스 생성
      val adInstance = createAdInstance(currentActivity, adType, adUnit, placement, options)

      // 광고 로드
      adInstance.loadAd(
        autoShow = false,
        listener = null,
        result = { success, data ->
          result.success(success)
        }
      )
    } catch (e: Exception) {
      result.success(false)
    }
  }

  /// 리워드 광고 표시
  private fun showRewardAd(call: MethodCall, result: Result) {
    try {
      val currentActivity = activity
        ?: return result.error(
          "1013",
          "NO_ACTIVITY",
          "No activity available to show ad",
        )

      val args = call.arguments as? Map<*, *> ?: return result.error(
        "1001",
        "INVALID_ARGUMENT",
        "Invalid arguments for showRewardAd",
      )

      val adType = FlutterDaroRewardAdType.fromString(args["adType"] as? String?) ?: return result.error(
        "1001",
        "INVALID_ARGUMENT",
        "adType is required : ${args["adType"]}",
      )
      val adUnit = args["adUnit"] as? String
        ?: return result.error(
          "1001",
          "INVALID_ARGUMENT",
          "adUnit is required",
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
          override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
            sendRewardAdEvent(
              adUnit,
              "onFailedToShow",
              mapOf(
                "code" to -1,
                "message" to error.toString(),
              ),
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
          result.success(success)
        }
      )
    } catch (e: Exception) {
      result.success(false)
    }
  }

  /// 리워드 광고 이벤트를 Flutter로 전송
  private fun sendRewardAdEvent(adUnit: String, eventType: String, data: Map<String, Any?>) {
    eventSink?.success(mapOf(
      "eventName" to eventType,
      "adUnit" to adUnit,
      "data" to data,
    ))
  }

  private fun dispose(adUnit: String) {
    rewardAdMap.remove(adUnit)?.destroy()
  }
  /// 리워드 광고 인스턴스 해제
  private fun disposeRewardAd(call: MethodCall, result: Result) {
    try {
      val args = call.arguments as? Map<*, *> ?: return result.error(
        "1001",
        "INVALID_ARGUMENT",
        "Invalid arguments for disposeRewardAd",
      )

      val adUnit = args["adUnit"] as? String ?: return result.error(
        "1001",
        "INVALID_ARGUMENT",
        "adUnit is required",
      )

      dispose(adUnit)

      result.success(null)
    } catch (e: Exception) {
      result.error("1030", "DISPOSE_ERROR", e)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    bannerAdFactory.onDestroy()
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
