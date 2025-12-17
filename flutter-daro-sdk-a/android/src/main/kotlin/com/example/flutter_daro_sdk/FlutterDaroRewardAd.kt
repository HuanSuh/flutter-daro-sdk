package com.example.flutter_daro_sdk

import android.app.Activity
import android.content.Context
import android.graphics.Color
import androidx.core.graphics.toColorInt
import droom.daro.core.adunit.DaroAppOpenAdUnit
import droom.daro.core.adunit.DaroInterstitialAdUnit
import droom.daro.core.adunit.DaroLightPopupAdUnit
import droom.daro.core.adunit.DaroRewardedAdUnit
import droom.daro.core.listener.DaroAppOpenAdListener
import droom.daro.core.listener.DaroAppOpenAdLoaderListener
import droom.daro.core.listener.DaroInterstitialAdListener
import droom.daro.core.listener.DaroInterstitialAdLoaderListener
import droom.daro.core.listener.DaroLightPopupAdListener
import droom.daro.core.listener.DaroLightPopupAdLoaderListener
import droom.daro.core.listener.DaroRewardedAdListener
import droom.daro.core.listener.DaroRewardedAdLoaderListener
import droom.daro.core.model.DaroAdDisplayFailError
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroAppOpenAd
import droom.daro.core.model.DaroInterstitialAd
import droom.daro.core.model.DaroLightPopupAd
import droom.daro.core.model.DaroLightPopupAdOptions
import droom.daro.core.model.DaroRewardedAd
import droom.daro.loader.DaroAppOpenAdLoader
import droom.daro.loader.DaroInterstitialAdLoader
import droom.daro.loader.DaroLightPopupAdLoader
import droom.daro.loader.DaroRewardedAdLoader

// 광고 타입 정의
enum class FlutterDaroRewardAdType(val value: String) {
    INTERSTITIAL("interstitial"),
    REWARDED_VIDEO("rewardedVideo"),
    POPUP("popup"),
    OPENING("opening");

    companion object {
        fun fromString(value: String?): FlutterDaroRewardAdType? {
            if(value == null) return null
            return entries.find { it.value == value }
        }
    }
}

// 광고 로드 리스너
interface FlutterDaroRewardAdLoadListener {
    fun onAdLoadSuccess(ad: FlutterDaroRewardAd, adInstance: Any?, adInfo: DaroAdInfo?) {}
    fun onAdLoadFail(error: DaroAdLoadError) {}
}

// 광고 표시 리스너
interface FlutterDaroRewardAdListener {
    fun onShown(adInfo: DaroAdInfo) {}
    fun onRewarded(adInfo: DaroAdInfo, rewardItem: DaroRewardedAd.DaroRewardedItem) {}
    fun onAdImpression(adInfo: DaroAdInfo) {}
    fun onAdClicked(adInfo: DaroAdInfo) {}
    fun onDismiss(adInfo: DaroAdInfo) {}
    fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {}
}

// Factory 클래스
object FlutterDaroRewardAdFactory {
    fun create(
        context: Context,
        adType: FlutterDaroRewardAdType,
        adUnit: String,
        placement: String? = null,
        options: Map<*,*>? = null,
        loadListener: FlutterDaroRewardAdLoadListener? = null
    ): FlutterDaroRewardAd {
        return when (adType) {
            FlutterDaroRewardAdType.INTERSTITIAL -> {
                FlutterDaroInterstitialAd(context, adUnit, placement, loadListener)
            }
            FlutterDaroRewardAdType.REWARDED_VIDEO -> {
                FlutterDaroRewardedVideoAd(context, adUnit, placement, loadListener)
            }
            FlutterDaroRewardAdType.POPUP -> {
                FlutterDaroPopupAd(context, adUnit, placement, loadListener, options)
            }
            FlutterDaroRewardAdType.OPENING -> {
                FlutterDaroOpeningAd(context, adUnit, placement, loadListener)
            }
        }
    }
}

// 추상 광고 클래스
abstract class FlutterDaroRewardAd(
    protected val context: Context,
    protected val adUnit: String,
    protected val placement: String? = null,
    protected var loadListener: FlutterDaroRewardAdLoadListener? = null
) {
    // 상위 클래스에서 공통으로 관리하는 loader와 ad
    private var loader: Any? = null
    protected var ad: Any? = null

    // 각 구체 클래스에서 로더 생성 구현
    protected abstract fun createLoader(): Any

    // 각 구체 클래스에서 로더 구현
    protected abstract fun loadAdInternal(
        loader: Any,
        autoShow: Boolean,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    )

    // 각 구체 클래스에서 광고 리스너 설정 및 표시 구현
    protected abstract fun showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    )

    // 각 구체 클래스에서 광고 해제 구현
    protected abstract fun destroyAd(ad: Any?)

    private fun setupLoader() {
        loader = createLoader()
    }

    // 공통 로드 로직
    fun loadAd(
        autoShow: Boolean = false,
        listener: FlutterDaroRewardAdListener? = null,
        result: (Boolean, Any?) -> Unit
    ) {
        if(ad != null) {
            // 이미 로드된 광고가 있으면 바로 리턴
            loadListener?.onAdLoadSuccess(this@FlutterDaroRewardAd, ad, null)
            result(true, null)
            return
        }
        if (loader == null) {
            setupLoader()
        }

        loader?.let {
            try {
                loadAdInternal(it, autoShow, listener, result)
            } catch (e: Exception) {
                result(false, mapOf(
                    "code" to 1011,
                    "message" to "Failed to load ad",
                    "details" to e.message,
                ))
                destroy()
            }
        } ?: result(false, mapOf(
            "code" to 1011,
            "message" to "Failed to load ad",
            "details" to "Failed to create loader",
        ))
    }

    // 공통 표시 로직
    fun showAd(
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        ad?.let { currentAd ->
            try {
                showAdInternal(currentAd, listener, result)
            } catch (e: Exception) {
                result(false, mapOf(
                    "code" to 1012,
                    "message" to "Failed to show ad",
                    "details" to e.message,
                ))
                destroy()
            }
        } ?: run {
            loadAd(autoShow = true, listener = listener, result = result)
        }
    }

    // 공통 해제 로직
    fun destroy() {
        ad?.let { destroyAd(it) }
        ad = null
        loader = null
        loadListener = null
    }
}

// 전면 광고 클래스
class FlutterDaroInterstitialAd(
    context: Context,
    adUnit: String,
    placement: String? = null,
    loadListener: FlutterDaroRewardAdLoadListener? = null
) : FlutterDaroRewardAd(context, adUnit, placement, loadListener) {

    override fun createLoader(): DaroInterstitialAdLoader {
        val unit = DaroInterstitialAdUnit(
            key = adUnit,
            placement = placement ?: ""
        )
        return DaroInterstitialAdLoader(
            context = context,
            adUnit = unit
        )
    }

    override fun loadAdInternal(
        loader: Any,
        autoShow: Boolean,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        (loader as? DaroInterstitialAdLoader)?.setListener(object : DaroInterstitialAdLoaderListener {
            override fun onAdLoadSuccess(ad: DaroInterstitialAd, adInfo: DaroAdInfo) {
                this@FlutterDaroInterstitialAd.ad = ad
                loadListener?.onAdLoadSuccess(this@FlutterDaroInterstitialAd, ad, adInfo)
                
                if (autoShow) {
                    showAd(listener) { success, error ->
                        result(success, error)
                    }
                } else {
                    result(true, null)
                }
            }

            override fun onAdLoadFail(error: DaroAdLoadError) {
                loadListener?.onAdLoadFail(error)
                result(false, mapOf(
                    "code" to error.code,
                    "message" to error.message
                ))
            }
        })
        (loader as? DaroInterstitialAdLoader)?.load()
    }

    override fun showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        (ad as? DaroInterstitialAd)?.let { interstitialAd ->
            interstitialAd.setListener(object : DaroInterstitialAdListener {
                override fun onAdImpression(adInfo: DaroAdInfo) {
                    listener?.onAdImpression(adInfo)
                }

                override fun onAdClicked(adInfo: DaroAdInfo) {
                    listener?.onAdClicked(adInfo)
                }

                override fun onShown(adInfo: DaroAdInfo) {
                    listener?.onShown(adInfo)
                }

                override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                    listener?.onFailedToShow(adInfo, error)
                    destroy()
                    result(false, mapOf(
                        "code" to -1,//error.code,
                        "message" to error.message
                    ))
                }

                override fun onDismiss(adInfo: DaroAdInfo) {
                    listener?.onDismiss(adInfo)
                    destroy()
                    result(true, null)
                }
            })
            (context as? Activity)?.let { currentActivity ->
                interstitialAd.show(activity = currentActivity)
            } ?: {
                result(false, mapOf(
                    "code" to 1013,
                    "message" to "No activity available to show ad"
                ))
            }
        }
    }

    override fun destroyAd(ad: Any?) {
        (ad as? DaroInterstitialAd)?.destroy()
    }
}

// 리워드 비디오 광고 클래스
class FlutterDaroRewardedVideoAd(
    context: Context,
    adUnit: String,
    placement: String? = null,
    loadListener: FlutterDaroRewardAdLoadListener? = null
) : FlutterDaroRewardAd(context, adUnit, placement, loadListener) {

    override fun createLoader(): DaroRewardedAdLoader {
        val unit = DaroRewardedAdUnit(
            key = adUnit,
            placement = placement ?: ""
        )
        return DaroRewardedAdLoader(
            context = context,
            adUnit = unit
        )
    }

    override fun loadAdInternal(
        loader: Any,
        autoShow: Boolean,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        (loader as? DaroRewardedAdLoader)?.setListener(object : DaroRewardedAdLoaderListener {
            override fun onAdLoadSuccess(ad: DaroRewardedAd, adInfo: DaroAdInfo) {
                this@FlutterDaroRewardedVideoAd.ad = ad
                loadListener?.onAdLoadSuccess(this@FlutterDaroRewardedVideoAd, ad, adInfo)
                
                if (autoShow) {
                    showAd(listener) { success, error ->
                        result(success, error)
                    }
                } else {
                    result(true, null)
                }
            }

            override fun onAdLoadFail(error: DaroAdLoadError) {
                loadListener?.onAdLoadFail(error)
                destroy()
                result(false, mapOf(
                    "code" to error.code,
                    "message" to error.message
                ))
            }
        })
        (loader as? DaroRewardedAdLoader)?.load()
    }

    override fun showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        (ad as? DaroRewardedAd)?.let { rewardedAd ->
            var reward: DaroRewardedAd.DaroRewardedItem? = null
            rewardedAd.setListener(object : DaroRewardedAdListener {
                override fun onAdImpression(adInfo: DaroAdInfo) {
                    listener?.onAdImpression(adInfo)
                }

                override fun onAdClicked(adInfo: DaroAdInfo) {
                    listener?.onAdClicked(adInfo)
                }

                override fun onShown(adInfo: DaroAdInfo) {
                    listener?.onShown(adInfo)
                }

                override fun onEarnedReward(adInfo: DaroAdInfo, rewardItem: DaroRewardedAd.DaroRewardedItem) {
                    reward = rewardItem
                    listener?.onRewarded(adInfo, rewardItem)
                }

                override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                    listener?.onFailedToShow(adInfo, error)
                    destroy()
                    result(false, mapOf(
                        "code" to -1,//error.code,
                        "message" to error.message
                    ))
                }

                override fun onDismiss(adInfo: DaroAdInfo) {
                    listener?.onDismiss(adInfo)
                    destroy()
                    result(reward != null, null)
                }
            })
            (context as? Activity)?.let { currentActivity ->
                rewardedAd.show(activity = currentActivity)
            } ?: {
                result(false, mapOf(
                    "code" to 1013,
                    "message" to "No activity available to show ad"
                ))
            }
        }
    }

    override fun destroyAd(ad: Any?) {
        (ad as? DaroRewardedAd)?.destroy()
    }
}

// 팝업 광고 클래스
class FlutterDaroPopupAd(
    context: Context,
    adUnit: String,
    placement: String? = null,
    loadListener: FlutterDaroRewardAdLoadListener? = null,
    private val options: Map<*, *>?,
) : FlutterDaroRewardAd(context, adUnit, placement, loadListener) {

    private fun createOptions(map: Map<*, *>?): DaroLightPopupAdOptions {
        if(map == null || map.isEmpty()) return DaroLightPopupAdOptions()
        fun valueToColorInt(value: Any?, defaultValue: String): Int {
            return when(value) {
                is Long -> {
                    val a = ((value shr 24) and 0xFF).toInt()
                    val r = ((value shr 16) and 0xFF).toInt()
                    val g = ((value shr 8) and 0xFF).toInt()
                    val b = (value and 0xFF).toInt()
                    Color.argb(a, r, g, b)
                }
                is Int -> {
                    val a = ((value shr 24) and 0xFF)
                    val r = ((value shr 16) and 0xFF)
                    val g = ((value shr 8) and 0xFF)
                    val b = (value and 0xFF)
                    Color.argb(a, r, g, b)
                }
                is String -> value.toColorInt()
                else -> defaultValue.toColorInt()
            }
        }
        return DaroLightPopupAdOptions(
            backgroundColor = valueToColorInt(map["backgroundColor"], "#B2121416"),
            containerColor = valueToColorInt(map["containerColor"], "#121416"),
            adMarkLabelTextColor = valueToColorInt(map["adMarkLabelTextColor"], "#F7FAFF"),
            adMarkLabelBackgroundColor = valueToColorInt(map["adMarkLabelBackgroundColor"], "#3E434F"),
            titleColor = valueToColorInt(map["titleColor"], "#F7FAFF"),
            bodyColor = valueToColorInt(map["bodyColor"], "#B6BECC"),
            ctaBackgroundColor = valueToColorInt(map["ctaBackgroundColor"], "#EB2640"),
            ctaTextColor= valueToColorInt(map["ctaTextColor"], "#FFFFFF"),
            closeButtonText = map["closeButtonText"] as? String ?: "Close", 
            closeButtonColor = valueToColorInt(map["closeButtonColor"], "#F7FAFF"),
        )
    }

    override fun createLoader(): DaroLightPopupAdLoader {
        val unit = DaroLightPopupAdUnit(
            key = adUnit,
            placement = placement ?: "",
            options = createOptions(options)
        )
        return DaroLightPopupAdLoader(
            context = context,
            adUnit = unit
        )
    }

    override fun loadAdInternal(
        loader: Any,
        autoShow: Boolean,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        (loader as? DaroLightPopupAdLoader)?.setListener(object : DaroLightPopupAdLoaderListener {
            override fun onAdLoadSuccess(ad: DaroLightPopupAd, adInfo: DaroAdInfo) {
                this@FlutterDaroPopupAd.ad = ad
                loadListener?.onAdLoadSuccess(this@FlutterDaroPopupAd, ad, adInfo)
                
                if (autoShow) {
                    showAd(listener) { success, error ->
                        result(success, error)
                    }
                } else {
                    result(true, null)
                }
            }

            override fun onAdLoadFail(error: DaroAdLoadError) {
                loadListener?.onAdLoadFail(error)
                destroy()
                result(false, mapOf(
                    "code" to error.code,
                    "message" to error.message
                ))
            }
        })
        (loader as? DaroLightPopupAdLoader)?.load()
    }

    override fun showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        (ad as? DaroLightPopupAd)?.let { popupAd ->
            popupAd.setListener(object : DaroLightPopupAdListener {
                override fun onAdImpression(adInfo: DaroAdInfo) {
                    listener?.onAdImpression(adInfo)
                }

                override fun onAdClicked(adInfo: DaroAdInfo) {
                    listener?.onAdClicked(adInfo)
                }

                override fun onShown(adInfo: DaroAdInfo) {
                    listener?.onShown(adInfo)
                }

                override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                    listener?.onFailedToShow(adInfo, error)
                    destroy()
                    result(false, mapOf(
                        "code" to -1,//error.code,
                        "message" to error.message
                    ))
                }

                override fun onDismiss(adInfo: DaroAdInfo) {
                    listener?.onDismiss(adInfo)
                    destroy()
                    result(true, null)
                }
            })
            (context as? Activity)?.let { currentActivity ->
                popupAd.show(activity = currentActivity)
            } ?: {
                result(false, mapOf(
                    "code" to 1013,
                    "message" to "No activity available to show ad"
                ))
            }
        }
    }

    override fun destroyAd(ad: Any?) {
        (ad as? DaroLightPopupAd)?.destroy()
    }
}

// 앱 오프닝 광고 클래스
class FlutterDaroOpeningAd(
    context: Context,
    adUnit: String,
    placement: String? = null,
    loadListener: FlutterDaroRewardAdLoadListener? = null
) : FlutterDaroRewardAd(context, adUnit, placement, loadListener) {

    override fun createLoader(): DaroAppOpenAdLoader {
        val unit = DaroAppOpenAdUnit(
            key = adUnit,
            placement = placement ?: ""
        )
        return DaroAppOpenAdLoader(
            context = context,
            adUnit = unit
        )
    }

    override fun loadAdInternal(
        loader: Any,
        autoShow: Boolean,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        (loader as? DaroAppOpenAdLoader)?.setListener(object : DaroAppOpenAdLoaderListener {
            override fun onAdLoadSuccess(ad: DaroAppOpenAd, adInfo: DaroAdInfo) {
                this@FlutterDaroOpeningAd.ad = ad
                loadListener?.onAdLoadSuccess(this@FlutterDaroOpeningAd, ad, adInfo)
                
                if (autoShow) {
                    showAd(listener) { success, error ->
                        result(success, error)
                    }
                } else {
                    result(true, null)
                }
            }

            override fun onAdLoadFail(error: DaroAdLoadError) {
                loadListener?.onAdLoadFail(error)
                destroy()
                result(false, mapOf(
                    "code" to error.code,
                    "message" to error.message
                ))
            }
        })
        (loader as? DaroAppOpenAdLoader)?.load()
    }

    override fun showAdInternal(
        ad: Any,
        listener: FlutterDaroRewardAdListener?,
        result: (Boolean, Any?) -> Unit
    ) {
        (ad as? DaroAppOpenAd)?.let { appOpenAd ->
            appOpenAd.setListener(object : DaroAppOpenAdListener {
                override fun onAdImpression(adInfo: DaroAdInfo) {
                    listener?.onAdImpression(adInfo)
                }

                override fun onAdClicked(adInfo: DaroAdInfo) {
                    listener?.onAdClicked(adInfo)
                }

                override fun onShown(adInfo: DaroAdInfo) {
                    listener?.onShown(adInfo)
                }

                override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                    listener?.onFailedToShow(adInfo, error)
                    destroy()
                    result(false, mapOf(
                        "code" to -1,//error.code,
                        "message" to error.message
                    ))
                }

                override fun onDismiss(adInfo: DaroAdInfo) {
                    listener?.onDismiss(adInfo)
                    destroy()
                    result(true, null)
                }
            })

            (context as? Activity)?.let { currentActivity ->
                appOpenAd.show(activity = currentActivity)
            } ?: {
                result(false, mapOf(
                    "code" to 1013,
                    "message" to "No activity available to show ad"
                ))
            }
        }
    }

    override fun destroyAd(ad: Any?) {
        (ad as? DaroAppOpenAd)?.destroy()
    }
}