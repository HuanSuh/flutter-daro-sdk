package com.example.flutter_daro_sdk

import android.app.Activity
import android.content.Context
import android.util.Log
import android.view.View
import droom.daro.core.adunit.DaroBannerAdUnit
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroBannerSize
import droom.daro.core.model.DaroViewAd
import droom.daro.view.DaroAdViewListener
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import droom.daro.view.DaroBannerAdView
import org.json.JSONObject

class FlutterDaroBannerAdFactory
private constructor(private val messenger: BinaryMessenger) :
    PlatformViewFactory(JSONMessageCodec.INSTANCE) {

    private lateinit var activity: Activity
    private lateinit var adView: FlutterDaroBannerAdView

    override fun create(context: Context?, id: Int, args: Any?): FlutterDaroBannerAdView {
        adView = FlutterDaroBannerAdView(context, messenger, id, args)
        return adView
    }

    fun onDestroy() {
        adView.dispose()
    }

    companion object {
        fun registerWith(flutterPluginBinding: FlutterPluginBinding): FlutterDaroBannerAdFactory {
            val plugin = FlutterDaroBannerAdFactory(flutterPluginBinding.binaryMessenger)
            flutterPluginBinding.platformViewRegistry.registerViewFactory(
                "flutter_daro_banner_view", plugin
            )
            return plugin
        }
    }
}

class FlutterDaroBannerAdView(
    private val context: Context?,
    messenger: BinaryMessenger,
    viewId: Int,
    arguments: Any?
) : PlatformView, EventChannel.StreamHandler, MethodCallHandler {
    private var adView: DaroBannerAdView? = null
    private var eventSink: EventSink? = null
//    private var methodChannel: MethodChannel? = null

    init {
        try {
//            methodChannel = with(
//                MethodChannel(
//                    messenger,
//                    "com.daro.flutter_daro_sdk/method_$viewId"
//                )
//            ) {
//                setMethodCallHandler(this@FlutterDaroBannerAdView)
//                return@with this
//            }

            /* open an event channel */
            EventChannel(
                messenger,
                "com.daro.flutter_daro_sdk/events_$viewId",
                JSONMethodCodec.INSTANCE
            ).setStreamHandler(this)

            loadAd(arguments as JSONObject)
        } catch (e: Exception) {
            callback("onAdFailedToLoad", null, e.message)
        }
    }

    private fun loadAd(args: JSONObject) {
        val adUnit = args["adUnit"] as? String
        if(adUnit == null) {
            callback("onAdFailedToLoad", null, "AdUnit is null")
            return
        }
        val adSize: DaroBannerSize = when((args["adSize"] as? String)?.lowercase()) {
            "banner" -> DaroBannerSize.Banner
            "mrec" -> DaroBannerSize.MREC
            else -> DaroBannerSize.Banner
        }

        val placement = args["placement"] as? String
        context?.let {
            adView = DaroBannerAdView(
                it, DaroBannerAdUnit(
                    key = adUnit,
                    placement = placement ?: "",
                    bannerSize = adSize
                )
            )
            adView?.apply {
                setListener(object : DaroAdViewListener {
                    override fun onAdLoadSuccess(ad: DaroViewAd, adInfo: DaroAdInfo) {
                        callback("onAdLoaded", adUnit)
                    }

                    override fun onAdLoadFail(err: DaroAdLoadError) {
                        val error = JSONObject()
                        error.put("code", err.code)
                        error.put("message", err.message)
                        callback("onAdFailedToLoad", adUnit, error)
                    }

                    override fun onAdImpression(adInfo: DaroAdInfo) {
                        callback("onAdImpression", adUnit)
                    }

                    override fun onAdClicked(adInfo: DaroAdInfo) {
                        callback("onAdClicked", adUnit)
                    }
                })
                loadAd()
            }
        } ?: run {
            callback("onAdFailedToLoad", adUnit, "Context is null")
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        result.notImplemented()
    }


    private fun callback(event: String, adId: String?) {
        callback(event, adId, null)
    }

    private fun callback(event: String, adId: String?, message: Any?) {
        val data = JSONObject()
        data.put("event", event)
        data.put("adId", adId)
        data.put("data", message)
        eventSink?.success(data)
    }

    override fun getView(): View {
        return adView ?: View(context)
    }

    override fun dispose() {
//        methodChannel?.setMethodCallHandler(null)
        eventSink = null
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}